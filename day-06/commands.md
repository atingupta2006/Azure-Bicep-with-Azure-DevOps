# Day 6 — Governance and capstone

Notes: [notes.md](notes.md). Replace `XX` with your seat. Repo: `iac-uXX`.  
Course folder (lab VM): `/home/buXX/Azure-Bicep-with-Azure-DevOps`

Do not deploy a VNet into `rg-bicep-shared`. Do not put passwords in Git or YAML.

The class VNet `vnet-bicep-shared` / `snet-app-shared` in `rg-bicep-shared` must exist before the capstone VM step.

---

## Lab 1 — Policy-compliant deployment

### Understand the built-in definition (CLI)

```bash
az policy definition show \
  --name 871b6d14-10aa-478d-b590-94f262ecfa99 \
  --query "{name:name, displayName:displayName, mode:properties.mode}" \
  -o json
```

### Assign policy in Azure Portal (you do this)

Do this twice on **your** resource group only.

#### First assignment — require tag `env`

1. Portal → search **Policy** → open **Policy**.
2. **Authoring** → **Definitions** → search `Require a tag on resources` → open the built-in definition.
3. Click **Assign** (or go to **Assignments** → **Assign policy**).
4. **Scope**: click the scope control → select **only** `rg-bicep-uXX`. Do not leave the whole subscription selected.
5. **Policy definition**: **Require a tag on resources**.
6. **Assignment name**: `uXX-require-tag-env` (example `u03-require-tag-env`).
7. **Parameters** tab → **Tag Name** = `env`.
8. Effect should be **Deny**.
9. **Review + create** → **Create**.

#### Second assignment — require tag `owner`

1. **Assign policy** again.
2. Same scope: `rg-bicep-uXX` only.
3. Assignment name: `uXX-require-tag-owner`.
4. **Tag Name** = `owner`.
5. **Review + create** → **Create**.

#### Confirm in Portal

1. Resource groups → `rg-bicep-uXX` → **Policies** (or Policy → **Assignments**).
2. Confirm both assignments list your RG as scope and the correct tag names.

If those assignment names already exist from an earlier setup, open them and confirm scope + parameters. Do not create a duplicate with the same name.

### Confirm assignments from CLI

```bash
az policy assignment list \
  --resource-group rg-bicep-uXX \
  --query "[].{name:name, displayName:displayName}" \
  -o table
```

### See a deny (recommended)

Try to create a storage account **without** tags. Use a unique name (example `stb26uXXdeny`). This should fail with a policy error. Nothing useful is created.

```bash
az storage account create \
  --name stb26uXXdeny \
  --resource-group rg-bicep-uXX \
  --location eastus \
  --sku Standard_LRS \
  --kind StorageV2
```

You should see an error that mentions policy (for example `RequestDisallowedByPolicy`). That is the point of the exercise.

If the create somehow succeeded (policy not active yet), delete it:

```bash
az storage account delete --name stb26uXXdeny --resource-group rg-bicep-uXX --yes
```

Wait one or two minutes after creating assignments if the deny does not appear on the first try, then run the create again.

### Reference existing Azure Policy using existing

Open `$COURSE/day-06/samples/tagged-storage.bicep`. Find the `existing` resource for the built-in definition. That line looks up the definition. It does not assign the policy.

```bash
COURSE=/home/buXX/Azure-Bicep-with-Azure-DevOps
grep -n existing "$COURSE/day-06/samples/tagged-storage.bicep"
```

### Deploy resource with mandatory tags

In `$COURSE/day-06/samples/tagged-storage.bicepparam`, replace `XX` (example `u03` → `owner = 'u03'`, storage name `stb26u03z`). Keep the param file next to `tagged-storage.bicep`.

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

Portal: Resource groups → `rg-bicep-uXX` → `stb26uXXz` → **Tags**. Confirm `env`, `owner`, `project`.

Also open the RG → **Policies** / compliance and notice the tagged storage is compliant for the tag rules.

```bash
az storage account delete --name stb26uXXz --resource-group rg-bicep-uXX --yes
```

---

## Lab 2 — End-to-end project (capstone)

This lab deploys **two storage accounts and one VM** from one `main.bicep`, through Git and the pipeline. The VM is required when quota allows.

### Copy samples into a clean `iac-uXX`

```bash
cd ~/iac-uXX
git checkout main
git pull origin main

COURSE=/home/buXX/Azure-Bicep-with-Azure-DevOps
cp "$COURSE/day-06/samples/main.bicep" .
cp "$COURSE/day-06/samples/dev.bicepparam" .
cp -r "$COURSE/day-06/samples/modules" .
mkdir -p pipelines
cp "$COURSE/day-06/samples/pipelines/azure-pipelines.yml" pipelines/
```

Replace every `XX` in `main.bicep` defaults and in `dev.bicepparam` (`owner`, `namePrefix`, VM/NIC/PIP names). Keep `param adminPassword = ''`.

### Use modular Bicep code

```bash
ls modules
grep "^module " main.bicep
```

You should see modules for storage (twice) and compute. Storage names become `stb26uXXa` and `stb26uXXb`. Network for the VM is the **existing** class subnet — do not deploy a new VNet.

Local check (password only for what-if/create when you test deploy):

```bash
az bicep lint --file main.bicep
az bicep build --file main.bicep
```

Optional local deploy (same password pattern as Day 3):

```bash
az deployment group create \
  --resource-group rg-bicep-uXX \
  --name main \
  --parameters dev.bicepparam \
  --parameters adminPassword='<admin-password>'
```

### Store code in Azure Repos / branching workflow

```bash
git checkout -b feature/capstone-tags
git add main.bicep dev.bicepparam modules pipelines
git commit -m "Capstone storage and compute"
git push -u origin feature/capstone-tags
```

Raise a pull request into `main` and **Complete** it.

### Deploy via Azure DevOps pipeline

1. If the pipeline does not exist yet: Pipelines → New pipeline → Azure Repos Git → `iac-uXX` → Existing YAML → `/pipelines/azure-pipelines.yml`.
2. If you already have a Day 5 pipeline, point it at the new YAML path or edit the pipeline to use `/pipelines/azure-pipelines.yml`.
3. Add secret **`VM_ADMIN_PASSWORD`** on the pipeline (Edit → Variables → New variable → keep secret), unless `vg-bicep-class` already has that secret.
4. Permit `vg-bicep-class` and `sc-azure-bicep` if asked.
5. On `main`, Confirm **Validate** and **DeployDev** both Succeeded.
6. On a PR run, Confirm Validate runs and DeployDev is skipped.

Set the pipeline parameter `resourceGroupName` default to `rg-bicep-uXX`.

### Validate resources in Azure Portal and CLI

```bash
az storage account list \
  --resource-group rg-bicep-uXX \
  --query "[].{name:name, sku:sku.name, tags:tags}" \
  -o json

az vm show \
  --resource-group rg-bicep-uXX \
  --name vm-bicep-uXX \
  --query "{name:name, size:hardwareProfile.vmSize, tags:tags}" \
  -o json

az network nic show \
  --resource-group rg-bicep-uXX \
  --name nic-vm-uXX \
  --query "ipConfigurations[0].properties.subnet.id" \
  -o tsv
```

Portal checks:

- Resource group `rg-bicep-uXX` shows both storage accounts and the VM  
- VM / NIC / PIP tags include `env`, `owner`, `project`, `workload`  
- NIC is on `snet-app-shared` (subnet id contains that name)

If `Standard_B1s` fails with quota, set `vmSize` to `Standard_B2s` in `dev.bicepparam`, commit through a small PR or amend your branch, and redeploy.

### Perform deployment updates through Pull Request workflow

Change **two** things in one change request:

1. `storageSku` from `Standard_LRS` to `Standard_GRS`  
2. tag `workload` from `batch` to `interactive`  

```bash
git checkout main
git pull origin main
git checkout -b feature/capstone-sku
```

Edit `dev.bicepparam`. Save.

```bash
git add dev.bicepparam
git commit -m "Capstone SKU and workload tag"
git push -u origin feature/capstone-sku
```

Raise a Pull Request into `main`. On the PR run, open What-If and note Modify on storage (SKU) and on tagged resources (`workload`). Complete the PR. Wait for DeployDev on `main`.

Confirm:

```bash
az storage account show -g rg-bicep-uXX -n stb26uXXa --query sku.name -o tsv
az vm show -g rg-bicep-uXX -n vm-bicep-uXX --query tags.workload -o tsv
```

Expect `Standard_GRS` and `interactive`.

### Destroy the VM when the capstone is done

Keep the storage accounts if you still need them for Day 7. Delete compute to stop VM cost:

```bash
az vm delete -g rg-bicep-uXX -n vm-bicep-uXX --yes
az network nic delete -g rg-bicep-uXX -n nic-vm-uXX
az network public-ip delete -g rg-bicep-uXX -n pip-vm-uXX
az disk list -g rg-bicep-uXX --query "[].name" -o tsv
az disk delete -g rg-bicep-uXX -n vm-bicep-uXX-osdisk --yes
```

If the OS disk name differs, use the name from `az disk list`.

Do not delete `rg-bicep-uXX`. Do not delete anything in `rg-bicep-shared`.
