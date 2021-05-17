#!/bin/bash

subscriptionId="$(az account show -o tsv --query 'id')"
location="eastus"
resourceGroup="always-on-""$location"
clusterName="pz-ao-""$location"

#az aks get-credentials --subscription "$subscriptionId" -g "$resourceGroup" -n "$clusterName" --overwrite-existing --verbose


### Install Secrets CSI Driver
# Source: https://secrets-store-csi-driver.sigs.k8s.io/getting-started/installation.html
# kubectl apply -f "https://raw.githubusercontent.com/kubernetes-sigs/secrets-store-csi-driver/master/deploy/rbac-secretproviderclass.yaml"
kubectl apply -f ../infra-deploy/aks/rbac-secretproviderclass.yaml

#kubectl apply -f "https://raw.githubusercontent.com/kubernetes-sigs/secrets-store-csi-driver/master/deploy/csidriver.yaml" # Outdated API Version
kubectl apply -f ../infra-deploy/aks/csidriver.yaml

# kubectl apply -f "https://raw.githubusercontent.com/kubernetes-sigs/secrets-store-csi-driver/master/deploy/secrets-store.csi.x-k8s.io_secretproviderclasses.yaml"
kubectl apply -f ../infra-deploy/aks/secrets-store.csi.x-k8s.io_secretproviderclasses.yaml

# kubectl apply -f "https://raw.githubusercontent.com/kubernetes-sigs/secrets-store-csi-driver/master/deploy/secrets-store.csi.x-k8s.io_secretproviderclasspodstatuses.yaml"
kubectl apply -f ../infra-deploy/aks/secrets-store.csi.x-k8s.io_secretproviderclasspodstatuses.yaml

# kubectl apply -f "https://raw.githubusercontent.com/kubernetes-sigs/secrets-store-csi-driver/master/deploy/secrets-store-csi-driver.yaml"
kubectl apply -f ../infra-deploy/aks/secrets-store-csi-driver.yaml

# kubectl apply -f "https://raw.githubusercontent.com/kubernetes-sigs/secrets-store-csi-driver/master/deploy/rbac-secretprovidersyncing.yaml"
kubectl apply -f ../infra-deploy/aks/rbac-secretprovidersyncing.yaml

# Validate - should see csi-secrets-store running on each node
#kubectl get pods -l app=csi-secrets-store -A


### Install AKS Provider
# Source: https://github.com/Azure/secrets-store-csi-driver-provider-azure

# kubectl apply -f https://raw.githubusercontent.com/Azure/secrets-store-csi-driver-provider-azure/master/deployment/provider-azure-installer.yaml
kubectl apply -f ../infra-deploy/aks/provider-azure-installer.yaml

 # Validate
#kubectl get pods -l app=csi-secrets-store-provider-azure


# DO NOT DO THE STUFF ENCLOSED IN THIS BLOCK - LEFT HERE FOR REFERENCE
# Configure AAD Pod Identity to access AKV
### https://docs.microsoft.com/en-us/azure/aks/developer-best-practices-pod-security#use-azure-key-vault-with-secrets-store-csi-driver
### The following is NOT!!!! NEEDED!!!! when you use az aks command as in infra.deploy.region.yml. In fact, if you run the following three deployments in addition to az aks --enable-pod-identity, you will BREAK your cluster.
### Source: https://azure.github.io/secrets-store-csi-driver-provider-azure/configurations/identity-access-modes/pod-identity-mode/
####kubectl apply -f https://raw.githubusercontent.com/Azure/aad-pod-identity/master/deploy/infra/deployment-rbac.yaml
###kubectl apply -f ../infra-deploy/aks/deployment-rbac.yaml
###kubectl create -f ../infra-deploy/aks/aadpodidentity.yaml
###kubectl create -f ../infra-deploy/aks/aadpodidentitybinding.yaml
# END OF THE DO NOT DO THIS BLOCK :)


### Install SecretProviderClass - custpmized for our secrets
# Source: https://azure.github.io/secrets-store-csi-driver-provider-azure/getting-started/usage/

kubectl apply -f ../infra-deploy/aks/secretprovider.ao.akv.yaml


# Now deploy your app, shell to a pod and check for /mnt/secrets-store and if you synced to K8s secrets and from there to env vars, e.g. echo $VARNAME
