# Day 2 — Parameters, variables, and modules

Notes: [notes.md](notes.md). Replace `XX` (example `u03` → `stb26u03`). Labs use `samples/` only. Same resource group as Day 1.

```bash
az account show --query name -o tsv
az group show --name rg-bicep-uXX --query name -o tsv
```

---

## Lab 1 — Environment-ready template

### Convert hardcoded values to parameters

```bash
cat day-01/samples/storage.bicep
cat day-02/samples/env-template.bicep
```

### Add minLength and maxLength validation

```bash
grep -n -B2 -A6 "storageAccountName" day-02/samples/env-template.bicep
```

```bash
az bicep build --file day-02/samples/env-template.bicep
```

### Create dev and test parameter files

```bash
cat day-02/samples/dev.bicepparam
cat day-02/samples/test.bicepparam
```

### Deploy using parameter files

```bash
az deployment group create \
  --resource-group rg-bicep-uXX \
  --template-file day-02/samples/env-template.bicep \
  --parameters day-02/samples/dev.bicepparam
```

```bash
az storage account show \
  --name stb26uXX \
  --resource-group rg-bicep-uXX \
  --query "{name:name, sku:sku.name}" \
  -o table
```

```bash
az deployment group create \
  --resource-group rg-bicep-uXX \
  --template-file day-02/samples/env-template.bicep \
  --parameters day-02/samples/dev.bicepparam \
  --parameters storageSku=Premium_LRS
```

That SKU is outside `@allowed`. Deploy with the test file:

```bash
az deployment group create \
  --resource-group rg-bicep-uXX \
  --template-file day-02/samples/env-template.bicep \
  --parameters day-02/samples/test.bicepparam
```

```bash
az storage account show \
  --name stb26uXX \
  --resource-group rg-bicep-uXX \
  --query sku.name \
  -o tsv
```

---

## Lab 2 — Modular deployment

### Create a storage module

```bash
cat day-02/samples/modules/one-storage.bicep
```

### Use variables for naming

```bash
grep -n -A3 "var storageName" day-02/samples/reuse-module.bicep
```

Accounts are `namePrefix` plus `a` and `b` (`stb26uXXa`, `stb26uXXb`).

### Expose outputs

```bash
grep -n "^output " day-02/samples/reuse-module.bicep day-02/samples/modules/one-storage.bicep
```

### Reuse module twice in main template

```bash
cat day-02/samples/reuse-module.bicep
cat day-02/samples/reuse-module.bicepparam
```

```bash
az deployment group create \
  --resource-group rg-bicep-uXX \
  --template-file day-02/samples/reuse-module.bicep \
  --parameters day-02/samples/reuse-module.bicepparam
```

```bash
az storage account list \
  --resource-group rg-bicep-uXX \
  --query "[].{name:name, sku:sku.name}" \
  -o table
```

```bash
az deployment group show \
  --resource-group rg-bicep-uXX \
  --name reuse-module \
  --query properties.outputs \
  -o json
```

```bash
az bicep lint --file day-02/samples/reuse-module.bicep
az bicep lint --file day-02/samples/modules/one-storage.bicep
```
