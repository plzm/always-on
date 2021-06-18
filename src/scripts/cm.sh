#!/bin/bash

nsgRuleInbound100Src="75.68.47.183"

PREFIX="pz-ao"
location="eastus2"

subscriptionId="$(az account show -o tsv --query 'id')"
resourceGroupOps="always-on-ops"

nsgName="netops-""$location"
vnetName="$PREFIX""-""$location""-netops"
vnetPrefix="10.0.0.0/16"
subnetName="cm"
subnetPrefix="10.0.1.0/24"

vmName="$PREFIX""-netops"

vmPublicIpName="$vmName""-pip"
vmPublicIpType="Dynamic"
vmPublicIpSku="Basic"

vmNicName="$vmName""-nic"

vmPublisher="Canonical"
vmOffer="UbuntuServer"
vmSku="19.04"
vmVersion="latest"

vmSize="Standard_D4s_v3"
provisionVmAgent="true"

enableAcceleratedNetworking=false
privateIpAllocationMethod="Dynamic"
ipConfigName="ipConfig1"

vmTimeZone="Eastern Standard Time"
vmAdminUsername="pelazem"
vmAdminUserSshPublicKey="ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAg+4FzJlW5nqUa798vqYGanooy5HvSyG8sS6KjPu0sJAf+fkP6qpHY8k1m2/Z9Mahv2Y0moZDiVRHFMGH8qZU+AlYdvjGyjxHcIzDnsmHcV2ONxEiop4KMJLwecHUyf95ogicB1QYfK/6Q8pL9sDlXt8bAcSh6iP0u2d1g9QJaON2aniOpzn68xnKdGT974i7JQLN0SjaPiidZ2prc0cSIMBN26tGV7at2Jh5FIb1Jv8fXHnZebD/vgLilfCqLbuQjTpDVCskZ+OUAyvlBko3gBjRgd/jBprMqCpFLoGUBVkSSR0IkjTj2A6n2XyCyYRMFYrVrjwyU8I+IvO/6zJSEw== pelazem"

osDiskStorageType="Premium_LRS"
osDiskSizeInGB=64
dataDiskStorageType="Premium_LRS"
dataDiskCount=0
dataDiskSizeInGB=32

vmAutoShutdownTime="1800"
enableAutoShutdownNotification="Disabled"
autoShutdownNotificationWebhookURL="" # Provide if set enableAutoShutdownNotification="Enabled"
autoShutdownNotificationMinutesBefore=15
# ==========

echo "Create Resource Group"
az group create --subscription "$subscriptionId" -n "$resourceGroupOps" -l "$location" --verbose

echo "Create NSG"
az deployment group create --subscription "$subscriptionId" -n "NSG-""$location" --verbose \
	-g "$resourceGroupOps" --template-file "../infra-deploy/templates/net.nsg.json" \
	--parameters location="$location" nsgName="$nsgName" nsgRuleInbound100Src="$nsgRuleInbound100Src"
#
echo "Create VNet"
az deployment group create --subscription "$subscriptionId" -n "VNet-""$location" --verbose \
	-g "$resourceGroupOps" --template-file "../infra-deploy/templates/net.vnet.json" \
	--parameters \
	location="$location" \
	vnetName="$vnetName" \
	vnetPrefix="$vnetPrefix" \
	enableDdosProtection="false" \
	enableVmProtection="false"
#
echo "Create Subnet"
az deployment group create --subscription "$subscriptionId" -n "VNet-Subnet-""$location" --verbose \
	-g "$resourceGroupOps" --template-file "../infra-deploy/templates/net.vnet.subnet.json" \
	--parameters \
	vnetName="$vnetName" \
	subnetName="$subnetName" \
	subnetPrefix="$subnetPrefix" \
	nsgResourceGroup="$resourceGroupOps" \
	nsgName="$nsgName" \
	serviceEndpoints="" \
	privateEndpointNetworkPolicies="Enabled" \
	privateLinkServiceNetworkPolicies="Enabled"
#
echo "Deploy VM Public IP"
az deployment group create --subscription "$subscriptionId" -n "VM-PIP-""$location" --verbose \
	-g "$resourceGroupOps" --template-file "../infra-deploy/templates/net.public-ip.json" \
	--parameters \
	location="$location" \
	publicIpName="$vmPublicIpName" \
	publicIpType="$vmPublicIpType" \
	publicIpSku="$vmPublicIpSku" \
	domainNameLabel="$vmName"
#
echo "Deploy VM NIC"
az deployment group create --subscription "$subscriptionId" -n "VM-NIC-""$location" --verbose \
	-g "$resourceGroupOps" --template-file "../infra-deploy/templates/net.network-interface.json" \
	--parameters \
	location="$location" \
	networkInterfaceName="$vmNicName" \
	vnetResourceGroup="$resourceGroupOps" \
	vnetName="$vnetName" \
	subnetName="$subnetName" \
	enableAcceleratedNetworking="$enableAcceleratedNetworking" \
	privateIpAllocationMethod="$privateIpAllocationMethod" \
	publicIpResourceGroup="$resourceGroupOps" \
	publicIpName="$vmPublicIpName" \
	ipConfigName="$ipConfigName"
#
echo "Deploy VM"
az deployment group create --subscription "$subscriptionId" -n "VM-""$location" --verbose \
	-g "$resourceGroupOps" --template-file "../infra-deploy/templates/vm.json" \
	--parameters \
	location="$location" \
	virtualMachineName="$vmName" \
	virtualMachineSize="$vmSize" \
	publisher="$vmPublisher" \
	offer="$vmOffer" \
	sku="$vmSku" \
	version="$vmVersion" \
	provisionVmAgent="$provisionVmAgent" \
	adminUsername="$vmAdminUsername" \
	adminSshPublicKey="$vmAdminUserSshPublicKey" \
	virtualMachineTimeZone="$vmTimeZone" \
	osDiskStorageType="$osDiskStorageType" \
	osDiskSizeInGB="$osDiskSizeInGB" \
	dataDiskStorageType="$dataDiskStorageType" \
	dataDiskCount="$dataDiskCount" \
	dataDiskSizeInGB="$dataDiskSizeInGB" \
	vmAutoShutdownTime="$vmAutoShutdownTime" \
	enableAutoShutdownNotification="$enableAutoShutdownNotification" \
	autoShutdownNotificationWebhookURL="$autoShutdownNotificationWebhookURL" \
	autoShutdownNotificationMinutesBefore="$autoShutdownNotificationMinutesBefore" \
	resourceGroupNameNetworkInterface="$resourceGroupOps" \
	networkInterfaceName="$vmNicName"
#
echo "Deploy Network Watcher Extension to VM"
az vm extension set -g "$resourceGroupOps" --vm-name "$vmName" --name NetworkWatcherAgentLinux --publisher Microsoft.Azure.NetworkWatcher --version 1.4
