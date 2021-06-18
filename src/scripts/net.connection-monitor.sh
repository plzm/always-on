#!/bin/bash

prefix="pz-ao"
suffix="34"

subscriptionId="$(az account show -o tsv --query 'id')"
location="eastus2"

resourceGroup="NetworkWatcherRG"

networkWatcherName="NetworkWatcher_""$location"

az deployment group create --subscription "$subscriptionId" -n "network-watcher" --verbose --debug \
	-g "$resourceGroup" --template-file "../infra-deploy/templates/net.connection-monitor.json" \
	--parameters \
	location="$location" networkWatcherName="NetworkWatcher_""$location" connectionMonitorName="cm1"
