targetScope = 'resourceGroup'

@description('Azure region')
param location string = resourceGroup().location

@description('Explicit account name, or leave empty to generate from namePrefix')
param accountName string = ''

@description('Name prefix for generated names')
param namePrefix string = 'aiacct'

@description('SKU name')
@allowed([ 'S0' 'S1' ])
param skuName string = 'S0'

@description('Account kind')
@allowed([ 'AIServices' 'CognitiveServices' ])
param kind string = 'AIServices'

@description('Public network access')
@allowed([ 'Enabled' 'Disabled' ])
param publicNetworkAccess string = 'Enabled'

@description('Disable local auth (keys)')
param disableLocalAuth bool = true

@description('Resource tags')
param tags object = {}

@description('Whether to deploy Azure OpenAI model deployments')
param deployModels bool = false

@description('Array of model deployments')
param modelDeployments array = []

@description('Enable Private DNS zone + VNet link (for private networking)')
param enablePrivateDns bool = false

@description('VNet resource ID (required when enablePrivateDns is true)')
@metadata({
  description: 'Example: /subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.Network/virtualNetworks/<vnet>'
})
param vnetId string = ''

@description('Name of the VNet link to create')
param vnetLinkName string = 'cogsvc-dnslink'

module account './modules/account.bicep' = {
  name: 'account'
  params: {
    location: location
    accountName: accountName
    namePrefix: namePrefix
    skuName: skuName
    kind: kind
    publicNetworkAccess: publicNetworkAccess
    disableLocalAuth: disableLocalAuth
    tags: tags
  }
}

module openaiDeployments './modules/openai-deployments.bicep' = if (deployModels && length(modelDeployments) > 0) {
  name: 'openai-deployments'
  params: {
    accountName: account.outputs.accountName
    modelDeployments: modelDeployments
  }
}

module privateDns '../addons/private-dns/main.bicep' = if (enablePrivateDns) {
  name: 'private-dns'
  params: {
    vnetId: vnetId
    vnetLinkName: vnetLinkName
  }
}

output accountId string = account.outputs.accountId
output endpoint string = account.outputs.endpoint
