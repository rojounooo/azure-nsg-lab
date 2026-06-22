#!/bin/bash

# Usage: ./create-vnet.sh <resource-group> <vnet-name> <address-prefix> <location>

RESOURCE_GROUP=$1
VNET_NAME=$2
ADDRESS_PREFIX=$3
LOCATION=$4

if [[ -z "$RESOURCE_GROUP" ]]; then
  echo "Error: resource group name is required"
  echo "Usage: ./create-vnet.sh <resource-group> <vnet-name> <address-prefix> <location>"
  exit 1
fi

if [[ -z "$VNET_NAME" ]]; then
  echo "Error: vnet name is required"
  echo "Usage: ./create-vnet.sh <resource-group> <vnet-name> <address-prefix> <location>"
  exit 1
fi

if [[ -z "$ADDRESS_PREFIX" ]]; then
  echo "Error: address prefix is required"
  echo "Usage: ./create-vnet.sh <resource-group> <vnet-name> <address-prefix> <location>"
  exit 1
fi

if [[ -z "$LOCATION" ]]; then
  echo "Error: location is required"
  echo "Usage: ./create-vnet.sh <resource-group> <vnet-name> <address-prefix> <location>"
  exit 1
fi

# Check resource group exists
if ! az group show --name "$RESOURCE_GROUP" &>/dev/null; then
  echo "Error: resource group '$RESOURCE_GROUP' does not exist"
  exit 1
fi

# Check vnet does not already exist
if az network vnet show --resource-group "$RESOURCE_GROUP" --name "$VNET_NAME" &>/dev/null; then
  echo "Error: VNet '$VNET_NAME' already exists in '$RESOURCE_GROUP'"
  exit 1
fi

echo "Creating VNet '$VNET_NAME' with address space '$ADDRESS_PREFIX'..."

az network vnet create \
  --resource-group "$RESOURCE_GROUP" \
  --name "$VNET_NAME" \
  --address-prefix "$ADDRESS_PREFIX" \
  --location "$LOCATION"

if [[ $? -ne 0 ]]; then
  echo "Error: failed to create VNet"
  exit 1
fi

echo "Creating subnet 'snet-web' (10.0.1.0/24)..."

az network vnet subnet create \
  --resource-group "$RESOURCE_GROUP" \
  --vnet-name "$VNET_NAME" \
  --name snet-web \
  --address-prefix 10.0.1.0/24

if [[ $? -ne 0 ]]; then
  echo "Error: failed to create snet-web"
  exit 1
fi

echo "Creating subnet 'snet-data' (10.0.2.0/24)..."

az network vnet subnet create \
  --resource-group "$RESOURCE_GROUP" \
  --vnet-name "$VNET_NAME" \
  --name snet-data \
  --address-prefix 10.0.2.0/24

if [[ $? -ne 0 ]]; then
  echo "Error: failed to create snet-data"
  exit 1
fi

echo "VNet '$VNET_NAME' and subnets created successfully"
