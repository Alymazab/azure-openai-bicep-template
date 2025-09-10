@description('Azure region for the Cognitive Services account')
param location string = resourceGroup().location

@description('Explicit account name. If empty, a unique name will be generated from namePrefix.')
@minLength(0)
param accountName string = ''

@description('Name prefix used to derive accountName when accountName is empty')
@minLength(3)
param namePrefix string = 'aiacct'

@description('SKU name for Cognitive Services account')
@allowed([ 'S0' 'S1' ])
param skuName string = 'S0'

@description('Account kind')
@allowed([ 'AIServices' 'CognitiveServices' ])
param kind string = 'AIServices'

@description('Enable or disable public network access')
@allowed([ 'Enabled' 'Disabled' ])
param publicNetworkAccess string = 'Enabled'

@description('Disable local auth (keys); enforce Azure AD auth only')
param disableLocalAuth bool = true

@description('Tags to apply to resources')
param tags object = {}

var acctName = empty(accountName) ? toLower('${namePrefix}${uniqueString(resourceGroup().id)}') : accountName

resource account 'Microsoft.CognitiveServices/accounts@2024-10-01' = {
  name: acctName
  location: location
  kind: kind
  sku: {
    name: skuName
  }
  identity: {
    type: 'SystemAssigned'
  }
  tags: tags
  properties: {
    publicNetworkAccess: publicNetworkAccess
    disableLocalAuth: disableLocalAuth
  }
}

@description('Outputs the account resource id and endpoint')
output accountId string = account.id
output accountName string = account.name
output endpoint string = account.properties.endpoint
