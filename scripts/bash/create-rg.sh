#!/bin/bash

# Usage: ./create-rg.sh <resource-group> <location>

RESOURCE_GROUP=$1
LOCATION=$2

if [[ -z "$RESOURCE_GROUP" ]]; then
  echo "Error: resource group name is required"
  echo "Usage: ./create-rg.sh <resource-group> <location>"
  exit 1
fi

if [[ -z "$LOCATION" ]]; then
  echo "Error: location is required"
  echo "Usage: ./create-rg.sh <resource-group> <location>"
  exit 1
fi

# Check if resource group already exists
if az group show --name "$RESOURCE_GROUP" &>/dev/null; then
  echo "Error: resource group '$RESOURCE_GROUP' already exists"
  exit 1
fi

echo "Creating resource group '$RESOURCE_GROUP' in '$LOCATION'..."

az group create \
  --name "$RESOURCE_GROUP" \
  --location "$LOCATION"

if [[ $? -ne 0 ]]; then
  echo "Error: failed to create resource group"
  exit 1
fi

echo "Resource group '$RESOURCE_GROUP' created successfully"
