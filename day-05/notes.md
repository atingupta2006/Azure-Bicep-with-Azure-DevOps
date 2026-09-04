# Day 5 — Azure DevOps CI/CD for Bicep

Commands: [commands.md](commands.md)  
YAML: copy `day-05/samples/azure-pipelines.yml` into `iac-uXX` as `pipelines/azure-pipelines.yml`.  
Service connection `sc-azure-bicep` and variable group `vg-bicep-class` already exist.

Set `resourceGroupName` default to `rg-bicep-uXX`. Never target `rg-bicep-shared`.

---

## Module 5.1 — Azure DevOps pipelines

### Azure DevOps pipelines overview

A pipeline is YAML **in the repo**. A run is a job on a Microsoft-hosted agent (`ubuntu-latest`). The identity that talks to Azure is the **service connection**, not your `az login`.

| Event | What runs |
|-------|-----------|
| Push / merge to `main` | Validate, then **DeployDev** |
| Push to `feature/*` | **Validate** only |
| Pull request into `main` (from `feature/*`) | **Validate** only (`DeployDev` skipped — source branch is not `main`) |

That split is CI (every PR) without deploying from the feature branch.

Hands-on: [Pipelines hub](https://dev.azure.com/org-bicep/bicep-aug26/_build).

### YAML pipeline structure

Order in the file: `trigger`, `pr`, `pool`, `parameters`, `variables`, `stages` → `jobs` → `steps`.

```yaml
trigger:
  branches:
    include:
      - main
      - feature/*
pr:
  branches:
    include:
      - main
      - feature/*

pool:
  vmImage: ubuntu-latest

parameters:
  - name: resourceGroupName
    type: string
    default: rg-bicep-uXX   # change from rg-bicep-demo
```

Day 4 branches use the `feature/*` prefix (for example `feature/access-tier`). Pushes to those branches and pull requests into `main` run **Validate**. **DeployDev** runs only when the pipeline source branch is `main` (after merge), not on a `feature/*` branch and not during a PR build.

`variables: - group: vg-bicep-class` attaches the class Library variable group. That group holds shared values for every pipeline in the class. Today it includes `deployLocation` = `eastus`. The What-If and DeployDev steps pass it into Bicep as:

```bash
--parameters location="$(deployLocation)"
```

`$(deployLocation)` comes from the variable group, not from the YAML file and not from your laptop. Seat-specific values (resource group) stay as a pipeline **parameter**. Secrets (for example a VM password) can also live in a variable group — marked secret and never printed in logs. Today’s storage deploy does not need a password.

Hands-on: Pipelines → Library → `vg-bicep-class`, then `cat pipelines/azure-pipelines.yml`.

### Service Connection concept

```yaml
azureSubscription: sc-azure-bicep
```

That name is an Azure Resource Manager service connection already created in the project. The pipeline uses that identity for `az bicep` / `az deployment`. The connection is federated (no client secret in the YAML). Do **not** create a new connection. First run may ask you to **Permit** the variable group and the connection — permit, do not edit the connection.

### Pipeline stages overview

```mermaid
flowchart LR
  pr["PR into main"] --> v["Validate: lint + build + what-if"]
  main["Push / merge to main"] --> v
  v --> d["DeployDev — main branch only"]
```

| Stage | Tasks | When |
|-------|--------|------|
| Validate | `az bicep lint`, `az bicep build`, What-If with `dev.bicepparam` + `location` from the variable group | Always (PR and `main`) |
| DeployDev | `az deployment group create` with the same param file + `location` from the variable group | `main` only (`condition: eq(Build.SourceBranch, refs/heads/main)`) |

`DeployDev` `dependsOn` Validate. The pipeline deploys `main.bicep` with `dev.bicepparam` (Day 4 files in `iac-uXX`) and overrides `location` from `vg-bicep-class`.

### What-If deployments

`az deployment group what-if` shows Create / Ignore / Modify / Delete **without** changing Azure. There is no saved plan file. The next `az deployment group create` talks to live ARM again. First time this is a taught lab. Run it on the CLI **and** read the pipeline What-If log.

What-If is a preview, not a pixel-perfect contract. Default properties and some policy effects can show as noise. Use it to catch Create / Modify / Delete before DeployDev.

| Result | Meaning |
|--------|---------|
| Ignore | Azure already matches the template |
| Create | Resource would be added |
| Modify | Property change (for example SKU) |
| Delete | Would remove something in complete mode — not this lab |

---

## Lab 1 — CI validation pipeline

Create the pipeline from `day-05/samples/azure-pipelines.yml` (copied to `/pipelines/azure-pipelines.yml` on `iac-uXX`). Set `resourceGroupName` to `rg-bicep-uXX`. Run it. Open **Bicep build**, then **What-If**. Also run What-If on `samples/whatif-storage.bicep`, then delete `stb26uXXq`.

Commands: [commands.md](commands.md) — Lab 1.

---

## Module 5.2 — Continuous deployment for Bicep

### Deployment stages

Validate = CI (compile + What-If). DeployDev = CD to **dev** only (`dev.bicepparam`). No test stage, no prod stage.

### Environment approvals (conceptual)

Azure DevOps Environments can require a person to approve before a stage runs. This pipeline does **not** add a check. Production pattern: an approver for prod — **not configured** in this class. `DeployDev` starts when Validate succeeds.

### Dev environment deployments

`az deployment group create` with `dev.bicepparam`. Account name from Day 4 `main.bicep` (`stb26uXX`). Tags stay `env=dev`.

### Pipeline troubleshooting basics

Red stage → open the **task log** (not only the stage name).

| Symptom | Usual cause |
|---------|-------------|
| Bicep build / lint red | Syntax or analyzer in `main.bicep` |
| What-If red | Service connection RBAC, wrong `resourceGroupName` |
| DeployDev red | Azure (name taken, policy on Day 6). Storage name stays `stb26uXX`; if the name is taken globally, change the class prefix |
| DeployDev skipped | Source branch is `feature/*` or the run is a PR — expected until merge to `main` |

### Secure deployment considerations

No passwords in YAML (`grep` should find none). Identity is the service connection. `@secure()` stays in Bicep for Day 3 compute. Non-secret class settings (like `deployLocation`) and secrets (like a future VM password) both belong in the variable group — not hard-coded in the YAML.

---

## Lab 2 — CI/CD deployment

Let the **main** run finish **DeployDev**. A run from a pull request stops after Validate. Portal + `az storage account list` + `az deployment group show --name main`. Then branch, toggle SKU in `dev.bicepparam`, PR (Validate only), complete, pipeline on `main` (Validate + DeployDev). What-If on the merge should show **Modify** on SKU.

Commands: [commands.md](commands.md) — Lab 2.

No GitHub Actions. No prod stage. No real approval gate.

---

## Optional — subscription scope

Day 5 labs use **resource group** scope: the RG already exists and you run `az deployment group`.

Some templates set `targetScope = 'subscription'` at the top of the file. They can create **resource groups** as resources, then (in larger templates) deploy modules into those groups with `scope: rgName`.

Sample: `samples/subscription-rgs.bicep` creates `rg-bicep-uXX-sub-a` and `rg-bicep-uXX-sub-b`. CLI commands use `az deployment sub what-if` and `az deployment sub create` with `--location eastus`. See [commands.md](commands.md) — Optional section.

Keep your main work in `rg-bicep-uXX`. Delete the `-sub-a` / `-sub-b` groups when finished.
