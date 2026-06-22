# Usage: .\Create-VMs.ps1 <resource-group> <admin-username> <admin-password> <location>

param(
    [string]$ResourceGroup,
    [string]$AdminUsername,
    [string]$AdminPassword,
    [string]$Location
)

if (-not $ResourceGroup) {
    Write-Error "Error: resource group name is required"
    Write-Host "Usage: .\Create-VMs.ps1 <resource-group> <admin-username> <admin-password> <location>"
    exit 1
}

if (-not $AdminUsername) {
    Write-Error "Error: admin username is required"
    Write-Host "Usage: .\Create-VMs.ps1 <resource-group> <admin-username> <admin-password> <location>"
    exit 1
}

if (-not $AdminPassword) {
    Write-Error "Error: admin password is required"
    Write-Host "Usage: .\Create-VMs.ps1 <resource-group> <admin-username> <admin-password> <location>"
    exit 1
}

if (-not $Location) {
    Write-Error "Error: location is required"
    Write-Host "Usage: .\Create-VMs.ps1 <resource-group> <admin-username> <admin-password> <location>"
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

# Check subnets exist
$snetWeb = Get-AzVirtualNetworkSubnetConfig -Name "snet-web" -VirtualNetwork $vnet -ErrorAction SilentlyContinue
if (-not $snetWeb) {
    Write-Error "Error: snet-web does not exist - run Create-VNet.ps1 first"
    exit 1
}

$snetData = Get-AzVirtualNetworkSubnetConfig -Name "snet-data" -VirtualNetwork $vnet -ErrorAction SilentlyContinue
if (-not $snetData) {
    Write-Error "Error: snet-data does not exist - run Create-VNet.ps1 first"
    exit 1
}

$securePassword = ConvertTo-SecureString $AdminPassword -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential($AdminUsername, $securePassword)

Write-Host "Creating public IP for vm-web..."

$publicIp = New-AzPublicIpAddress `
    -Name "vm-web-ip" `
    -ResourceGroupName $ResourceGroup `
    -Location $Location `
    -AllocationMethod Static

if (-not $publicIp) {
    Write-Error "Error: failed to create public IP"
    exit 1
}

Write-Host "Creating NIC for vm-web..."

$nicWeb = New-AzNetworkInterface `
    -Name "vm-web-nic" `
    -ResourceGroupName $ResourceGroup `
    -Location $Location `
    -SubnetId $snetWeb.Id `
    -PublicIpAddressId $publicIp.Id

if (-not $nicWeb) {
    Write-Error "Error: failed to create NIC for vm-web"
    exit 1
}

Write-Host "Creating vm-web..."

$vmWebConfig = New-AzVMConfig -VMName "vm-web" -VMSize "Standard_B2ats_v2" |
    Set-AzVMOperatingSystem -Linux -ComputerName "vm-web" -Credential $credential |
    Set-AzVMSourceImage -PublisherName "Canonical" -Offer "0001-com-ubuntu-server-jammy" -Skus "22_04-lts-gen2" -Version "latest" |
    Add-AzVMNetworkInterface -Id $nicWeb.Id

New-AzVM -ResourceGroupName $ResourceGroup -Location $Location -VM $vmWebConfig

if (-not $?) {
    Write-Error "Error: failed to create vm-web"
    exit 1
}

Write-Host "Creating NIC for vm-data..."

$nicData = New-AzNetworkInterface `
    -Name "vm-data-nic" `
    -ResourceGroupName $ResourceGroup `
    -Location $Location `
    -SubnetId $snetData.Id

if (-not $nicData) {
    Write-Error "Error: failed to create NIC for vm-data"
    exit 1
}

Write-Host "Creating vm-data..."

$vmDataConfig = New-AzVMConfig -VMName "vm-data" -VMSize "Standard_B2ats_v2" |
    Set-AzVMOperatingSystem -Linux -ComputerName "vm-data" -Credential $credential |
    Set-AzVMSourceImage -PublisherName "Canonical" -Offer "0001-com-ubuntu-server-jammy" -Skus "22_04-lts-gen2" -Version "latest" |
    Add-AzVMNetworkInterface -Id $nicData.Id

New-AzVM -ResourceGroupName $ResourceGroup -Location $Location -VM $vmDataConfig

if (-not $?) {
    Write-Error "Error: failed to create vm-data"
    exit 1
}

Write-Host "Both VMs created successfully"
