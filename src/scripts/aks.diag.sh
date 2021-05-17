#!/bin/bash

subscriptionId="$(az account show -o tsv --query 'id')"
location="eastus"
resourceGroup="always-on-""$location"
clusterName="pz-ao-""$location"

az aks get-credentials --subscription "$subscriptionId" -g "$resourceGroup" -n "$clusterName" --overwrite-existing --verbose

kubectl get deployments -A -o wide
kubectl get nodes -A -o wide
kubectl get daemonsets -A -o wide
kubectl get services -A -o wide
kubectl get pods -A -o wide
