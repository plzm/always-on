#!/bin/bash

PREFIX="pz-ao"
SUFFIX="22"

subscriptionId="$(az account show -o tsv --query 'id')"
location="eastus"
resourceGroup="always-on-""$location"
clusterName="pz-ao-""$location"

AZURE_RESOURCE_GROUP_GLOBAL=always-on-global
AZURE_RESOURCE_GROUP=always-on-$location
UAMI_NAME=$PREFIX


#UAMI_ID=$(az identity show --subscription $subscriptionId -g $AZURE_RESOURCE_GROUP_GLOBAL -n $UAMI_NAME -o tsv --query 'id')
#UAMI_PRINCIPAL_ID=$(az identity show --subscription $subscriptionId -g $AZURE_RESOURCE_GROUP_GLOBAL -n $UAMI_NAME -o tsv --query 'principalId')
#UAMI_CLIENT_ID=$(az identity show --subscription $subscriptionId -g $AZURE_RESOURCE_GROUP_GLOBAL -n $UAMI_NAME -o tsv --query 'clientId')

#echo "Resource ID: ""$UAMI_ID"
#echo "Principal ID: ""$UAMI_PRINCIPAL_ID"
#echo "Client ID: ""$UAMI_CLIENT_ID"

# Purge kubectl
#kubectl config unset current-context
#kubectl config unset contexts
#kubectl config unset clusters
#kubectl config unset users
#kubectl config view

az aks get-credentials --subscription "$subscriptionId" -g "$resourceGroup" -n "$clusterName" --overwrite-existing --verbose

#kubectl get deployments -A -o wide
#kubectl get nodes -A -o wide
#kubectl get daemonsets -A -o wide
#kubectl get services -A -o wide
#kubectl get pods -A -o wide

#kubectl get azureidentity
#kubectl get azureidentitybinding

# Bounce pods
#kubectl -n default rollout restart deploy

# Shell to a pod
#kubectl exec --stdin --tty azure-vote-front-7d857d7f5b-xq9b4 -- /bin/bash

