#!/bin/bash

prefix="pz-ao"
suffix="34"

subscriptionId="$(az account show -o tsv --query 'id')"
location="eastus2"

resourceGroup="always-on-""$location"

networkWatcherName="NetworkWatcher_""$location"

az deployment group create --subscription "$subscriptionId" -n "network-watcher" --verbose \
	-g "$resourceGroup" --template-file "../infra-deploy/templates/net.network-watcher.json" \
	--parameters \
	location="$location" networkWatcherName="$networkWatcherName"
