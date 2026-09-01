# Day 5 — Azure DevOps CI/CD

Notes: [notes.md](notes.md). Replace `XX`. Repo: `iac-uXX` (Day 4 clone with `main.bicep` + `dev.bicepparam` on `main`).  
Service connection `sc-azure-bicep` and variable group `vg-bicep-class` already exist.  
Labs use `day-05/samples/` plus files already in `iac-uXX`. Do not target `rg-bicep-shared`.

Course folder (lab VM): `/home/buXX/Azure-Bicep-with-Azure-DevOps`

---

## Before Lab 1

```bash
cd ~/iac-uXX
git checkout main
git pull origin main
```

Copy the pipeline YAML into your repo:

```bash
COURSE=/home/buXX/Azure-Bicep-with-Azure-DevOps
mkdir -p pipelines
cp "$COURSE/day-05/samples/azure-pipelines.yml" pipelines/azure-pipelines.yml
```

In `pipelines/azure-pipelines.yml`, set the default `resourceGroupName` to `rg-bicep-uXX`. Save.

```bash
git add pipelines/azure-pipelines.yml
git commit -m "Add Azure Pipelines YAML"
git push origin main
```

First pipeline run may ask you to **Permit** variable group `vg-bicep-class` and service connection `sc-azure-bicep`. Permit — do not edit the connection.

---

## Lab 1 — CI validation pipeline

### Create YAML validation pipeline

Azure DevOps: Pipelines → **New pipeline** → Azure Repos Git → **`iac-uXX`** → **Existing Azure Pipelines YAML file** → path `/pipelines/azure-pipelines.yml` → **Save** (do not Run yet if it prompts — Run in the next step).

### Run Bicep build validation

Pipelines → your pipeline → **Run pipeline** → **Run**.

Open the **Validate** stage → **Bicep build** task log. Exit code must be 0.

A run from a **pull request** into `main` runs Validate only. **DeployDev** is skipped on PRs.

### Run What-If deployment

Open the **What-If (dev)** task log on the same run.

CLI equivalent from your `iac-uXX` clone (same param file the pipeline uses):

```bash
cd ~/iac-uXX
az deployment group what-if \
  --resource-group rg-bicep-uXX \
  --parameters dev.bicepparam
```

Throwaway What-If sample from the course folder (creates `stb26uXXq`, then delete it).

In `$COURSE/day-05/samples/whatif-storage.bicepparam`, replace `XX` with your seat (`namePrefix` / `owner`). Keep the param file in **`samples/`** next to `whatif-storage.bicep` — do not copy the param file alone to another folder.

```bash
COURSE=/home/buXX/Azure-Bicep-with-Azure-DevOps
az deployment group what-if \
  --resource-group rg-bicep-uXX \
  --parameters "$COURSE/day-05/samples/whatif-storage.bicepparam"

az deployment group create \
  --resource-group rg-bicep-uXX \
  --name whatif-storage \
  --parameters "$COURSE/day-05/samples/whatif-storage.bicepparam"

az storage account delete --name stb26uXXq --resource-group rg-bicep-uXX --yes
```

### Validate deployment outputs

After Lab 2 **DeployDev** succeeds:

```bash
az deployment group show \
  --resource-group rg-bicep-uXX \
  --name main \
  --query properties.outputs \
  -o json
```

---

## Lab 2 — CI/CD deployment

### Use pre-provisioned Service Connection

The YAML already references `azureSubscription: sc-azure-bicep`. Do not create a new service connection.

### Configure deployment stage

**DeployDev** runs `az deployment group create` with `dev.bicepparam` when the run is **not** a pull request. No edit required if you copied the sample YAML.

### Deploy to dev environment

Run the pipeline on **`main`** (or re-run the latest `main` run). Let **DeployDev** finish.

```bash
az storage account list \
  --resource-group rg-bicep-uXX \
  --query "[].{name:name, sku:sku.name}" \
  -o table
```

### Validate deployment in Azure Portal

Azure Portal: Resource groups → `rg-bicep-uXX` → storage account `stb26uXX` from Day 4 `main.bicep`.

```bash
az deployment group show \
  --resource-group rg-bicep-uXX \
  --name main \
  --query properties.outputs \
  -o json
```

### Re-run deployment after updates

```bash
cd ~/iac-uXX
git checkout main
git pull origin main
git checkout -b feature/pipeline-rerun
```

In `dev.bicepparam`, set `storageSku` to `Standard_GRS` (or back to `Standard_LRS` if it is already GRS). Save.

```bash
git add dev.bicepparam
git commit -m "Toggle dev storage SKU"
git push -u origin feature/pipeline-rerun
```

Raise a pull request into `main`. The PR run should show Validate only (What-If may show **Modify** on SKU). Complete the PR, then confirm the **`main`** run runs Validate + **DeployDev**.
