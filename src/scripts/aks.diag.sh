#!/bin/bash

PREFIX="pz-ao"
SUFFIX="34"
location="westus2"

subscriptionId="$(az account show -o tsv --query 'id')"
resourceGroup="always-on-""$location"
clusterName="pz-ao-""$location"

# Purge kubectl
kubectl config unset current-context
kubectl config unset contexts
kubectl config unset clusters
kubectl config unset users
#kubectl config view

az aks get-credentials --subscription "$subscriptionId" -g "$resourceGroup" -n "$clusterName" --overwrite-existing --verbose

#kubectl get deployments -A -o wide
#kubectl get nodes -A -o wide
#kubectl get daemonsets -A -o wide
#kubectl get services -A -o wide
#kubectl get pods -A -o wide

#kubectl get azureidentity
#kubectl get azureidentitybinding

# Bounce
#kubectl -n default rollout restart deployment
#kubectl -n default rollout restart daemonset
