@description('Parent Cognitive Services account name')
param accountName string

@description('Array of model deployments')
param modelDeployments array = []

resource account 'Microsoft.CognitiveServices/accounts@2024-10-01' existing = {
  name: accountName
}

@batchSize(1)
resource deployments 'Microsoft.CognitiveServices/accounts/deployments@2024-10-01' = [for d in modelDeployments: {
  name: '${account.name}/${d.name}'
  properties: {
    model: {
      format: d.model.format
      name: d.model.name
      version: d.model.version
    }
    sku: {
      name: d.sku.name
      capacity: int(d.capacity)
    }
    raiPolicyName: empty(d.raiPolicyName) ? null : d.raiPolicyName
  }
}]
