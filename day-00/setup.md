# Names

Notes: [notes.md](notes.md). Roster: [roster.md](roster.md). Optional lab VM (web VS Code): [lab-access.md](lab-access.md). Find your name. Azure Portal login `buXX@attt21.onmicrosoft.com`. Seat `uXX`. Example: Supratim Chatterjee → `bu03@attt21.onmicrosoft.com` → `u03` → `rg-bicep-u03`.

| | |
|--|--|
| Azure Portal / `az login` | `buXX@attt21.onmicrosoft.com` |
| Lab web VS Code | Linux `buXX` (same number) |
| Subscription | `MSDN` |
| Region | `eastus` |
| Resource group | `rg-bicep-uXX` |
| Day 1 storage | `stb26uXX` |
| Day 1 lab files | `day-01/samples/storage.bicep` + `storage.bicepparam` |
| Day 2 storage | `stb26uXXa`, `stb26uXXb` |
| Day 3 VM / NIC / PIP | `vm-bicep-uXX`, `nic-vm-uXX`, `pip-vm-uXX` |
| Class network (Day 3) | `rg-bicep-shared` / `vnet-bicep-shared` / `snet-app-shared` |
| Azure DevOps org | `https://dev.azure.com/org-bicep` |
| Project | `bicep-aug26` |
| Working repo | `iac-uXX` |
| Service connection | `sc-azure-bicep` |
| Variable group | `vg-bicep-class` |

```bash
git clone https://github.com/atingupta2006/Azure-Bicep-with-Azure-DevOps.git
cd Azure-Bicep-with-Azure-DevOps
```

```bash
find day-00 day-01 -type f | sort
ls day-01/samples
```

On a **laptop** (or Cloud Shell), sign in as `buXX@attt21.onmicrosoft.com`. Subscription name must be **MSDN**.

```bash
az login
az account show --query name -o tsv
az bicep version
```

On the **lab VM browser** terminal, use device code (the VM has no browser for Azure login):

```bash
az login --use-device-code
```

Open https://microsoft.com/devicelogin on your laptop, enter the code, then `az account show` as above.

If Bicep CLI is missing:

```bash
az bicep install
```

```bash
code --install-extension ms-azuretools.vscode-bicep
```

Skip `code` if you are in Cloud Shell. On the lab VM, Bicep is already installed.
