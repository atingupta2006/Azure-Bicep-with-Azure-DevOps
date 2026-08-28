# Day 3 — Network and compute

Notes: [notes.md](notes.md). Replace `XX` (example `u03` → `rg-bicep-u03`, `vm-bicep-u03`). Labs use `samples/` only.

Run every command from the **course clone root** (the folder that contains `day-03/`).

Do not deploy into `rg-bicep-shared`. The class VNet there is shared; your VM NIC attaches to it in Lab 2 only.

```bash
az account show --query name -o tsv
```

---

## Parameter files and the VM password

Each sample uses a `.bicepparam` file with a `using '…bicep'` line. That links the param file to the template.

When you deploy with a `.bicepparam` file:

1. Do **not** add `--template-file`. The param file already points at the Bicep file.
2. Use **one** `--parameters` argument. Put the param file first, then any overrides on the **same line**.
3. The VM password is `@secure()` in Bicep. `compute.bicepparam` keeps `adminPassword = ''` as a placeholder only. Type the real password on the command line — never in git.

Correct pattern (Lab 2 VM):

```bash
az deployment group create \
  --resource-group rg-bicep-uXX \
  --name compute \
  --parameters day-03/samples/compute.bicepparam adminPassword='<admin-password>'
```

Wrong — two `--parameters` flags (fails on many CLI builds):

```bash
  --parameters day-03/samples/compute.bicepparam \
  --parameters adminPassword='<admin-password>'
```

Wrong — `--template-file` with a `.bicepparam` that has `using` (errors on current CLI):

```bash
  --template-file day-03/samples/compute.bicep \
  --parameters day-03/samples/compute.bicepparam
```

Use **single quotes** around the password so Bash does not expand special characters.

To change VM size at deploy time (optional), add `vmSize` on the same `--parameters` line:

```bash
  --parameters day-03/samples/compute.bicepparam adminPassword='<admin-password>' vmSize=Standard_B2s
```

Allowed sizes: `Standard_B1s`, `Standard_B2s`.

Confirm the param file does not contain a real password:

```bash
grep adminPassword day-03/samples/compute.bicepparam
```

Expect: `param adminPassword = ''` only.

---

## Lab 1 — Network foundation

Deploy a VNet into **your** resource group (`rg-bicep-uXX`). This is not the class VNet.

### Inspect the template

```bash
cat day-03/samples/network.bicep
cat day-03/samples/network.bicepparam
```

Replace `XX` in `network.bicepparam` before you deploy (or rely on your seat number in the file).

### Deploy VNet, subnets, and NSG

```bash
az deployment group create \
  --resource-group rg-bicep-uXX \
  --name network \
  --parameters day-03/samples/network.bicepparam
```

### Confirm the VNet

```bash
az network vnet show \
  --resource-group rg-bicep-uXX \
  --name vnet-bicep-uXX \
  --query "{name:name,address:addressSpace.addressPrefixes}" \
  -o json
```

### Confirm two subnets

```bash
az network vnet subnet list \
  --resource-group rg-bicep-uXX \
  --vnet-name vnet-bicep-uXX \
  --query "[].{name:name,prefix:addressPrefix}" \
  -o table
```

### Confirm NSG rules

```bash
az network nsg show \
  --resource-group rg-bicep-uXX \
  --name nsg-app-uXX \
  --query "{name:name,rules:securityRules[].{name:name,port:destinationPortRange,access:access}}" \
  -o json
```

### Confirm NSG is on the app subnet only

```bash
az network vnet subnet show \
  --resource-group rg-bicep-uXX \
  --vnet-name vnet-bicep-uXX \
  --name snet-app-uXX \
  --query networkSecurityGroup.id \
  -o tsv
```

```bash
az network vnet subnet show \
  --resource-group rg-bicep-uXX \
  --vnet-name vnet-bicep-uXX \
  --name snet-mgmt-uXX \
  --query networkSecurityGroup.id \
  -o tsv
```

The app subnet id ends with `nsg-app-uXX`. The mgmt subnet returns empty (no NSG).

---

## Lab 2 — Compute on existing network

The VM NIC attaches to the **class** app subnet in `rg-bicep-shared`. Do not deploy `network.bicep` there.

### Inspect the templates

```bash
cat day-03/samples/existing-vnet.bicep
cat day-03/samples/compute.bicep
cat day-03/samples/compute.bicepparam
```

Replace `XX` in `compute.bicepparam` before you deploy.

### Reference existing VNet (lookup only)

This deployment writes **outputs** only. It does not change `rg-bicep-shared`.

```bash
az deployment group create \
  --resource-group rg-bicep-uXX \
  --name existing-vnet \
  --parameters day-03/samples/existing-vnet.bicepparam
```

```bash
az deployment group show \
  --resource-group rg-bicep-uXX \
  --name existing-vnet \
  --query properties.outputs \
  -o json
```

Expect subnet ids under `rg-bicep-shared` / `vnet-bicep-shared`.

### Deploy VM into the class app subnet

Type your classroom VM password where `<admin-password>` appears. Minimum 12 characters; mix upper, lower, digit, and special.

```bash
az deployment group create \
  --resource-group rg-bicep-uXX \
  --name compute \
  --parameters day-03/samples/compute.bicepparam adminPassword='<admin-password>'
```

If B1s quota is exhausted, retry with `vmSize=Standard_B2s` on the same line (see the parameter section above).

### Parameterize VM size

Default size is in the param file. To change it permanently, edit `day-03/samples/compute.bicepparam`:

```bash
grep -n -A6 vmSize day-03/samples/compute.bicep day-03/samples/compute.bicepparam
```

Allowed: `Standard_B1s`, `Standard_B2s`.

### Validate deployment

```bash
az vm show \
  --resource-group rg-bicep-uXX \
  --name vm-bicep-uXX \
  --query "{state:provisioningState, size:hardwareProfile.vmSize, boot:diagnosticsProfile.bootDiagnostics}" \
  -o json
```

```bash
az network nic show \
  --resource-group rg-bicep-uXX \
  --name nic-vm-uXX \
  --query ipConfigurations[0].subnet.id \
  -o tsv
```

Expect `snet-app-shared` in the subnet id.

```bash
az network public-ip show \
  --resource-group rg-bicep-uXX \
  --name pip-vm-uXX \
  --query ipAddress \
  -o tsv
```

```bash
az vm get-instance-view \
  --resource-group rg-bicep-uXX \
  --name vm-bicep-uXX \
  --query "instanceView.statuses[].displayStatus" \
  -o tsv
```

```bash
az deployment group show \
  --resource-group rg-bicep-uXX \
  --name compute \
  --query properties.outputs \
  -o json
```

ARM masks secure parameters in deployment history:

```bash
az deployment group show \
  --resource-group rg-bicep-uXX \
  --name compute \
  --query properties.parameters.adminPassword
```

Expect `"value": "*******"`, not your plain-text password.

---

## Optional — Deployment stacks

After Lab 2: [extras/deployment-stacks.md](extras/deployment-stacks.md) (template: `extras/vm-stack.bicep`). Not required for Day 3.
