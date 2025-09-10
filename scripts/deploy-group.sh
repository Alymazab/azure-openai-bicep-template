#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <resource-group> <parameters-file> [--what-if]"
  exit 1
fi

RG="$1"
PARAMS="$2"
WHATIF="${3:-}"

TEMPLATE="templates/azure-deploy.bicep"

if [[ "$WHATIF" == "--what-if" ]]; then
  az deployment group what-if -g "$RG" -f "$TEMPLATE" -p "@$PARAMS"
else
  az deployment group create -g "$RG" -f "$TEMPLATE" -p "@$PARAMS"
fi
