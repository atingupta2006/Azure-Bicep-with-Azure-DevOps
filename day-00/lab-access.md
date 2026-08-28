# Lab VM (optional)

Shared Ubuntu machine with VS Code. This is **not** the Day 3 VM (`vm-bicep-uXX`). `az` and `bicep` are on the PATH. Course files open in `Azure-Bicep-with-Azure-DevOps`.

Your seat does not change. Azure Portal stays `buXX@attt21.onmicrosoft.com`. This page is Linux `buXX` (same number). Roster: [roster.md](roster.md).

## Browser

```text
https://biceplab-aug26usg.eastus.cloudapp.azure.com/
```

Use the FQDN, not the numeric IP.

| Field | Value |
|--------|--------|
| Username | `buXX` only (example `bu03`). Do **not** type `buXX@attt21.onmicrosoft.com` here |
| Password | class Linux password (on the board) |

| Where | Username |
|--------|----------|
| Azure Portal / `az login` | `buXX@attt21.onmicrosoft.com` |
| This web VS Code page | `buXX` |

### Sign out of the lab URL

Open this in the **same tab** (do not delete cookies):

```text
https://logout:logout@biceplab-aug26usg.eastus.cloudapp.azure.com/logout
```

Then open https://biceplab-aug26usg.eastus.cloudapp.azure.com/ and sign in again (or Cancel).

`az logout` in the terminal only signs out of Azure CLI. It does not leave this web page.

Terminal: **Ctrl+`** (backtick). Then:

```bash
az login --use-device-code
```

Open https://microsoft.com/devicelogin on your laptop, enter the code, then:

```bash
az account show --query name -o tsv
az bicep version
```

Subscription name must match the **class subscription on the board** (not Pay-As-You-Go).

Extensions: **Ctrl+Shift+X**. Bicep is already installed. Install others from the list in the editor.

Run a Day 1 check: **Terminal → Run Task…** → `bicep lint storage` or `bicep build storage`.

## Laptop VS Code (full Marketplace)

On your laptop, install [Visual Studio Code](https://code.visualstudio.com/) and the **Remote - SSH** extension.

Command Palette (**F1**) → **Remote-SSH: Connect to Host…** → enter (replace `buXX`):

```text
buXX@biceplab-aug26usg.eastus.cloudapp.azure.com
```

Same Linux password as the web page. Open folder `/home/buXX/Azure-Bicep-with-Azure-DevOps`. Install **Bicep** from the Marketplace if the editor prompts.

## SSH shell only

```bash
ssh buXX@biceplab-aug26usg.eastus.cloudapp.azure.com
```

Or:

```bash
az extension add --name ssh
az login
az account show --query name -o tsv
az ssh vm -g rg-usersessionguard -n vm-bicep-lab
```

Do not run `sudo`.
