#!/bin/bash

subscriptionId="$(az account show -o tsv --query 'id')"
location="northeurope"

resourceGroup="always-on-""$location"

clusterName="pz-ao-""$location"


az aks get-credentials --subscription "$subscriptionId" -g "$resourceGroup" -n "$clusterName" --overwrite-existing --verbose

kubectl apply -f ../aks/azure-vote.yaml