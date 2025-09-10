@description('Location for the Private Endpoint (should match the VNet region).')
param location string
@description('Target Cognitive Services account resource ID.')
param targetAccountResourceId string
@description('Subnet resource ID where the Private Endpoint NIC will be deployed.')
param subnetResourceId string
@description('Optional: Manual approval description.')
param manualConnectionMessage string = 'Requesting Private Endpoint connection.'
@description('Tags for the Private Endpoint.')
param tags object = {}

// NOTE: This module does not create Private DNS zones. Link them separately if needed.
// For Cognitive Services the groupId is typically "account".
var peName = 'pe-${uniqueString(targetAccountResourceId, subnetResourceId)}'

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2023-09-01' = {
  name: peName
  location: location
  properties: {
    subnet: {
      id: subnetResourceId
    }
    privateLinkServiceConnections: [
      {
        name: 'cogsvc'
        properties: {
          privateLinkServiceId: targetAccountResourceId
          groupIds: [
            'account'
          ]
          requestMessage: manualConnectionMessage
        }
      }
    ]
  }
  tags: tags
}

output privateEndpointId string = privateEndpoint.id
