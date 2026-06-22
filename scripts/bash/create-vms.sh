#!/bin/bash

# Usage: ./create-vms.sh <resource-group> <admin-username> <admin-password> <location>

RESOURCE_GROUP=$1
ADMIN_USERNAME=$2
ADMIN_PASSWORD=$3
LOCATION=$4

if [[ -z "$RESOURCE_GROUP" ]]; then
  echo "Error: resource group name is required"
  echo "Usage: ./create-vms.sh <resource-group> <admin-username> <admin-password> <location>"
  exit 1
fi

if [[ -z "$ADMIN_USERNAME" ]]; then
  echo "Error: admin username is required"
  echo "Usage: ./create-vms.sh <resource-group> <admin-username> <admin-password> <location>"
  exit 1
fi

if [[ -z "$ADMIN_PASSWORD" ]]; then
  echo "Error: admin password is required"
  echo "Usage: ./create-vms.sh <resource-group> <admin-username> <admin-password> <location>"
  exit 1
fi

if [[ -z "$LOCATION" ]]; then
  echo "Error: location is required"
  echo "Usage: ./create-vms.sh <resource-group> <admin-username> <admin-password> <location>"
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

# Check subnets exist
if ! az network vnet subnet show --resource-group "$RESOURCE_GROUP" --vnet-name vnet-nsg-lab --name snet-web &>/dev/null; then
  echo "Error: snet-web does not exist - run create-vnet.sh first"
  exit 1
fi

if ! az network vnet subnet show --resource-group "$RESOURCE_GROUP" --vnet-name vnet-nsg-lab --name snet-data &>/dev/null; then
  echo "Error: snet-data does not exist - run create-vnet.sh first"
  exit 1
fi

echo "Creating vm-web in snet-web..."

az vm create \
  --resource-group "$RESOURCE_GROUP" \
  --name vm-web \
  --image Ubuntu2204 \
  --vnet-name vnet-nsg-lab \
  --subnet snet-web \
  --public-ip-address vm-web-ip \
  --nsg "" \
  --admin-username "$ADMIN_USERNAME" \
  --admin-password "$ADMIN_PASSWORD" \
  --authentication-type password \
  --size Standard_B2ats_v2 \
  --location "$LOCATION"

if [[ $? -ne 0 ]]; then
  echo "Error: failed to create vm-web"
  exit 1
fi

echo "Creating vm-data in snet-data..."

az vm create \
  --resource-group "$RESOURCE_GROUP" \
  --name vm-data \
  --image Ubuntu2204 \
  --vnet-name vnet-nsg-lab \
  --subnet snet-data \
  --public-ip-address "" \
  --nsg "" \
  --admin-username "$ADMIN_USERNAME" \
  --admin-password "$ADMIN_PASSWORD" \
  --authentication-type password \
  --size Standard_B2ats_v2 \
  --location "$LOCATION"

if [[ $? -ne 0 ]]; then
  echo "Error: failed to create vm-data"
  exit 1
fi

echo "Both VMs created successfully"
