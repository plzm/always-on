#!/bin/bash

PREFIX="pz-ao"
SUFFIX="22"

subscriptionId="$(az account show -o tsv --query 'id')"
location="eastus"

AZURE_RESOURCE_GROUP=always-on-$location
UAMI_NAME=$PREFIX-$location

resourceGroup="always-on-""$location"
clusterName="pz-ao-""$location"

UAMI_ID=$(az identity show --subscription $subscriptionId -g $AZURE_RESOURCE_GROUP -n $UAMI_NAME -o tsv --query 'id')
UAMI_PRINCIPAL_ID=$(az identity show --subscription $subscriptionId -g $AZURE_RESOURCE_GROUP -n $UAMI_NAME -o tsv --query 'principalId')
UAMI_CLIENT_ID=$(az identity show --subscription $subscriptionId -g $AZURE_RESOURCE_GROUP -n $UAMI_NAME -o tsv --query 'clientId')

az aks get-credentials --subscription "$subscriptionId" -g "$resourceGroup" -n "$clusterName" --overwrite-existing --verbose

kubectl get deployments -A -o wide
kubectl get nodes -A -o wide
kubectl get daemonsets -A -o wide
kubectl get services -A -o wide
kubectl get pods -A -o wide
