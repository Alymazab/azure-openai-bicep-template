# Azure AI (Cognitive Services / Azure OpenAI) – Bicep Sample

**One-command deploy** of a Cognitive Services account (default **Azure OpenAI**) using Bicep.

## What this does
- Creates a `Microsoft.CognitiveServices/accounts` resource (kind defaults to `OpenAI`)
- Secure defaults: **AAD auth** (local keys disabled), tags, and optional public network lockdown
- Portable parameter files for **dev / staging / prod**
- GitHub Actions workflow to **validate** and **what‑if** all parameter files

> ℹ️ By default, `publicNetworkAccess` is **Enabled** so anyone can deploy this without VNet/DNS. For production, use `parameters.prod.json` which sets it to **Disabled** and add a Private Endpoint + DNS as needed.

---

## Prerequisites
- Azure CLI (`az`) installed and `az login` completed
- A Resource Group (or create one)
- Provider registrations:

```bash
az provider register --namespace Microsoft.CognitiveServices
az provider register --namespace Microsoft.Network
```

If you are using Azure OpenAI, ensure your subscription is **approved** and has quota for your region.

---

## Quickstart (CLI)
```bash
RG=ai-sample-rg
az group create -n $RG -l eastus

# Deploy (dev defaults)
./scripts/deploy-group.sh -g $RG -p parameters/parameters.json

# Or deploy prod-hardened defaults
./scripts/deploy-group.sh -g $RG -p parameters/parameters.prod.json
```

### Template Parameters
| Name | Type | Default | Notes |
|---|---|---|---|
| `accountName` | string | `''` | If empty, a unique name is created from `namePrefix` + `uniqueString(resourceGroup().id)` |
| `namePrefix` | string | `aoai` | Used when `accountName` is empty |
| `location` | string | `resourceGroup().location` | Region for the account |
| `kind` | string | `OpenAI` | `OpenAI` or `AIServices` |
| `skuName` | string | `S0` | SKU for the account |
| `publicNetworkAccess` | string | `Enabled` | `Enabled` or `Disabled` |
| `disableLocalAuth` | bool | `true` | Prefer AAD over access keys |
| `tags` | object | `{ project, environment }` | Custom tags |

### Outputs
- `name` – resource name
- `endpoint` – service endpoint (varies by kind)
- `resourceId` – full ARM ID

---

## Private Endpoint (optional)
A minimal module is available at `addons/private-endpoint/private-endpoint.bicep`.
It **does not** manage Private DNS zones. For Azure OpenAI, link to the zone `privatelink.openai.azure.com`. For other Cognitive Services kinds, use the appropriate zone (e.g., `privatelink.cognitiveservices.azure.com`). Approve the PE connection on the target resource if manual approval is required.

Example invocation (module-level):
```bicep
module pe 'addons/private-endpoint/private-endpoint.bicep' = {
  name: 'pe'
  params: {
    location: resourceGroup().location
    targetAccountResourceId: account.id
    subnetResourceId: '/subscriptions/<subId>/resourceGroups/<rg>/providers/Microsoft.Network/virtualNetworks/<vnet>/subnets/<subnet>'
  }
}
```

---

## GitHub Actions (Validate & What-If)
Add these repository secrets:
- `AZURE_CREDENTIALS` – Service principal JSON (`appId`, `password`, `tenantId`)
- `AZURE_SUBSCRIPTION_ID`
- `AZURE_RESOURCE_GROUP` – Target RG for validation/what-if

The workflow will run validation and what‑if against **every** file in `parameters/*.json`.

---

## Clean up
```bash
az group delete -n <your-rg> --yes --no-wait
```

## License
MIT – see [LICENSE](./LICENSE).


## Improvements in This Version
- Added guidance on optional **model deployments** (e.g., GPT-4o-mini, embeddings).
- Added guidance for **Private DNS add-on** for private endpoint scenarios.
- Clarified **prerequisites**: provider registration, Azure OpenAI approval/quota, RBAC, and regional availability.
- CI workflow notes: using `azure/login` with OIDC, `az bicep install`.
- Parameter usage clarified: account naming and networking differences across environments.

## Optional Model Deployment (future)
You can extend `templates/azure-deploy.bicep` with:
```bicep
resource deployment 'Microsoft.CognitiveServices/accounts/deployments@2023-05-01' = if (deployModels) [for model in modelDeployments: {
  name: model.name
  parent: cognitiveAccount
  properties: {
    model: {
      format: model.format
      name: model.modelName
      version: model.version
    }
    scaleSettings: {
      capacity: model.capacity
    }
  }
}]
```

Parameters example:
```json
"deployModels": { "value": true },
"modelDeployments": {
  "value": [
    { "name": "gpt-4o-mini", "format": "OpenAI", "modelName": "gpt-4o-mini", "version": "2024-08-06", "capacity": 1 }
  ]
}
```

## Private Networking
To use private endpoints:
- Enable `addons/private-endpoint`
- Add a **Private DNS Zone** like `privatelink.cognitiveservices.azure.com` and link it to your VNet.
