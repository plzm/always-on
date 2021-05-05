#!/bin/bash

# ####################
# Variables

# Regional Stamp - only these should be needed as per-region inputs
location="eastus" # Azure region
prefix="pz-ao" # Used in resource naming
infix="eus" # Used in resource naming

# General
subscriptionId="$(az account show -o tsv --query 'id')"

# Global
resourceGroupGlobal="always-on-global"
logAnalyticsWorkspaceName="$prefix"
ddosProtectionPlanName="$prefix"

# Deployment/Region Specific
resourceGroup="always-on-""$infix"


# Dynamic - Resource IDs etc.
logAnalyticsWorkspaceId="$(az monitor log-analytics workspace show --subscription ${{secrets.AZURE_SUBSCRIPTION_ID}} -g ${{env.AZURE_RESOURCE_GROUP}} -n ${{env.LA_WORKSPACE_NAME}} -o tsv --query 'id')"
uamiId="$(az identity show --subscription ${{secrets.AZURE_SUBSCRIPTION_ID}} -g ${{env.AZURE_RESOURCE_GROUP}} -n ${{env.UAMI_NAME}} -o tsv --query 'id')"
uamiPrincipalId="$(az identity show --subscription ${{secrets.AZURE_SUBSCRIPTION_ID}} -g ${{env.AZURE_RESOURCE_GROUP}} -n ${{env.UAMI_NAME}} -o tsv --query 'principalId')"


# Dev/Test
myIp="75.68.47.183/32"

# ####################

# ####################
### Operations

## Install CLI extensions
az extension add --name aks-preview

##Deploy RG
az group create --subscription "$subscriptionId" --location "$location" --name "$resourceGroup" --verbose

## Deploy NSGs and diagnostics
# APIM
az deployment group create --subscription "$subscriptionId" -n "NSG-APIM" --verbose \
	-g "$resourceGroup" --template-file "../templates/apim.nsg.json" \
	--parameters location="$location" nsgName=${{env.APIM_NSG_NAME}} nsgRuleInbound100Src="$myIp" allowTrafficOnlyFromFrontDoor=${{env.APIM_SUBNET_FRONTDOOR_INBOUND_ONLY}}

az deployment group create --subscription "$subscriptionId" -n "NSG-APIM-Diag" --verbose \
	-g "$resourceGroup" --template-file "../templates/net.nsg.diagnostics.json" \
	--parameters nsgName=${{env.APIM_NSG_NAME}} logAnalyticsWorkspaceResourceId="${{env.LA_WORKSPACE_ID}}"

# App
az deployment group create --subscription "$subscriptionId" -n "NSG-App" --verbose \
	-g "$resourceGroup" --template-file "../templates/net.nsg.json" \
	--parameters location="$location" nsgName=${{env.APP_NSG_NAME}} nsgRuleInbound100Src="$myIp"

az deployment group create --subscription "$subscriptionId" -n "NSG-App-Diag" --verbose \
	-g "$resourceGroup" --template-file "../templates/net.nsg.diagnostics.json" \
	--parameters nsgName=${{env.APP_NSG_NAME}} logAnalyticsWorkspaceResourceId="${{env.LA_WORKSPACE_ID}}"

## Deploy VNet, diagnostics, and subnets
# VNet
az deployment group create --subscription "$subscriptionId" -n "VNet" --verbose \
	-g "$resourceGroup" --template-file "../templates/net.vnet.json" \
	--parameters location=${{env.AZURE_LOCATION}} vnetName=${{env.VNET_NAME}} vnetPrefix=${{env.VNET_PREFIX}} enableDdosProtection=${{env.VNET_ENABLE_DDOS}} ddosProtectionPlanResourceGroup=${{env.AZURE_RESOURCE_GROUP}} ddosProtectionPlanName=${{env.DDOS_PLAN_NAME}}

az deployment group create --subscription "$subscriptionId" -n "VNet-Diag" --verbose \
	-g "$resourceGroup" --template-file "../templates/net.vnet.diagnostics.json" \
	--parameters vnetName=${{env.VNET_NAME}} logAnalyticsWorkspaceResourceId="${{env.LA_WORKSPACE_ID}}"

az deployment group create --subscription "$subscriptionId" -n "Subnet-APIM" --verbose \
	-g "$resourceGroup" --template-file "../templates/net.vnet.subnet.json" \
	--parameters vnetName=${{env.VNET_NAME}} subnetName=${{env.APIM_SUBNET_NAME}} subnetPrefix=${{env.APIM_SUBNET_PREFIX}} nsgResourceGroup=${{env.AZURE_RESOURCE_GROUP}} nsgName=${{env.APIM_NSG_NAME}}

az deployment group create --subscription "$subscriptionId" -n "Subnet-AppGW" --verbose \
	-g "$resourceGroup" --template-file "../templates/net.vnet.subnet.json" \
	--parameters vnetName=${{env.VNET_NAME}} subnetName=${{env.APPGW_SUBNET_NAME}} subnetPrefix=${{env.APPGW_SUBNET_PREFIX}}

az deployment group create --subscription "$subscriptionId" -n "Subnet-App" --verbose \
	-g "$resourceGroup" --template-file "../templates/net.vnet.subnet.json" \
	--parameters vnetName=${{env.VNET_NAME}} subnetName=${{env.APP_SUBNET_NAME}} subnetPrefix=${{env.APP_SUBNET_PREFIX}} nsgResourceGroup=${{env.AZURE_RESOURCE_GROUP}} nsgName=${{env.APP_NSG_NAME}} serviceEndpoints=${{env.APP_SUBNET_SERVICE_ENDPOINTS}}

# Get app subnet resource ID for later operations
appSubnetId="$(az network vnet subnet show --subscription ${{secrets.AZURE_SUBSCRIPTION_ID}} -g ${{env.AZURE_RESOURCE_GROUP}} --vnet-name ${{env.VNET_NAME}} -n ${{env.APP_SUBNET_NAME}} -o tsv --query 'id')"

# Deploy UAMI Network Contributor role assignment to VNet for kubenet config
az deployment group create --subscription "$subscriptionId" -n "VNet" --verbose \
	-g "$resourceGroup" --template-file "../templates/authorization.role-assignment.json" \
	--parameters roleDefinitionId="${{env.RBAC_ROLE_ID_NETWORK_CONTRIBUTOR}}" principalId="${{env.UAMI_PRINCIPAL_ID}}" resourceType="Microsoft.Network/virtualNetworks" resourceName="${{env.VNET_NAME}}"

