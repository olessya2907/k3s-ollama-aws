#!/bin/bash
set -e

# Path to the project root (folder where this script lives)
ROOT="$(cd "$(dirname "$0")" && pwd)"

# 1. Point the Security Group at your current public IP
MY_IP=$(curl -s https://checkip.amazonaws.com)
echo "my_ip = \"${MY_IP}/32\"" > "$ROOT/terraform/terraform.tfvars"
echo "==> Using your public IP: ${MY_IP}"

# 2. Provision the infrastructure with Terraform
echo "==> terraform apply"
terraform -chdir="$ROOT/terraform" init -input=false
terraform -chdir="$ROOT/terraform" apply -auto-approve

# 3. Give the servers time to finish booting
echo "==> Waiting 60s for servers to boot..."
sleep 60

# 4. Install K3S with Ansible
echo "==> ansible-playbook"
( cd "$ROOT/ansible" && ansible-playbook playbook.yml )

# 5. Fetch the kubeconfig and point it at the master public IP
MASTER_IP=$(terraform -chdir="$ROOT/terraform" output -raw master_public_ip)
mkdir -p ~/.kube
scp -i ~/.ssh/k3s-ollama -o StrictHostKeyChecking=no \
  ubuntu@"$MASTER_IP":/etc/rancher/k3s/k3s.yaml ~/.kube/k3s-ollama.yaml
sed -i '' "s/127.0.0.1/$MASTER_IP/" ~/.kube/k3s-ollama.yaml
export KUBECONFIG=~/.kube/k3s-ollama.yaml

# 6. Deploy Ollama and the Ingress
echo "==> Deploying Ollama and Ingress"
kubectl apply -f "$ROOT/k3s/"

# 7. Wait for the Ollama pod, then pull the model
echo "==> Waiting for the Ollama pod to be ready..."
kubectl wait --for=condition=ready pod -l app=ollama --timeout=300s
echo "==> Pulling the model (llama3.2:1b)"
kubectl exec deploy/ollama -- ollama pull llama3.2:1b

# 8. Start OpenWebUI locally (fresh, pointing at the current master IP)
echo "==> Starting OpenWebUI"
docker rm -f open-webui 2>/dev/null || true
docker volume rm open-webui 2>/dev/null || true
docker run -d -p 3000:8080 \
  -e OLLAMA_BASE_URL=http://"$MASTER_IP" \
  -v open-webui:/app/backend/data \
  --name open-webui \
  ghcr.io/open-webui/open-webui:main

echo ""
echo "==> Done! Open http://localhost:3000 in about 30 seconds."
echo "==> Master public IP: $MASTER_IP"