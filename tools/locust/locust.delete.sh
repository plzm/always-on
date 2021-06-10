#!/bin/bash

subscriptionId="$(az account show -o tsv --query 'id')"
resourceGroup="always-on-tests"

az deployment group delete --subscription "$subscriptionId" -g "$resourceGroup" -n "locust" --verbose