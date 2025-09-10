@description('Optional: Exact account name. Leave empty to auto-generate from namePrefix + uniqueString(resourceGroup().id).')
param accountName string = ''
@description('Prefix used if accountName is empty.')
param namePrefix string = 'aoai'
@description('Deployment location; defaults to the resource group location.')
param location string = resourceGroup().location
@description('Account kind. Use OpenAI for Azure OpenAI; AIServices for multi-service Cognitive Services.')
@allowed([ 'OpenAI', 'AIServices' ])
param kind string = 'OpenAI'
@description('SKU for the Cognitive Services account.')
param skuName string = 'S0'
@description('Enable or Disable public network access. Default Enabled so the template works without VNet.')
@allowed([ 'Enabled', 'Disabled' ])
param publicNetworkAccess string = 'Enabled'
@description('Disable local keys; prefer AAD auth.')
param disableLocalAuth bool = true
@description('Resource tags.')
param tags object = {
  project: 'azure-ai-arm-sample'
  environment: 'dev'
}

var computedName = accountName != '' ? accountName : toLower('${namePrefix}${uniqueString(resourceGroup().id)}')

resource account 'Microsoft.CognitiveServices/accounts@2023-05-01' = {
  name: computedName
  location: location
  kind: kind
  sku: {
    name: skuName
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    publicNetworkAccess: publicNetworkAccess
    disableLocalAuth: disableLocalAuth
  }
  tags: tags
}

output name string = account.name
output endpoint string = account.properties.endpoint
output resourceId string = account.id
