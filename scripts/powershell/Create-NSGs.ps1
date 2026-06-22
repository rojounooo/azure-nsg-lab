# Usage: .\Create-NSGs.ps1 <resource-group> <location>
# Creates empty nsg-web and nsg-data and associates them with their subnets
# Rules should be configured manually in the portal after running this script

param(
    [string]$ResourceGroup,
    [string]$Location
)

if (-not $ResourceGroup) {
    Write-Error "Error: resource group name is required"
    Write-Host "Usage: .\Create-NSGs.ps1 <resource-group> <location>"
    exit 1
}

if (-not $Location) {
    Write-Error "Error: location is required"
    Write-Host "Usage: .\Create-NSGs.ps1 <resource-group> <location>"
    exit 1
}

# Check resource group exists
$rg = Get-AzResourceGroup -Name $ResourceGroup -ErrorAction SilentlyContinue
if (-not $rg) {
    Write-Error "Error: resource group '$ResourceGroup' does not exist"
    exit 1
}

# Check VNet exists
$vnet = Get-AzVirtualNetwork -Name "vnet-nsg-lab" -ResourceGroupName $ResourceGroup -ErrorAction SilentlyContinue
if (-not $vnet) {
    Write-Error "Error: vnet-nsg-lab does not exist in '$ResourceGroup' - run Create-VNet.ps1 first"
    exit 1
}

Write-Host "Creating nsg-web..."

$nsgWeb = New-AzNetworkSecurityGroup `
    -Name "nsg-web" `
    -ResourceGroupName $ResourceGroup `
    -Location $Location

if (-not $nsgWeb) {
    Write-Error "Error: failed to create nsg-web"
    exit 1
}

Write-Host "Associating nsg-web with snet-web..."

$snetWeb = Get-AzVirtualNetworkSubnetConfig -Name "snet-web" -VirtualNetwork $vnet
$snetWeb.NetworkSecurityGroup = $nsgWeb
Set-AzVirtualNetwork -VirtualNetwork $vnet | Out-Null

if (-not $?) {
    Write-Error "Error: failed to associate nsg-web with snet-web"
    exit 1
}

Write-Host "Creating nsg-data..."

$nsgData = New-AzNetworkSecurityGroup `
    -Name "nsg-data" `
    -ResourceGroupName $ResourceGroup `
    -Location $Location

if (-not $nsgData) {
    Write-Error "Error: failed to create nsg-data"
    exit 1
}

Write-Host "Associating nsg-data with snet-data..."

$vnet = Get-AzVirtualNetwork -Name "vnet-nsg-lab" -ResourceGroupName $ResourceGroup
$snetData = Get-AzVirtualNetworkSubnetConfig -Name "snet-data" -VirtualNetwork $vnet
$snetData.NetworkSecurityGroup = $nsgData
Set-AzVirtualNetwork -VirtualNetwork $vnet | Out-Null

if (-not $?) {
    Write-Error "Error: failed to associate nsg-data with snet-data"
    exit 1
}

Write-Host "nsg-web and nsg-data created and associated successfully"
Write-Host "Configure rules manually in the portal before deploying VMs"
