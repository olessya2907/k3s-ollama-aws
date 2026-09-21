#!/bin/bash

# Path to the project root (folder where this script lives)
ROOT="$(cd "$(dirname "$0")" && pwd)"

# 1. Destroy all AWS infrastructure
echo "==> terraform destroy"
terraform -chdir="$ROOT/terraform" destroy -auto-approve

# 2. Stop the local OpenWebUI container
echo "==> Stopping OpenWebUI"
docker rm -f open-webui 2>/dev/null || true

# 3. Verify nothing expensive is left running
echo "==> Verifying no leftover resources..."
NAT=$(aws ec2 describe-nat-gateways --filter "Name=state,Values=available,pending" --query "NatGateways[].NatGatewayId" --output text)
EIP=$(aws ec2 describe-addresses --query "Addresses[].PublicIp" --output text)
INST=$(aws ec2 describe-instances --filters "Name=tag:Role,Values=master,worker" "Name=instance-state-name,Values=running,pending" --query "Reservations[].Instances[].InstanceId" --output text)

if [ -z "$NAT" ] && [ -z "$EIP" ] && [ -z "$INST" ]; then
  echo "==> Clean: no NAT gateways, Elastic IPs, or instances left. Nothing is being billed."
else
  echo "==> WARNING: some resources may still exist — check and re-run:"
  echo "    NAT gateways: $NAT"
  echo "    Elastic IPs:  $EIP"
  echo "    Instances:    $INST"
fi