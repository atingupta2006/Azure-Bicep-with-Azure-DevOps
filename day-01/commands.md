# Day 1 — Azure Bicep Fundamentals

Notes: [notes.md](notes.md). Replace `XX` (example `u03` → `rg-bicep-u03`, `stb26u03`).  
Labs use `samples/` only.

From the course clone:

```bash
az account show --query name -o tsv
az bicep version
```

---

## Lab 1 — Core Bicep workflow

### Create a Resource Group

```bash
az group create --name rg-bicep-uXX --location eastus
```

### Write a Bicep file to deploy a Storage Account

```bash
code day-01/samples/storage.bicep
code day-01/samples/storage.bicepparam
```

If `code` is not installed, open the files in the editor you have.

```bash
az bicep format --file day-01/samples/storage.bicep
```

### Deploy using Azure CLI

```bash
az deployment group create \
  --resource-group rg-bicep-uXX \
  --template-file day-01/samples/storage.bicep \
  --parameters day-01/samples/storage.bicepparam
```

```bash
az storage account show \
  --name stb26uXX \
  --resource-group rg-bicep-uXX \
  --query "{name:name, sku:sku.name, kind:kind, location:location, tls:minimumTlsVersion, https:enableHttpsTrafficOnly}" \
  -o table
```

```bash
az deployment group show \
  --resource-group rg-bicep-uXX \
  --name storage \
  --query properties.outputs \
  -o json
```

### Modify SKU and redeploy

In `day-01/samples/storage.bicep` change `sku.name` from `Standard_LRS` to `Standard_GRS`. Save.

```bash
az deployment group create \
  --resource-group rg-bicep-uXX \
  --template-file day-01/samples/storage.bicep \
  --parameters day-01/samples/storage.bicepparam
```

```bash
az storage account show \
  --name stb26uXX \
  --resource-group rg-bicep-uXX \
  --query sku.name \
  -o tsv
```

### Observe idempotent behavior

No file change.

```bash
az deployment group create \
  --resource-group rg-bicep-uXX \
  --template-file day-01/samples/storage.bicep \
  --parameters day-01/samples/storage.bicepparam
```

### Cleanup resources

Keep the resource group. Delete the storage account:

```bash
az storage account delete \
  --name stb26uXX \
  --resource-group rg-bicep-uXX \
  --yes
```

```bash
az group show --name rg-bicep-uXX --query name -o tsv
```

Set `sku.name` in `day-01/samples/storage.bicep` back to `Standard_LRS`. Save.

---

## Lab 2 — Validation and errors

### Intentionally introduce syntax errors

In `day-01/samples/storage.bicep`, on the storage resource, change `location: location` to `location location`. Save.

### Observe linter warnings

```bash
az bicep build --file day-01/samples/storage.bicep
```

```bash
az bicep lint --file day-01/samples/storage.bicep
```

### Fix deployment errors

Restore `location: location`. Save.

```bash
az bicep format --file day-01/samples/storage.bicep
az bicep build --file day-01/samples/storage.bicep
az bicep lint --file day-01/samples/storage.bicep
```

### Validate deployment success

```bash
az deployment group create \
  --resource-group rg-bicep-uXX \
  --template-file day-01/samples/storage.bicep \
  --parameters day-01/samples/storage.bicepparam
```

```bash
az storage account show \
  --name stb26uXX \
  --resource-group rg-bicep-uXX \
  --query "{name:name, sku:sku.name, tls:minimumTlsVersion, https:enableHttpsTrafficOnly, publicBlob:allowBlobPublicAccess}" \
  -o json
```
