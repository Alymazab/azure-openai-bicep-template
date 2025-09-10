#!/usr/bin/env bash
set -euo pipefail
usage() { echo "Usage: $0 -g <resource-group> -p <parameters-file> [-s <subscription-id>]"; exit 1; }
RG=""; SUB=""; PARAMS="parameters/parameters.json"
while getopts ":g:p:s:" opt; do
  case $opt in
    g) RG="$OPTARG" ;;
    p) PARAMS="$OPTARG" ;;
    s) SUB="$OPTARG" ;;
    *) usage ;;
  esac
done
[[ -z "$RG" ]] && usage
if [[ -n "${SUB:-}" ]]; then
  az account set --subscription "$SUB"
fi
echo "Deploying to resource group: $RG with params: $PARAMS"
az deployment group create       --resource-group "$RG"       --template-file templates/azure-deploy.bicep       --parameters @"$PARAMS"
