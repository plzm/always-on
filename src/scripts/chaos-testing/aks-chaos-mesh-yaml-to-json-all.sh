#!/bin/bash

path=$1

for yamlFile in $(ls $path*.yaml)
do
  jsonFile=${yamlFile/yaml/json}

  ./aks-chaos-mesh-yaml-to-json.sh $yamlFile $jsonFile
done
