#!/bin/bash

subscriptionId="$(az account show -o tsv --query 'id')"
location="eastus"
resourceGroup="always-on-""$location"
clusterName="pz-ao-""$location"

az aks get-credentials --subscription "$subscriptionId" -g "$resourceGroup" -n "$clusterName" --overwrite-existing --verbose

kubectl delete -f ../infra-deploy/aks/secret-store.akv.yaml

### Install AKS Provider
# Source: https://github.com/Azure/secrets-store-csi-driver-provider-azure

kubectl delete -f https://raw.githubusercontent.com/Azure/secrets-store-csi-driver-provider-azure/master/deployment/provider-azure-installer.yaml

### Install Secrets CSI Driver
# Source: https://secrets-store-csi-driver.sigs.k8s.io/getting-started/installation.html
csiPrefix="https://raw.githubusercontent.com/kubernetes-sigs/secrets-store-csi-driver/master/"

# If using the driver to sync secrets-store content as Kubernetes Secrets, deploy the additional RBAC permissions required to enable this feature
kubectl delete -f "$csiPrefix""deploy/rbac-secretprovidersyncing.yaml"

kubectl delete -f "$csiPrefix""deploy/secrets-store-csi-driver.yaml"
kubectl delete -f "$csiPrefix""deploy/secrets-store.csi.x-k8s.io_secretproviderclasspodstatuses.yaml"
kubectl delete -f "$csiPrefix""deploy/secrets-store.csi.x-k8s.io_secretproviderclasses.yaml"
kubectl delete -f "$csiPrefix""deploy/csidriver.yaml"
kubectl delete -f "$csiPrefix""deploy/rbac-secretproviderclass.yaml"


# Validate - should see csi-secrets-store running on each node
#kubectl get pods -l app=csi-secrets-store -n kube-system

 # Validate
#kubectl get pods -l app=csi-secrets-store-provider-azure

### Install SecretProviderClass
# Source: https://azure.github.io/secrets-store-csi-driver-provider-azure/getting-started/usage/

