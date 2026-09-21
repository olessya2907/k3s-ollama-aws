#!/bin/bash
# Master public IP - fill in after terraform apply
MASTER_IP="MASTER_PUBLIC_IP"

docker run -d \
  -p 3000:8080 \
  -e OLLAMA_BASE_URL=http://${MASTER_IP} \
  -v open-webui:/app/backend/data \
  --name open-webui \
  ghcr.io/open-webui/open-webui:main