#!/bin/bash

# Usage: ./create-nsgs.sh <resource-group> <location>
# Creates empty nsg-web and nsg-data and associates them with their subnets
# Rules should be configured manually in the portal after running this script

RESOURCE_GROUP=$1
LOCATION=$2

if [[ -z "$RESOURCE_GROUP" ]]; then
  echo "Error: resource group name is required"
  echo "Usage: ./create-nsgs.sh <resource-group> <location>"
  exit 1
fi

if [[ -z "$LOCATION" ]]; then
  echo "Error: location is required"
  echo "Usage: ./create-nsgs.sh <resource-group> <location>"
  exit 1
fi

# Check resource group exists
if ! az group show --name "$RESOURCE_GROUP" &>/dev/null; then
  echo "Error: resource group '$RESOURCE_GROUP' does not exist"
  exit 1
fi

# Check vnet exists
if ! az network vnet show --resource-group "$RESOURCE_GROUP" --name vnet-nsg-lab &>/dev/null; then
  echo "Error: vnet-nsg-lab does not exist in '$RESOURCE_GROUP' - run create-vnet.sh first"
  exit 1
fi

echo "Creating nsg-web..."

az network nsg create \
  --resource-group "$RESOURCE_GROUP" \
  --name nsg-web \
  --location "$LOCATION"

if [[ $? -ne 0 ]]; then
  echo "Error: failed to create nsg-web"
  exit 1
fi

echo "Associating nsg-web with snet-web..."

az network vnet subnet update \
  --resource-group "$RESOURCE_GROUP" \
  --vnet-name vnet-nsg-lab \
  --name snet-web \
  --network-security-group nsg-web

if [[ $? -ne 0 ]]; then
  echo "Error: failed to associate nsg-web with snet-web"
  exit 1
fi

echo "Creating nsg-data..."

az network nsg create \
  --resource-group "$RESOURCE_GROUP" \
  --name nsg-data \
  --location "$LOCATION"

if [[ $? -ne 0 ]]; then
  echo "Error: failed to create nsg-data"
  exit 1
fi

echo "Associating nsg-data with snet-data..."

az network vnet subnet update \
  --resource-group "$RESOURCE_GROUP" \
  --vnet-name vnet-nsg-lab \
  --name snet-data \
  --network-security-group nsg-data

if [[ $? -ne 0 ]]; then
  echo "Error: failed to associate nsg-data with snet-data"
  exit 1
fi

echo "nsg-web and nsg-data created and associated successfully"
echo "Configure rules manually in the portal before deploying VMs"
