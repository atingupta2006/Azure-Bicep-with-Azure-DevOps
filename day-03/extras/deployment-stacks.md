# Optional — Deployment stacks (short lab)

This is **optional**. Finish Day 3 Lab 1 and Lab 2 first.

A normal `az deployment group create` deploys your Bicep and then mostly forgets the set. A **deployment stack** keeps a list of the resources it created so you can update or remove them as one unit.

You will deploy a small VM (PIP + NIC + VM) with a stack, look at it in the Portal, then try **detach** and **delete**.

Replace every `XX` with your seat number (example: `uXX` → `u03`, `rg-bicep-uXX` → `rg-bicep-u03`). Do that in **both** this page’s commands **and** inside `day-03/extras/vm-stack.bicep` (resource names and the `owner` tag).

Run from the course clone root. Pass the classroom VM password on the command line only.

Do **not** deploy into `rg-bicep-shared`. Names here (`vm-stack-uXX`) are different from Lab 2 (`vm-bicep-uXX`) on purpose.

```bash
az account show --query name -o tsv
```

---

## 1. Prepare the template

```bash
cat day-03/extras/vm-stack.bicep
```

In `day-03/extras/vm-stack.bicep`, set your seat on these defaults (example seat `u03`):

- `vmName` → `vm-stack-u03`
- `nicName` → `nic-stack-u03`
- `pipName` → `pip-stack-u03`
- `tags.owner` → `u03`

```bash
az bicep lint --file day-03/extras/vm-stack.bicep
az bicep build --file day-03/extras/vm-stack.bicep
```

---

## 2. Create the stack

```bash
az stack group create \
  --name stack-bicep-uXX \
  --resource-group rg-bicep-uXX \
  --template-file day-03/extras/vm-stack.bicep \
  --action-on-unmanage deleteAll \
  --deny-settings-mode none \
  --yes \
  --parameters adminPassword='<admin-password>'
```

If the size is unavailable:

```bash
az stack group create \
  --name stack-bicep-uXX \
  --resource-group rg-bicep-uXX \
  --template-file day-03/extras/vm-stack.bicep \
  --action-on-unmanage deleteAll \
  --deny-settings-mode none \
  --yes \
  --parameters adminPassword='<admin-password>' vmSize=Standard_B2s
```

---

## 3. Check what the stack owns

```bash
az stack group show \
  --name stack-bicep-uXX \
  --resource-group rg-bicep-uXX \
  --query "{name:name, provisioningState:provisioningState, resources:resources[].id}" \
  -o json
```

If `resources` looks empty, print the full object and open the Portal blade instead:

```bash
az stack group show \
  --name stack-bicep-uXX \
  --resource-group rg-bicep-uXX \
  -o jsonc
```

```bash
az vm show -g rg-bicep-uXX -n vm-stack-uXX \
  --query "{state:provisioningState,size:hardwareProfile.vmSize}" -o json
```

```bash
az network nic show -g rg-bicep-uXX -n nic-stack-uXX \
  --query ipConfigurations[0].subnet.id -o tsv
```

The subnet id should include `snet-app-shared`.

**Portal:** Resource group `rg-bicep-uXX` → **Deployment stacks** → `stack-bicep-uXX`.  
That is different from **Deployments** (normal template runs).

---

## 4. Detach (remove the stack, keep the VM)

```bash
az stack group delete \
  --name stack-bicep-uXX \
  --resource-group rg-bicep-uXX \
  --action-on-unmanage detachAll \
  --yes
```

```bash
az vm show -g rg-bicep-uXX -n vm-stack-uXX --query name -o tsv
```

The VM should still be there. The stack entry should be gone from **Deployment stacks**.

---

## 5. Create again, then delete everything the stack owns

Same resource names are fine. The stack takes ownership of the existing PIP, NIC, and VM again.

```bash
az stack group create \
  --name stack-bicep-uXX \
  --resource-group rg-bicep-uXX \
  --template-file day-03/extras/vm-stack.bicep \
  --action-on-unmanage deleteAll \
  --deny-settings-mode none \
  --yes \
  --parameters adminPassword='<admin-password>'
```

```bash
az stack group delete \
  --name stack-bicep-uXX \
  --resource-group rg-bicep-uXX \
  --action-on-unmanage deleteAll \
  --yes
```

```bash
az vm show -g rg-bicep-uXX -n vm-stack-uXX 2>&1 | head -5
```

The stack VM should be gone. Your Lab 2 VM (`vm-bicep-uXX`), if you still have one, is separate — leave it alone.

```bash
az network vnet show -g rg-bicep-shared -n vnet-bicep-shared --query name -o tsv
```

The class VNet must still be there.

---

## Compared with Lab 2

| | Lab 2 (`az deployment group create`) | This optional lab (`az stack group`) |
|--|--------------------------------------|--------------------------------------|
| Deploys Bicep | Yes | Yes |
| Remembers the set for later delete | No | Yes |
| One command to remove the set | No — delete resources yourself | `az stack group delete` with `deleteAll` |

Use Lab 2 for the main Day 3 work. Use stacks when you want that lifecycle list.

---

## Cleanup leftovers after detach

Only if you stopped after step 4 (or detach) and still have `vm-stack-uXX`:

```bash
az vm delete -g rg-bicep-uXX -n vm-stack-uXX --yes
az network nic delete -g rg-bicep-uXX -n nic-stack-uXX
az network public-ip delete -g rg-bicep-uXX -n pip-stack-uXX
az disk delete -g rg-bicep-uXX -n vm-stack-uXX-osdisk --yes
```
