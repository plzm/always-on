#!/bin/bash

# Chaos Mesh needs to be installed on AKS cluster before Chaos Studio Experiments can be run against it
# Go to Chaos Mesh and determine the current version for below
# https://chaos-mesh.org/docs/

# ##################################################
# Variables - modify as needed
subscriptionId="$(az account show -o tsv --query 'id')"
resourceGroup="always-on-eastus2"
aksClusterName="pz-ao-eastus2"
installOption="2" # 1 or 2

# Azure CLI extension auto install if needed
az config set extension.use_dynamic_install=yes_without_prompt

# Get kubectl credentials for AKS cluster
az aks get-credentials --subscription $subscriptionId -g $resourceGroup -n $aksClusterName

# ##################################################
# https://chaos-mesh.org/docs/user_guides/installation/#install-chaos-mesh

if [ $installOption -eq "1" ]
then
	# Chaos Mesh install option 1 - easy peasy - this does it all for you and does not require you to have Helm installed locally
	# HOWEVER - if you install this way, and then add components like a DNS service in the Chaos Mesh namespace via Helm, those installs may fail so prefer option #2.

	curl -sSL https://mirrors.chaos-mesh.org/v1.2.2/install.sh | bash

  # Uninstall
	# curl -sSL https://mirrors.chaos-mesh.org/v1.2.2/install.sh | bash -s -- --template | kubectl delete -f -
elif [ $installOption -eq "2" ]
then
	# Chaos Mesh install option 2 - uses helm

	# 1. Install Helm - ref https://helm.sh/docs/intro/install/
	curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash

	# https://chaos-mesh.org/docs/user_guides/installation/#install-by-helm
	# 2. Add chaos mesh helm repo locally
	helm repo add chaos-mesh https://charts.chaos-mesh.org

	# 3. Create Chaos Mesh namespace on AKS cluster
	kubectl create ns chaos-testing

	# 4. Install Chaos Mesh with DNS Server for DNSChaos - Helm v3
	helm upgrade chaos-mesh chaos-mesh/chaos-mesh --namespace=chaos-testing --set chaosDaemon.runtime=containerd --set chaosDaemon.socketPath=/run/containerd/containerd.sock --set dnsServer.create=true --install

fi
# ##################################################

# Verify Chaos Mesh pods are running
kubectl get pods --namespace chaos-testing -l app.kubernetes.io/instance=chaos-mesh
