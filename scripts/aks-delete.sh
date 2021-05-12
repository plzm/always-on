#!/bin/bash

subscriptionId="$(az account show -o tsv --query 'id')"
location="eastus"

resourceGroup="always-on-""$location"

clusterName="pz-ao-""$location"


az aks get-credentials --subscription "$subscriptionId" -g "$resourceGroup" -n "$clusterName" --overwrite-existing --verbose

kubectl delete -f ../aks/azure-vote.yaml

