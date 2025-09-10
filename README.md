# Azure Cognitive Services (Azure AI) – Bicep Starter

Provision a **Cognitive Services** account (default kind: `AIServices`, SKU: `S0`) with clean defaults, optional **model deployments** (for Azure OpenAI) and optional **Private DNS** add‑on for private networking scenarios.

> ✅ Base deployment works out‑of‑the‑box with public network access.  
> 🧩 Optional modules can be turned on via parameters.

## What gets created
- `Microsoft.CognitiveServices/accounts` with managed identity and tags.
- (Optional) `Microsoft.CognitiveServices/accounts/deployments` for Azure OpenAI model deployments (off by default).
- (Optional) `Microsoft.Network/privateDnsZones` + VNet link for `privatelink.cognitiveservices.azure.com`.

## Repo layout
```
templates/
  azure-deploy.bicep           # Root compose: account + (optional) model deployments
  modules/
    account.bicep              # Cognitive Services account
    openai-deployments.bicep   # Optional model deployments (loop over array)
addons/
  private-dns/main.bicep       # Optional Private DNS zone + VNet link
parameters/
  parameters.dev.json
  parameters.staging.json
  parameters.prod.json
scripts/
  deploy-group.sh
  deploy-group.ps1
.github/workflows/
  validate-whatif.yml
bicepconfig.json
LICENSE
```

## Prerequisites
- Azure subscription with `Microsoft.CognitiveServices` + `Microsoft.Network` providers registered.
- If using **Azure OpenAI deployments**, ensure your subscription is **approved** and the **region** supports the models you choose.
- `az` CLI logged in and set to the target subscription:  
  ```bash
  az login
  az account set --subscription "<SUBSCRIPTION_ID>"
  ```

## Quick start
Deploy to a resource group:
```bash
# Create a resource group once
az group create -n my-rg -l eastus

# What-if (recommended)
./scripts/deploy-group.sh my-rg parameters/parameters.dev.json --what-if

# Deploy
./scripts/deploy-group.sh my-rg parameters/parameters.dev.json
```

PowerShell:
```powershell
./scripts/deploy-group.ps1 -ResourceGroup my-rg -ParametersFile parameters/parameters.dev.json -WhatIf
./scripts/deploy-group.ps1 -ResourceGroup my-rg -ParametersFile parameters/parameters.dev.json
```

## Parameters
Key parameters exposed by `templates/azure-deploy.bicep`:

- `location`: Azure region (defaults to resource group location)
- `accountName`: If empty, `namePrefix` is used to derive a unique name
- `namePrefix`: Prefix for generated names
- `skuName`: Defaults to `S0`
- `publicNetworkAccess`: `Enabled|Disabled`
- `disableLocalAuth`: `true|false` (defaults `true`)
- `tags`: object
- `deployModels`: `true|false` (defaults `false`)
- `modelDeployments`: array of objects:
  ```json
  {
    "name": "gpt-4o-mini",
    "model": { "format": "OpenAI", "name": "gpt-4o-mini", "version": "2024-08-06" },
    "sku": { "name": "Standard" },
    "capacity": 1
  }
  ```
- `enablePrivateDns`: `true|false` (defaults `false`)
- `vnetId`, `vnetLinkName`: Used only when `enablePrivateDns` is true, to create a VNet link to the private DNS zone.

> ℹ️ **Note:** Model deployment schema varies by API version and region. This template uses commonly working fields and keeps the feature **off by default** so the base deployment always succeeds.

## CI: What-if on PRs
The included GitHub Actions workflow performs `what-if` against all parameter files. It expects OIDC federated credentials configured on your repo:
- Create a federated credential in Azure AD for your repo, granting the identity **Contributor** on the resource group.
- Add repository variables: `AZURE_SUBSCRIPTION_ID`, `AZURE_RESOURCE_GROUP`.

## Private networking (optional)
If you disable public network access on the account, pair it with:
- Private Endpoint (not included here) to bring traffic via your VNet.
- Private DNS zone: `privatelink.cognitiveservices.azure.com` with VNet link (provided in `addons/private-dns`).

> This repo ships a **Private DNS** add‑on. You can extend with your own Private Endpoint module and wire it in a separate deployment if needed.

## Troubleshooting
- **Region/model mismatch**: If a model isn't available in your chosen region, either disable `deployModels` or pick a region/model pair that is supported.
- **Insufficient quota/approval**: Request Azure OpenAI access and quotas for the region.
- **Policy blocks**: Org policies may block public network access or specific SKUs. Use the `what-if` output to identify denials.

## License
MIT
