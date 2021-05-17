#!/bin/bash

subscriptionId="$(az account show -o tsv --query 'id')"
location="eastus"
resourceGroup="always-on-""$location"
clusterName="pz-ao-""$location"

az aks get-credentials --subscription "$subscriptionId" -g "$resourceGroup" -n "$clusterName" --overwrite-existing --verbose

# App
kubectl delete -f ../workload-deploy/aks/azure-vote.yaml

kubectl delete -f ../infra-deploy/aks/secret-provider-class.akv.yaml

kubectl delete -f ../infra-deploy/aks/aadpodidentitybinding.yaml
kubectl delete -f ../infra-deploy/aks/aadpodidentity.yaml

kubectl delete -f ../infra-deploy/aks/deployment-rbac.yaml

kubectl delete -f https://raw.githubusercontent.com/Azure/secrets-store-csi-driver-provider-azure/master/deployment/provider-azure-installer.yaml

kubectl delete -f "https://raw.githubusercontent.com/kubernetes-sigs/secrets-store-csi-driver/master/deploy/rbac-secretprovidersyncing.yaml"

kubectl delete -f "https://raw.githubusercontent.com/kubernetes-sigs/secrets-store-csi-driver/master/deploy/secrets-store-csi-driver.yaml"
kubectl delete -f "https://raw.githubusercontent.com/kubernetes-sigs/secrets-store-csi-driver/master/deploy/secrets-store.csi.x-k8s.io_secretproviderclasspodstatuses.yaml"
kubectl delete -f "https://raw.githubusercontent.com/kubernetes-sigs/secrets-store-csi-driver/master/deploy/secrets-store.csi.x-k8s.io_secretproviderclasses.yaml"

#kubectl delete -f "https://raw.githubusercontent.com/kubernetes-sigs/secrets-store-csi-driver/master/deploy/csidriver.yaml" # Outdated API Version
kubectl delete -f ../infra-deploy/aks/csidriver.yaml

kubectl delete -f "https://raw.githubusercontent.com/kubernetes-sigs/secrets-store-csi-driver/master/deploy/rbac-secretproviderclass.yaml"
