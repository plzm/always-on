#!/bin/bash

# Install YQ first if needed - check ./aks-install-tools.sh

inputPath=$1
outputPath=$2

# Transform YAML to minified JSON - per Chaos PG, only the -spec node
raw="$(yq eval '.spec' ""$inputPath"" --tojson --indent 0)"

# Escape the JSON
cooked=${raw//\"/\\\"}

# Write the output
echo $cooked > $outputPath
