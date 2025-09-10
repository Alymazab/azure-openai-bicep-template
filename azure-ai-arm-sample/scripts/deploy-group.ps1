param(
  [Parameter(Mandatory=$true)][string]$ResourceGroup,
  [Parameter(Mandatory=$false)][string]$ParametersPath = "parameters/parameters.json",
  [Parameter(Mandatory=$false)][string]$SubscriptionId
)
if ($PSBoundParameters.ContainsKey('SubscriptionId')) {
  az account set --subscription $SubscriptionId | Out-Null
}
Write-Host "Deploying to resource group: $ResourceGroup with params: $ParametersPath"
az deployment group create `
  --resource-group $ResourceGroup `
  --template-file templates/azure-deploy.bicep `
  --parameters @$ParametersPath
