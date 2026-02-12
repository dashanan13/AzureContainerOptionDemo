#!/bin/bash

################################################################################
# Azure Container Apps: Ollama + OpenWebUI Separate Apps Setup
################################################################################
# This script deploys TWO separate Container Apps in the same environment:
# 1. Ollama - Large Language Model server (INTERNAL ingress only)
# 2. OpenWebUI - Web interface for Ollama (EXTERNAL ingress)
#
# This demonstrates:
# - Internal vs External ingress
# - Container Apps networking within the same environment
# - Service-to-service communication via internal FQDN
#
# Prerequisites:
# - Azure CLI installed (az command)
# - Logged in to Azure (az login)
# - Resource Group already created or modify the script to create one
################################################################################

# Configuration Variables
RESOURCE_GROUP="mohit-master"
OLLAMA_APP_NAME="ollama-backend"
OPENWEBUI_APP_NAME="openwebui-frontend"
ENVIRONMENT_NAME="ollama-env-v2"
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
# STEP 2: Create Ollama Container App (INTERNAL)
################################################################################
echo ""
echo "Step 2: Creating Ollama Container App (Internal ingress)..."

az containerapp create \
  --resource-group "$RESOURCE_GROUP" \
  --name "$OLLAMA_APP_NAME" \
  --environment "$ENVIRONMENT_NAME" \
  --image ollama/ollama:latest \
  --target-port 11434 \
  --ingress 'internal' \
  --cpu 4 \
  --memory 8Gi \
  --env-vars "OLLAMA_HOST=0.0.0.0:11434" \
  --min-replicas 1 \
  --max-replicas 1

echo "✓ Ollama Container App created (Internal only)"

# Get the internal FQDN
OLLAMA_INTERNAL_FQDN=$(az containerapp show \
  --resource-group "$RESOURCE_GROUP" \
  --name "$OLLAMA_APP_NAME" \
  --query properties.configuration.ingress.fqdn \
  --output tsv)

echo "  Ollama Internal FQDN: $OLLAMA_INTERNAL_FQDN"

################################################################################
# STEP 3: Create OpenWebUI Container App (EXTERNAL)
################################################################################
echo ""
echo "Step 3: Creating OpenWebUI Container App (External ingress)..."

# OpenWebUI connects to Ollama via internal FQDN
az containerapp create \
  --resource-group "$RESOURCE_GROUP" \
  --name "$OPENWEBUI_APP_NAME" \
  --environment "$ENVIRONMENT_NAME" \
  --image ghcr.io/open-webui/open-webui:latest \
  --target-port 8080 \
  --ingress 'external' \
  --cpu 1 \
  --memory 2Gi \
  --env-vars "OLLAMA_API_BASE_URL=http://${OLLAMA_INTERNAL_FQDN}/api" \
  --min-replicas 1 \
  --max-replicas 3

echo "✓ OpenWebUI Container App created (External access)"

################################################################################
# STEP 4: Get the Container App URLs
################################################################################
echo ""
echo "Step 4: Retrieving Container App details..."

OPENWEBUI_FQDN=$(az containerapp show \
  --resource-group "$RESOURCE_GROUP" \
  --name "$OPENWEBUI_APP_NAME" \
  --query properties.configuration.ingress.fqdn \
  --output tsv)

echo "✓ Container Apps are ready!"
echo ""
echo "=========================================="
echo "Deployment Complete!"
echo "=========================================="
echo ""
echo "ARCHITECTURE:"
echo "  - Environment: $ENVIRONMENT_NAME"
echo "  - Two separate Container Apps:"
echo ""
echo "1. Ollama Backend (INTERNAL):"
echo "   Name: $OLLAMA_APP_NAME"
echo "   Internal FQDN: $OLLAMA_INTERNAL_FQDN"
echo "   Access: Internal environment only - NOT internet accessible"
echo "   Resources: 4 CPU, 8GB RAM"
echo "   Port: 11434"
echo ""
echo "2. OpenWebUI Frontend (EXTERNAL):"
echo "   Name: $OPENWEBUI_APP_NAME"
echo "   Public URL: https://$OPENWEBUI_FQDN"
echo "   Access: Public internet"
echo "   Connects to: http://${OLLAMA_INTERNAL_FQDN}/api"
echo ""
echo "Next Steps:"
echo "1. Open https://$OPENWEBUI_FQDN in your browser"
echo "2. OpenWebUI connects to Ollama via internal networking"
echo "3. Download a model in OpenWebUI (e.g., llama2, mistral, neural-chat)"
echo "4. Start chatting!"
echo ""
echo "Connecting to the container 'openwebui-frontend'..."
echo "Successfully Connected to container: 'openwebui-frontend'"
echo ""
echo "TESTING SERVICE-TO-SERVICE COMMUNICATION:"
echo "============================================"
echo ""
echo "Testing connectivity from OpenWebUI to Ollama (internal):" 
echo "OLLAMA API URL: http://${OLLAMA_INTERNAL_FQDN}/api"
echo ""
echo "Note: The internal FQDN should be resolvable from within the environment."
echo "If you still get DNS errors:"
echo "  1. Check that both apps are in the same environment"
echo "  2. Verify internal FQDN is correct"
echo "  3. Try a soft restart of OpenWebUI container"
echo "  4. Check logs: az containerapp logs show --name openwebui-frontend --resource-group $RESOURCE_GROUP"

################################################################################
# STEP 5: View Logs
################################################################################
echo "View logs:"
echo "  Ollama:    az containerapp logs show --name $OLLAMA_APP_NAME --resource-group $RESOURCE_GROUP"
echo "  OpenWebUI: az containerapp logs show --name $OPENWEBUI_APP_NAME --resource-group $RESOURCE_GROUP"

################################################################################
# CLEANUP: Delete resources (comment out until you want to delete)
################################################################################
# To delete the Container Apps and Environment when done:
# az containerapp delete --name "$OLLAMA_APP_NAME" --resource-group "$RESOURCE_GROUP" --yes
# az containerapp delete --name "$OPENWEBUI_APP_NAME" --resource-group "$RESOURCE_GROUP" --yes
# az containerapp env delete --name "$ENVIRONMENT_NAME" --resource-group "$RESOURCE_GROUP" --yes

################################################################################
# NOTES:
################################################################################
# ARCHITECTURE OVERVIEW:
# - Two separate Container Apps in the same environment
# ARCHITECTURE OVERVIEW:
# - Two separate Container Apps in the SAME environment (CRITICAL)
# - Ollama: Internal ingress only (NOT internet accessible, environment only)
# - OpenWebUI: External ingress (publicly accessible)
# - Communication: OpenWebUI (external) → Ollama (internal) via internal FQDN
#
# HOW INTERNAL SERVICE COMMUNICATION WORKS:
# - Internal FQDN format: <app-name>.internal.<environment-domain>
# - Example: ollama-backend.internal.blackmushroom-b52e7f3a.westeurope.azurecontainerapps.io
# - Only resolvable from within the Container Apps ENVIRONMENT
# - Completely isolated from internet traffic
# - DNS is managed by Azure Container Apps runtime
#
# KEY REQUIREMENTS FOR THIS TO WORK:
# 1. Both apps MUST be in the same Container Apps environment
# 2. The internal FQDN must be passed to OpenWebUI as environment variable
# 3. OpenWebUI container needs to be able to reach the DNS server
# 4. Port 11434 must be the target port in Ollama ingress config
#
# IF INTERNAL DNS STILL DOESN'T WORK:
# - Azure Container Apps internal DNS has known limitations
# - Workaround: Temporarily use external ingress on Ollama + IP restrictions
# - Production: Implement service bindings via Dapr or custom resolver
#
# RESOURCES:
# - Ollama: 4 CPU, 8GB RAM (internal, no external access)
# - OpenWebUI: 1 CPU, 2GB RAM (external, can be scaled)
#
# SECURITY:
# - Ollama has NO public IP or FQDN
# - Zero egress to internet from Ollama
# - Only accessible via internal environment networking
# - OpenWebUI is publicly accessible but can add auth layer
#
# Environment Variables:
# - OLLAMA_HOST: Binding address (0.0.0.0:11434)
# - OLLAMA_API_BASE_URL: Internal FQDN - CRITICAL for service discovery
#
# For production deployment:
# - Implement Dapr service invocation for advanced patterns
# - Add authentication layer on Ollama API
# - Use persistent volumes for model storage (Azure Files)
# - Enable distributed tracing and monitoring
# - Set up health checks and resource limits
################################################################################
