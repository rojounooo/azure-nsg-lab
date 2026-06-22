# Usage: .\Create-RG.ps1 <resource-group> <location>

param(
    [string]$ResourceGroup,
    [string]$Location
)

if (-not $ResourceGroup) {
    Write-Error "Error: resource group name is required"
    Write-Host "Usage: .\Create-RG.ps1 <resource-group> <location>"
    exit 1
}

if (-not $Location) {
    Write-Error "Error: location is required"
    Write-Host "Usage: .\Create-RG.ps1 <resource-group> <location>"
    exit 1
}

# Check if resource group already exists
$existing = Get-AzResourceGroup -Name $ResourceGroup -ErrorAction SilentlyContinue
if ($existing) {
    Write-Error "Error: resource group '$ResourceGroup' already exists"
    exit 1
}

Write-Host "Creating resource group '$ResourceGroup' in '$Location'..."

New-AzResourceGroup -Name $ResourceGroup -Location $Location

if (-not $?) {
    Write-Error "Error: failed to create resource group"
    exit 1
}

Write-Host "Resource group '$ResourceGroup' created successfully"
