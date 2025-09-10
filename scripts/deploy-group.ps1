param(
  [Parameter(Mandatory=$true)][string]$ResourceGroup,
  [Parameter(Mandatory=$true)][string]$ParametersFile,
  [switch]$WhatIf
)

$Template = "templates/azure-deploy.bicep"

if ($WhatIf) {
  az deployment group what-if -g $ResourceGroup -f $Template -p @$ParametersFile
} else {
  az deployment group create -g $ResourceGroup -f $Template -p @$ParametersFile
}
