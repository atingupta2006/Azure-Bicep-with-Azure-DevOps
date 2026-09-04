# Day 6 — Governance and capstone

Notes: [notes.md](notes.md). Replace `XX`. Repo: `iac-uXX`. Labs use `day-06/samples/` and your Day 5 pipeline.  
Do not deploy a VNet into `rg-bicep-shared`.

Course folder (lab VM): `/home/buXX/Azure-Bicep-with-Azure-DevOps`

Optional VM step needs the class shared VNet `vnet-bicep-shared` / subnet `snet-app-shared` in `rg-bicep-shared`. If compute fails with a missing subnet, ask the instructor to restore shared network.

---

## Lab 1 — Policy-compliant deployment

### Reference existing Azure Policy using existing

Built-in definition **Require a tag on resources** (`871b6d14-10aa-478d-b590-94f262ecfa99`). The sample reads the definition with `existing` — it does not create an assignment.

```bash
COURSE=/home/buXX/Azure-Bicep-with-Azure-DevOps
az policy definition show \
  --name 871b6d14-10aa-478d-b590-94f262ecfa99 \
  --query "{name:name, displayName:displayName, mode:properties.mode}" \
  -o json
```

### Deploy resource with mandatory tags

In `$COURSE/day-06/samples/tagged-storage.bicepparam`, replace `XX` with your seat (example `u03` → `owner = 'u03'`, `stb26uXXz` → `stb26u03z`). Keep the param file in **`samples/`** next to `tagged-storage.bicep`.

```bash
az deployment group create \
  --resource-group rg-bicep-uXX \
  --name tagged-storage \
  --parameters "$COURSE/day-06/samples/tagged-storage.bicepparam"
```

### Verify successful deployment due to compliance

```bash
az storage account show \
  --name stb26uXXz \
  --resource-group rg-bicep-uXX \
  --query tags \
  -o json

az deployment group show \
  --resource-group rg-bicep-uXX \
  --name tagged-storage \
  --query properties.outputs \
  -o json
```

Azure Portal: Resource groups → `rg-bicep-uXX` → `stb26uXXz` → Tags (`env`, `owner`, `project`).

```bash
az storage account delete --name stb26uXXz --resource-group rg-bicep-uXX --yes
```

---

## Lab 2 — End-to-end project

Copy capstone Bicep into `iac-uXX` (replaces Day 4/5 single-account `main.bicep` with modular two-account template):

```bash
cd ~/iac-uXX
git checkout main
git pull origin main

COURSE=/home/buXX/Azure-Bicep-with-Azure-DevOps
cp "$COURSE/day-06/samples/main.bicep" .
cp "$COURSE/day-06/samples/dev.bicepparam" .
cp -r "$COURSE/day-06/samples/modules" .
```

Replace `XX` in `main.bicep` and `dev.bicepparam` (`owner`, `namePrefix` → `stb26uXX`).

### Use modular Bicep code

```bash
ls modules
grep "^module " main.bicep
```

Storage names are `stb26uXXa` and `stb26uXXb`. Network for optional VM is the **existing** class VNet — do not deploy `network.bicep` into `rg-bicep-shared`.

### Store code in Azure Repos

```bash
git add main.bicep dev.bicepparam modules
git commit -m "Capstone modular Bicep"
git push origin main
```

Or use a branch + PR (recommended):

```bash
git checkout -b feature/capstone-tags
git add main.bicep dev.bicepparam modules
git commit -m "Capstone modular Bicep"
git push -u origin feature/capstone-tags
```

Raise a pull request into `main` and **Complete** it.

### Deploy via Azure DevOps pipeline

Same Day 5 pipeline on `main`: **Validate** (build + What-If) then **DeployDev** (creates or updates `stb26uXXa` / `stb26uXXb`).

### Validate resources in Azure Portal

```bash
az storage account list \
  --resource-group rg-bicep-uXX \
  --query "[].{name:name, sku:sku.name, tags:tags}" \
  -o json
```

### Optional — compute on existing network

Password on the command line only — not in git, not in YAML. In `$COURSE/day-03/samples/compute.bicepparam`, replace `XX` with your seat first. Keep the param file in **`samples/`** next to `compute.bicep`.

```bash
az deployment group create \
  --resource-group rg-bicep-uXX \
  --name compute \
  --parameters "$COURSE/day-03/samples/compute.bicepparam" adminPassword='<admin-password>'

az vm show \
  --resource-group rg-bicep-uXX \
  --name vm-bicep-uXX \
  --query "{name:name, tags:tags}" \
  -o json
```

Skip this block if B-series quota is unavailable.

### Perform deployment updates through Pull Request workflow

```bash
git checkout main
git pull origin main
git checkout -b feature/capstone-sku
```

Toggle `storageSku` in `dev.bicepparam`. Save.

```bash
git add dev.bicepparam
git commit -m "Capstone SKU update"
git push -u origin feature/capstone-sku
```

Raise a second pull request into `main`, complete it, wait for the pipeline on `main`, then confirm Portal / CLI shows the new SKU.
