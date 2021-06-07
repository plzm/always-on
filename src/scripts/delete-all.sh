#!/bin/bash

az group delete -g always-on-eastus2 --yes
az group delete -g always-on-westus2 --yes
az group delete -g always-on-global --yes
