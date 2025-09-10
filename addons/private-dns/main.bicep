@description('Create Private DNS zone for Cognitive Services and link it to a VNet')
param location string = resourceGroup().location
param zoneName string = 'privatelink.cognitiveservices.azure.com'
param vnetId string
param vnetLinkName string = 'cogsvc-dnslink'

resource dnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: zoneName
  location: 'global'
}

resource vnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${dnsZone.name}/${vnetLinkName}'
  location: 'global'
  properties: {
    virtualNetwork: {
      id: vnetId
    }
    registrationEnabled: false
  }
}

output zoneId string = dnsZone.id
