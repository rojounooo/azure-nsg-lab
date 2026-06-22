# Scripts

Scripts are located in `scripts/bash/` and `scripts/powershell/` and automate the provisioning of lab infrastructure. NSG rules are intentionally excluded and should be configured manually in the portal after running the NSG script.

## Bash

| Script | Description |
|---|---|
| `create-rg.sh` | Creates the resource group |
| `create-vnet.sh` | Creates the VNet and both subnets |
| `create-nsgs.sh` | Creates empty NSGs and associates them with their subnets |
| `create-vms.sh` | Creates vm-web with a public IP and vm-data with no public IP |

## PowerShell

| Script | Description |
|---|---|
| `Create-RG.ps1` | Creates the resource group |
| `Create-VNet.ps1` | Creates the VNet and both subnets |
| `Create-NSGs.ps1` | Creates empty NSGs and associates them with their subnets |
| `Create-VMs.ps1` | Creates vm-web with a public IP and vm-data with no public IP |

Run scripts in the order listed above regardless of which language you use.

## Running the scripts

**Bash - Azure Cloud Shell (recommended)**

Cloud Shell has the Azure CLI pre-installed and already authenticated. Upload the scripts using the upload button in the Cloud Shell toolbar, then make them executable and run them:

```bash
chmod +x create-rg.sh create-vnet.sh create-nsgs.sh create-vms.sh

./create-rg.sh rg-nsg-lab swedencentral
./create-vnet.sh rg-nsg-lab vnet-nsg-lab 10.0.0.0/16 swedencentral
./create-nsgs.sh rg-nsg-lab swedencentral
./create-vms.sh rg-nsg-lab azureuser YourPassword123! swedencentral
```

**Bash - local machine**

Requires the Azure CLI installed and an active login. Run `az login` first, then execute the scripts in the same order as above.

**PowerShell - Azure Cloud Shell (recommended)**

```powershell
.\Create-RG.ps1 rg-nsg-lab swedencentral
.\Create-VNet.ps1 rg-nsg-lab vnet-nsg-lab 10.0.0.0/16 swedencentral
.\Create-NSGs.ps1 rg-nsg-lab swedencentral
.\Create-VMs.ps1 rg-nsg-lab azureuser YourPassword123! swedencentral
```

**PowerShell - local machine**

Requires the Az PowerShell module installed and an active login. Run `Connect-AzAccount` first, then execute the scripts:

```powershell
.\Create-RG.ps1 rg-nsg-lab swedencentral
.\Create-VNet.ps1 rg-nsg-lab vnet-nsg-lab 10.0.0.0/16 swedencentral
.\Create-NSGs.ps1 rg-nsg-lab swedencentral
.\Create-VMs.ps1 rg-nsg-lab azureuser YourPassword123! swedencentral
```

**Note:** The PowerShell VM script creates the public IP and NIC as separate resources before attaching them to the VM. This is how the Az PowerShell module works - unlike the CLI which handles this in a single command.

**Note:** If script execution is blocked on your machine, run `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser` to allow local scripts to run.
