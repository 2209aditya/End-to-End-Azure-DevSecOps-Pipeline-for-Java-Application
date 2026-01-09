#!/bin/bash
set -e

RESOURCE_GROUP="rg-devsecops-prod"
LOCATION="centralindia"
ACR_NAME="acrdevsecops"
AKS_NAME="aks-devsecops-prod"

echo "Creating Azure resources..."

az group create --name $RESOURCE_GROUP --location $LOCATION
az acr create --resource-group $RESOURCE_GROUP --name $ACR_NAME --sku Premium
az aks create --resource-group $RESOURCE_GROUP --name $AKS_NAME --node-count 3 --attach-acr $ACR_NAME
az aks get-credentials --resource-group $RESOURCE_GROUP --name $AKS_NAME

echo "Done!"