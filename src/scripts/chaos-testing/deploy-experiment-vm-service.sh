#!/bin/bash

subscriptionId="$(az account show -o tsv --query 'id')"
resourceGroup="test-chaos"
location="eastus2euap"

templatePath="../templates/experiment.vm.service.json"

experimentName="chaos01"

vmId1="/subscriptions/e61e4c75-268b-4c94-ad48-237aa3231481/resourceGroups/always-on-ops/providers/Microsoft.Compute/virtualMachines/pz-ao-ops-1"
vmId2="/subscriptions/e61e4c75-268b-4c94-ad48-237aa3231481/resourceGroups/always-on-ops/providers/Microsoft.Compute/virtualMachines/pz-ao-ops-2"

az deployment group create --subscription "$subscriptionId" -n "Experiment-VM" --verbose \
	-g "$resourceGroup" --template-file "$templatePath" \
	--parameters \
	location="$location" experimentName="$experimentName" \
  restartWhenComplete="true" skipShutdown="true" \
  targetResourceIds="$vmId1"",""$vmId2"
