#Requires -Version 5.1

<#
.SYNOPSIS
    Examples demonstrating advanced Terraform backend management capabilities.

.DESCRIPTION
    This script contains examples showing how to use the DevContainer Template
    modular architecture for sophisticated Terraform backend management scenarios, 
    including cross-subscription backends, validation, and guided setup.

.NOTES
    Author: DevContainer Template
    Version: 1.0
    Requires: DevContainer Template Modular PowerShell Architecture
#>

# Import the required modules
$ModulesPath = Join-Path $PSScriptRoot "..\..\modules"
Import-Module (Join-Path $ModulesPath "CommonModule.psm1") -Force
Import-Module (Join-Path $ModulesPath "AzureModule.psm1") -Force
Import-Module (Join-Path $ModulesPath "InteractiveModule.psm1") -Force

Write-Host "🏗️  DevContainer Backend Management Examples (Modular)" -ForegroundColor Magenta
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Magenta

# Example 1: Basic Backend Creation
Write-Host "`n📝 Example 1: Basic Backend Creation" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan

$example1 = @'
# Create a basic Terraform backend using modular functions
New-AzureTerraformBackend -StorageAccountName "myprojecttfstate" `
                         -ResourceGroupName "terraform-rg" `
                         -ContainerName "tfstate" `
                         -Location "eastus" `
                         -SubscriptionId "your-subscription-id"

# This will:
# 1. Create the resource group if it doesn't exist
# 2. Create the storage account with security settings
# 3. Create the container for state files
# 4. Enable blob versioning and soft delete
'@

Write-Host $example1 -ForegroundColor Gray

# Example 2: Cross-Subscription Backend with Validation
Write-Host "`n📝 Example 2: Cross-Subscription Backend with Validation" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan

$example2 = @'
# Store Terraform state in a different subscription using modular approach
$backendSubscription = "backend-subscription-id"
$projectSubscription = "project-subscription-id"

# Test authentication for both subscriptions
Test-AzureAuthentication -SubscriptionId $backendSubscription
Test-AzureAuthentication -SubscriptionId $projectSubscription

# Create backend in the backend subscription
$backend = New-AzureTerraformBackend -StorageAccountName "enterprisetfstate" `
                                    -ResourceGroupName "shared-terraform-rg" `
                                    -ContainerName "project-states" `
                                    -Location "centralus" `
                                    -SubscriptionId $backendSubscription

# Validate the backend configuration
Test-TerraformBackend -StorageAccountName $backend.StorageAccount `
                     -ResourceGroupName $backend.ResourceGroup `
                     -ContainerName $backend.Container `
                     -SubscriptionId $backendSubscription
'@
$projectSubscription = "12345678-1234-1234-1234-123456789012"
$backendSubscription = "87654321-4321-4321-4321-210987654321"

# Initialize DevContainer with cross-subscription backend
Initialize-DevContainer -ProjectName "webapp-frontend" `
                       -TenantId "your-tenant-id" `
                       -SubscriptionId $projectSubscription `
                       -BackendSubscriptionId $backendSubscription `
                       -CreateBackend `
                       -CreateBackendResourceGroup `
                       -ProjectType "terraform" `
                       -Environment "prod"

# This scenario is useful when:
# - Centralized state management team manages all backends
# - Security requirements isolate state from project resources
# - Different teams own backend vs project subscriptions
'@

Write-Host $example2 -ForegroundColor Gray

# Example 3: Validation Before Creation
Write-Host "`n📝 Example 3: Validation Before Creation" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan

$example3 = @'
# Check if backend exists before proceeding with project setup
$backendConfig = @{
    StorageAccountName = "companytfstate"
    ResourceGroupName = "shared-terraform-rg"
    ContainerName = "tfstate"
    SubscriptionId = "shared-services-subscription-id"
}

# Validate the backend configuration
$validationResult = New-TerraformBackend @backendConfig -ValidateOnly

if ($validationResult.Valid) {
    Write-Host "✅ Backend is ready! Proceeding with DevContainer setup..." -ForegroundColor Green
    
    # Initialize DevContainer using existing backend
    Initialize-DevContainer -ProjectName "my-project" `
                           -TenantId "your-tenant-id" `
                           -SubscriptionId "project-subscription-id" `
                           -BackendSubscriptionId $backendConfig.SubscriptionId `
                           -BackendResourceGroup $backendConfig.ResourceGroupName `
                           -BackendStorageAccount $backendConfig.StorageAccountName `
                           -BackendContainer $backendConfig.ContainerName
} else {
    Write-Host "❌ Backend validation failed. Please check configuration." -ForegroundColor Red
    $validationResult.Issues | ForEach-Object { Write-Host "  • $_" -ForegroundColor Yellow }
}
'@

Write-Host $example3 -ForegroundColor Gray

# Example 4: Interactive Guided Setup
Write-Host "`n📝 Example 4: Interactive Guided Setup" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan

$example4 = @'
# Use the guided setup wizard for complex scenarios
$backendConfig = Invoke-GuidedBackendSetup -ProjectName "enterprise-app" -Location "eastus"

# The wizard will:
# 1. List all available subscriptions
# 2. Let you choose which subscription for the backend
# 3. Suggest appropriate resource names
# 4. Check for existing resources
# 5. Offer to create missing infrastructure
# 6. Return configuration for use with Initialize-DevContainer

# Use the result to initialize your DevContainer
if ($backendConfig.Valid) {
    Initialize-DevContainer -ProjectName "enterprise-app" `
                           -TenantId "your-tenant-id" `
                           -SubscriptionId "project-subscription-id" `
                           -BackendSubscriptionId $backendConfig.SubscriptionId `
                           -BackendResourceGroup $backendConfig.ResourceGroup `
                           -BackendStorageAccount $backendConfig.StorageAccount `
                           -BackendContainer $backendConfig.Container
}
'@

Write-Host $example4 -ForegroundColor Gray

# Example 5: Backend Connectivity Testing
Write-Host "`n📝 Example 5: Backend Connectivity Testing" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan

$example5 = @'
# Perform comprehensive testing of backend infrastructure
$testResults = Test-BackendConnectivity -StorageAccountName "myprojecttfstate" `
                                       -ResourceGroupName "terraform-rg" `
                                       -ContainerName "tfstate" `
                                       -SubscriptionId "your-subscription-id"

# Test results include:
Write-Host "Authentication: $($testResults.Authentication)"
Write-Host "Storage Account Access: $($testResults.StorageAccountAccess)"
Write-Host "Container Access: $($testResults.ContainerAccess)"
Write-Host "Write Permissions: $($testResults.WritePermissions)"
Write-Host "Read Permissions: $($testResults.ReadPermissions)"
Write-Host "Overall Status: $($testResults.OverallStatus)"

# Use this before important deployments to ensure backend is healthy
if (-not $testResults.OverallStatus) {
    Write-Warning "Backend has issues. Review before proceeding with Terraform operations."
    $testResults.Issues | ForEach-Object { Write-Warning "  • $_" }
}
'@

Write-Host $example5 -ForegroundColor Gray

# Example 6: List Available Subscriptions
Write-Host "`n📝 Example 6: List Available Subscriptions" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan

$example6 = @'
# Get all subscriptions accessible to the current user
$subscriptions = Get-AzureSubscriptions

# Display subscription information
foreach ($sub in $subscriptions) {
    $current = if ($sub.IsCurrent) { " (Current)" } else { "" }
    Write-Host "Name: $($sub.Name)$current" -ForegroundColor White
    Write-Host "  ID: $($sub.Id)" -ForegroundColor Gray
    Write-Host "  State: $($sub.State)" -ForegroundColor Gray
    Write-Host ""
}

# Use this to choose the right subscription for your backend
# Especially useful in multi-tenant or enterprise environments
'@

Write-Host $example6 -ForegroundColor Gray

# Example 7: Complete Project Workflow
Write-Host "`n📝 Example 7: Complete Project Workflow" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan

$example7 = @'
# Complete workflow for setting up a new Infrastructure as Code project

# Step 1: Check prerequisites
Test-DevContainerPrerequisites

# Step 2: List available subscriptions to choose from
$subscriptions = Get-AzureSubscriptions
$projectSub = "project-subscription-id"    # Replace with actual ID
$backendSub = "backend-subscription-id"    # Replace with actual ID

# Step 3: Create the project with cross-subscription backend
New-IaCProject -ProjectName "ecommerce-platform" `
               -ProjectPath "C:\Projects" `
               -TenantId "your-tenant-id" `
               -SubscriptionId $projectSub `
               -BackendSubscriptionId $backendSub `
               -ProjectType "terraform" `
               -Environment "dev" `
               -Location "eastus" `
               -InitializeGit `
               -IncludeExamples `
               -CreateBackend

# Step 4: Test the backend connectivity
Test-BackendConnectivity -StorageAccountName "ecommerceplatformtfstate" `
                        -ResourceGroupName "ecommerce-platform-tfstate-rg" `
                        -ContainerName "tfstate" `
                        -SubscriptionId $backendSub

# This creates a complete, production-ready Infrastructure as Code project with:
# - Git repository with proper .gitignore
# - DevContainer with all necessary tools
# - Terraform backend in separate subscription for security
# - Example Terraform files to get started
# - Validated backend connectivity
'@

Write-Host $example7 -ForegroundColor Gray

Write-Host "`n💡 Pro Tips" -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow

$tips = @'
1. Use Get-AzureSubscriptions to discover available subscriptions before setup
2. Cross-subscription backends are ideal for enterprise environments
3. Always validate backend connectivity before important deployments
4. Use the guided setup wizard for complex multi-subscription scenarios
5. Test-BackendConnectivity can help diagnose permission issues
6. Storage account names must be globally unique and alphanumeric only
7. Enable blob versioning and soft delete for production backends (done automatically)
8. Consider using descriptive resource group names for team environments
9. The backend subscription can be different from your project subscription
10. Use consistent naming conventions across your organization
'@

Write-Host $tips -ForegroundColor Gray

Write-Host "`n🔗 Related Commands" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan

$commands = @'
Get-Help Initialize-DevContainer -Full
Get-Help New-TerraformBackend -Full
Get-Help Invoke-GuidedBackendSetup -Full
Get-Help Test-BackendConnectivity -Full
Get-Help Get-AzureSubscriptions -Full
'@

Write-Host $commands -ForegroundColor Gray

Write-Host "`n✨ Ready to get started with advanced backend management!" -ForegroundColor Green
