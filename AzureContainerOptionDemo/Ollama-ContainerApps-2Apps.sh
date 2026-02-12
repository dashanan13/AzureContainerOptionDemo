#!/bin/bash

################################################################################
# Azure Container Apps: Ollama + OpenWebUI Multi-Container Setup
################################################################################
# This script deploys a Container App with two containers:
# 1. Ollama - Large Language Model server (backend)
# 2. OpenWebUI - Web interface for Ollama (frontend)
#
# Prerequisites:
# - Azure CLI installed (az command)
# - Logged in to Azure (az login)
# - Resource Group already created or modify the script to create one
################################################################################

# Configuration Variables
RESOURCE_GROUP="mohit-master"
CONTAINER_APP_NAME="ollama-openwebui-app"
ENVIRONMENT_NAME="ollama-env"
LOCATION="westeurope"
REGISTRY_SERVER="mohitcontainerregistry13.azurecr.io"  # Set if using private registry, e.g., myregistry.azurecr.io
REGISTRY_USERNAME="mohitcontainerregistry13"
REGISTRY_PASSWORD="9vRSyJgcL1u95tGeRENcyGyveMbxOaNYtDrGZPoX1fuuCirOB2WOJQQJ99CBACfhMk5Eqg7NAAACAZCRXz1w"

################################################################################
# STEP 1: Create a Container Apps Environment
################################################################################
echo "Step 1: Creating Container Apps Environment..."

az containerapp env create \
  --name "$ENVIRONMENT_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --location "$LOCATION"

echo "✓ Container Apps Environment created"

################################################################################
# STEP 2: Create the Container App with initial placeholder image
################################################################################
echo ""
echo "Step 2: Creating Container App (will be updated with multi-container config)..."

az containerapp create \
  --resource-group "$RESOURCE_GROUP" \
  --name "$CONTAINER_APP_NAME" \
  --environment "$ENVIRONMENT_NAME" \
  --image mcr.microsoft.com/k8se/samples/hello-world:latest \
  --target-port 80 \
  --ingress 'external' \
  --cpu 2 \
  --memory 4Gi \
  --min-replicas 1 \
  --max-replicas 1

echo "✓ Container App created"

################################################################################
# STEP 3: Update Container App to add OpenWebUI as second container
################################################################################
echo ""
echo "Step 3: Adding Ollama and OpenWebUI containers..."

# Wait a moment for initial deployment to complete
sleep 10

# Create a YAML configuration for the multi-container setup
cat > container-config.yaml <<'EOF'
properties:
  template:
    containers:
    - name: ollama
      image: ollama/ollama:latest
      resources:
        cpu: 1.5
        memory: 3Gi
      env:
      - name: OLLAMA_HOST
        value: "0.0.0.0:11434"
    - name: openwebui
      image: ghcr.io/open-webui/open-webui:latest
      resources:
        cpu: 0.5
        memory: 1Gi
      env:
      - name: OLLAMA_BASE_URL
        value: "http://localhost:11434"
    scale:
      minReplicas: 1
      maxReplicas: 1
  configuration:
    ingress:
      external: true
      targetPort: 8080
      transport: auto
EOF

# Update the container app with the multi-container configuration
az containerapp update \
  --name "$CONTAINER_APP_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --yaml container-config.yaml

echo "✓ Container App updated with Ollama and OpenWebUI"

################################################################################
# STEP 4: Get the Container App URL
################################################################################
echo ""
echo "Step 4: Retrieving Container App details..."

FQDN=$(az containerapp show \
  --resource-group "$RESOURCE_GROUP" \
  --name "$CONTAINER_APP_NAME" \
  --query properties.configuration.ingress.fqdn \
  --output tsv)

echo "✓ Container App is ready!"
echo ""
echo "=========================================="
echo "Deployment Complete!"
echo "=========================================="
echo "OpenWebUI URL: https://$FQDN"
echo "Ollama Base URL (internal): http://localhost:11434"
echo ""
echo "Next Steps:"
echo "1. Open https://$FQDN in your browser"
echo "2. OpenWebUI will automatically connect to Ollama on localhost:11434"
echo "3. Download a model in OpenWebUI (e.g., llama2, mistral, neural-chat)"
echo "4. Start chatting!"
echo ""
echo "To pull a model via Ollama directly:"
echo "  az containerapp exec -n $CONTAINER_APP_NAME -g $RESOURCE_GROUP --revision latest --container ollama -- ollama pull mistral"
echo ""

################################################################################
# STEP 5: View Logs
################################################################################
echo "View logs:"
echo "  az containerapp logs show --name $CONTAINER_APP_NAME --resource-group $RESOURCE_GROUP"

################################################################################
# CLEANUP: Delete resources (comment out until you want to delete)
################################################################################
# To delete the Container App and Environment when done:
# az containerapp delete \
#   --name "$CONTAINER_APP_NAME" \
#   --resource-group "$RESOURCE_GROUP" \
#   --yes
#
# az containerapp env delete \
#   --name "$ENVIRONMENT_NAME" \
#   --resource-group "$RESOURCE_GROUP" \
#   --yes

################################################################################
# NOTES:
################################################################################
# - Ollama container runs on port 11434 (internal only)
# - OpenWebUI container runs on port 8080 (exposed externally)
# - OpenWebUI connects to Ollama via http://localhost:11434
# - Both containers share the same network within the Container App
# - Default resources: 2 CPU, 4GB RAM total
# - GPU support: Add accelerator: gpu to container config if needed
# - Volume mounting: Use --mounts parameter for persistent storage
#
# Environment Variables:
# - OLLAMA_HOST: Binding address for Ollama server
# - OLLAMA_BASE_URL: URL that OpenWebUI uses to reach Ollama
#
# For production:
# - Enable logging and monitoring
# - Set up auto-scaling policies
# - Use health checks (livenessProbe, readinessProbe)
# - Store sensitive data in Key Vault
# - Configure backup and disaster recovery
################################################################################
