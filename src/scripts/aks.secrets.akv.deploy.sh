#!/bin/bash

subscriptionId="$(az account show -o tsv --query 'id')"
location="eastus"
resourceGroup="always-on-""$location"
clusterName="pz-ao-""$location"

az aks get-credentials --subscription "$subscriptionId" -g "$resourceGroup" -n "$clusterName" --overwrite-existing --verbose


### Install Secrets CSI Driver
# Source: https://secrets-store-csi-driver.sigs.k8s.io/getting-started/installation.html
csiPrefix="https://raw.githubusercontent.com/kubernetes-sigs/secrets-store-csi-driver/master/"

kubectl apply -f "https://raw.githubusercontent.com/kubernetes-sigs/secrets-store-csi-driver/master/deploy/rbac-secretproviderclass.yaml"

#kubectl apply -f "https://raw.githubusercontent.com/kubernetes-sigs/secrets-store-csi-driver/master/deploy/csidriver.yaml" # Outdated API Version
kubectl apply -f ../infra-deploy/aks/csidriver.yaml

kubectl apply -f "https://raw.githubusercontent.com/kubernetes-sigs/secrets-store-csi-driver/master/deploy/secrets-store.csi.x-k8s.io_secretproviderclasses.yaml"
kubectl apply -f "https://raw.githubusercontent.com/kubernetes-sigs/secrets-store-csi-driver/master/deploy/secrets-store.csi.x-k8s.io_secretproviderclasspodstatuses.yaml"
kubectl apply -f "https://raw.githubusercontent.com/kubernetes-sigs/secrets-store-csi-driver/master/deploy/secrets-store-csi-driver.yaml"

# If using the driver to sync secrets-store content as Kubernetes Secrets, deploy the additional RBAC permissions required to enable this feature
#kubectl apply -f "https://raw.githubusercontent.com/kubernetes-sigs/secrets-store-csi-driver/master/deploy/rbac-secretprovidersyncing.yaml"

# Validate - should see csi-secrets-store running on each node
kubectl get pods -l app=csi-secrets-store -n kube-system


### Install AKS Provider
# Source: https://github.com/Azure/secrets-store-csi-driver-provider-azure

kubectl apply -f https://raw.githubusercontent.com/Azure/secrets-store-csi-driver-provider-azure/master/deployment/provider-azure-installer.yaml

 # Validate
kubectl get pods -l app=csi-secrets-store-provider-azure


### Configure AAD Pod Identity to access AKV
# Source: https://azure.github.io/secrets-store-csi-driver-provider-azure/configurations/identity-access-modes/pod-identity-mode/

kubectl apply -f https://raw.githubusercontent.com/Azure/aad-pod-identity/master/deploy/infra/deployment-rbac.yaml

kubectl create -f ../infra-deploy/aks/aadpodidentity.yaml
kubectl create -f ../infra-deploy/aks/aadpodidentitybinding.yaml


### Install SecretProviderClass
# Source: https://azure.github.io/secrets-store-csi-driver-provider-azure/getting-started/usage/

kubectl apply -f ../infra-deploy/aks/secret-provider-class.akv.yaml
