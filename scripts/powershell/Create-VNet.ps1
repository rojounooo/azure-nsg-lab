# Usage: .\Create-VNet.ps1 <resource-group> <vnet-name> <address-prefix> <location>

param(
    [string]$ResourceGroup,
    [string]$VNetName,
    [string]$AddressPrefix,
    [string]$Location
)

if (-not $ResourceGroup) {
    Write-Error "Error: resource group name is required"
    Write-Host "Usage: .\Create-VNet.ps1 <resource-group> <vnet-name> <address-prefix> <location>"
    exit 1
}

if (-not $VNetName) {
    Write-Error "Error: VNet name is required"
    Write-Host "Usage: .\Create-VNet.ps1 <resource-group> <vnet-name> <address-prefix> <location>"
    exit 1
}

if (-not $AddressPrefix) {
    Write-Error "Error: address prefix is required"
    Write-Host "Usage: .\Create-VNet.ps1 <resource-group> <vnet-name> <address-prefix> <location>"
    exit 1
}

if (-not $Location) {
    Write-Error "Error: location is required"
    Write-Host "Usage: .\Create-VNet.ps1 <resource-group> <vnet-name> <address-prefix> <location>"
    exit 1
}

# Check resource group exists
$rg = Get-AzResourceGroup -Name $ResourceGroup -ErrorAction SilentlyContinue
if (-not $rg) {
    Write-Error "Error: resource group '$ResourceGroup' does not exist"
    exit 1
}

# Check VNet does not already exist
$existingVNet = Get-AzVirtualNetwork -Name $VNetName -ResourceGroupName $ResourceGroup -ErrorAction SilentlyContinue
if ($existingVNet) {
    Write-Error "Error: VNet '$VNetName' already exists in '$ResourceGroup'"
    exit 1
}

Write-Host "Creating subnet configurations..."

$snetWeb = New-AzVirtualNetworkSubnetConfig -Name "snet-web" -AddressPrefix "10.0.1.0/24"
$snetData = New-AzVirtualNetworkSubnetConfig -Name "snet-data" -AddressPrefix "10.0.2.0/24"

Write-Host "Creating VNet '$VNetName' with address space '$AddressPrefix'..."

New-AzVirtualNetwork `
    -Name $VNetName `
    -ResourceGroupName $ResourceGroup `
    -Location $Location `
    -AddressPrefix $AddressPrefix `
    -Subnet $snetWeb, $snetData

if (-not $?) {
    Write-Error "Error: failed to create VNet"
    exit 1
}

Write-Host "VNet '$VNetName' and subnets created successfully"
