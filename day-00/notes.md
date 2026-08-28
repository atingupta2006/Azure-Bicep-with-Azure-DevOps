# Day 0 — Setup

Commands: [setup.md](setup.md). Roster: [roster.md](roster.md). Optional lab VM: [lab-access.md](lab-access.md).

Find your name in the roster. Azure Portal login is `buXX@attt21.onmicrosoft.com`. Seat is `uXX`. Example: Supratim Chatterjee → `bu03@attt21.onmicrosoft.com` → `u03` → `rg-bicep-u03`, `stb26u03`.

## Names

| Item | Value | Shared? |
|------|--------|---------|
| Azure Portal / `az login` | `buXX@attt21.onmicrosoft.com` | No |
| Lab web VS Code | Linux `buXX` (same number; no `@attt21.onmicrosoft.com`) | No |
| Subscription | Class subscription on the board | Yes |
| Region | `eastus` | Yes |
| Your resource group | `rg-bicep-uXX` | No |
| Day 1 storage | `stb26uXX` | No |
| Day 2 storage | `stb26uXXa`, `stb26uXXb` | No |
| Day 3 VM / NIC / PIP | `vm-bicep-uXX`, `nic-vm-uXX`, `pip-vm-uXX` | No |
| Class network | `rg-bicep-shared` / `vnet-bicep-shared` / `snet-app-shared` | Yes (read; do not deploy into it) |
| Azure DevOps | `https://dev.azure.com/org-bicep` / project `bicep-aug26` / repo `iac-uXX` | Project yes; your repo no |

Sign in to Azure with **your** `buXX@attt21.onmicrosoft.com` account (CLI and Azure DevOps). Do not deploy into `rg-bicep-shared`. Pass the Day 3 VM password on the command line only.

## Repository

This clone is names, Day 1 notes and commands, and Day 1 lab files in `day-01/samples/` (`storage.bicep` + `storage.bicepparam`). Replace `XX` in those files.
