#!/bin/bash

subscriptionId="$(az account show -o tsv --query 'id')"
resourceGroup="always-on-eastus"
location="eastus"

az deployment group create --subscription "$subscriptionId" -n "AKS-NSG" --verbose \
	-g "$resourceGroup" --template-file "../templates/aks.nsg.json" \
	--parameters \
	location="$location" nsgName="app-""$location" nsgRuleInbound100Src="75.68.47.183/32"
