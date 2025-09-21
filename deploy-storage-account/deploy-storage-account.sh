
#!/usr/bin/env bash
set -euo pipefail

LOCATION="${LOCATION:-eastus}"                    
RESOURCE_GROUP="${RESOURCE_GROUP:-rg-artifacts}"   
SA_NAME="devopsstorage$RANDOM"  # must be globally unique
CONTAINER="${CONTAINER:-artifacts}"
BLOB_NAME="deployment-package"
SAS_LIFETIME_MINS="${SAS_LIFETIME_MINS:-60}"

# 1) Resource group
az group create \
  --name "$RESOURCE_GROUP" \
  --location "$LOCATION" \
  --output none

# 2) Storage account (secure defaults)
az storage account create \
  --name "$SA_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --location "$LOCATION" \
  --sku Standard_LRS \
  --kind StorageV2 \
  --min-tls-version TLS1_2 \
  --allow-blob-public-access false \
  --https-only true \
  --default-action Allow \
  --output none

# 3) Fetch an account key (for CLI auth)
ACCOUNT_KEY="$(az storage account keys list \
  --account-name "$SA_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --query '[0].value' -o tsv)"

# 4) Create a blob container
az storage container create \
  --name "$CONTAINER" \
  --account-name "$SA_NAME" \
  --account-key "$ACCOUNT_KEY" \
  --auth-mode key \
  --public-access off \
  --output none