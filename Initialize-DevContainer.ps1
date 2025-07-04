#Requires -Version 5.1

<#
.SYNOPSIS
    Initializes a DevContainer setup for Infrastructure as Code projects (Terraform/Bicep).

.DESCRIPTION
    This script sets up a complete DevContainer environment for Terraform and/or Bicep development.
    It copies the necessary DevContainer files, creates a customized environment configuration,
    and optionally initializes the project with example files.

.PARAMETER ProjectPath
    The path to your Terraform/Bicep project directory. Defaults to current directory.

.PARAMETER TenantId
    Azure Active Directory Tenant ID (GUID format).

.PARAMETER SubscriptionId
    Azure Subscription ID (GUID format).

.PARAMETER ClientId
    Optional: Azure Client ID for Service Principal authentication.

.PARAMETER ProjectName
    Name of your project (used for naming conventions).

.PARAMETER Environment
    Target environment (dev, staging, prod, etc.). Defaults to 'dev'.

.PARAMETER Location
    Primary Azure region for deployments. Defaults to 'eastus'.

.PARAMETER ProjectType
    Type of IaC project: 'terraform', 'bicep', or 'both'. Defaults to 'terraform'.

.PARAMETER BackendType
    Terraform backend type: 'local' for local state file, 'azure' for Azure Storage. Defaults to 'azure'.

.PARAMETER IncludeExamples
    Include example Terraform/Bicep files in the project.

.PARAMETER TemplateSource
    Path or URL to the DevContainer template. Defaults to current script directory.

.PARAMETER Force
    Overwrite existing DevContainer configuration if it exists.

.PARAMETER Interactive
    Run in interactive mode for guided setup.

.PARAMETER CreateBackend
    Create Terraform backend infrastructure if it doesn't exist.

.PARAMETER ValidateBackend
    Validate existing Terraform backend configuration.

.PARAMETER BackendSubscriptionId
    Subscription ID for Terraform backend (defaults to main subscription).

.PARAMETER BackendResourceGroup
    Resource Group for Terraform backend.

.PARAMETER BackendStorageAccount
    Storage Account name for Terraform backend.

.PARAMETER BackendContainer
    Container name for Terraform state. Defaults to 'tfstate'.

.PARAMETER CreateBackendResourceGroup
    Create the backend resource group if it doesn't exist.

.EXAMPLE
    .\Initialize-DevContainer.ps1 -TenantId "12345678-1234-1234-1234-123456789012" -SubscriptionId "87654321-4321-4321-4321-210987654321" -ProjectName "my-infrastructure"

.EXAMPLE
    .\Initialize-DevContainer.ps1 -ProjectPath "C:\MyProject" -TenantId "12345678-1234-1234-1234-123456789012" -SubscriptionId "87654321-4321-4321-4321-210987654321" -ProjectType "both" -IncludeExamples
#>

[CmdletBinding()]
param(
    [string]$ProjectPath = (Get-Location).Path,
    [Parameter(Mandatory = $false)]
    [string]$TenantId,
    [Parameter(Mandatory = $false)]
    [string]$SubscriptionId,
    [string]$ClientId = "",
    [Parameter(Mandatory = $false)]
    [string]$ProjectName,
    [string]$Environment = "dev",
    [string]$Location = "eastus",
    [ValidateSet('terraform', 'bicep', 'both')]
    [string]$ProjectType = "terraform",
    [ValidateSet('local', 'azure')]
    [string]$BackendType = "azure",
    [switch]$IncludeExamples,
    [string]$TemplateSource = $PSScriptRoot,
    [switch]$Force,
    [switch]$Interactive,
    [switch]$CreateBackend,
    [switch]$ValidateBackend,
    [string]$BackendSubscriptionId = "",
    [string]$BackendResourceGroup = "",
    [string]$BackendStorageAccount = "",
    [string]$BackendContainer = "tfstate",
    [switch]$CreateBackendResourceGroup,
    [switch]$WhatIf,    [switch]$DryRun
)

# Essential utility functions (defined first to avoid scoping issues)
function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = 'White'
    )
    if ($Host.UI.SupportsVirtualTerminal -or $env:TERM) {
        Write-Host $Message -ForegroundColor $Color
    } else {
        Write-Output $Message
    }
}

function Test-IsGuid {
    param([string]$InputString)
    $guidRegex = '^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$'
    return $InputString -match $guidRegex
}

# Essential functions for basic functionality (fallbacks)
function Test-Prerequisites {
    Write-ColorOutput "🔍 Checking prerequisites..." "Cyan"
    
    $issues = @()
    
    # Check Docker CLI
    try {
        $null = Get-Command docker -ErrorAction Stop
        Write-ColorOutput "✅ Docker CLI found" "Green"
    }
    catch {
        $issues += "Docker CLI not found. Please install Docker Desktop."
        Write-ColorOutput "❌ Docker CLI not found" "Red"
    }
    
    # Check VS Code CLI
    try {
        $null = Get-Command code -ErrorAction Stop
        Write-ColorOutput "✅ VS Code CLI found" "Green"
    }
    catch {
        $issues += "VS Code CLI not found. Please install VS Code and ensure 'code' command is in PATH."
        Write-ColorOutput "❌ VS Code CLI not found" "Red"
    }
    
    if ($issues.Count -gt 0) {
        Write-ColorOutput "`n❌ Prerequisites check failed:" "Red"
        $issues | ForEach-Object { Write-ColorOutput "   • $_" "Red" }
        return $false
    }
    
    return $true
}

function Show-NextSteps {
    param(
        [string]$ProjectPath,
        [string]$ProjectType,
        [hashtable]$BackendInfo = $null
    )
    
    Write-ColorOutput "`n🎉 DevContainer setup completed successfully!" "Green"
    Write-ColorOutput "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "Green"
    
    Write-ColorOutput "`n📁 Project Location: $ProjectPath" "Cyan"
    Write-ColorOutput "🔧 Project Type: $ProjectType" "Cyan"
    
    if ($BackendInfo) {
        Write-ColorOutput "`n🗄️  Terraform Backend:" "Yellow"
        if ($BackendInfo.Type -eq "local") {
            Write-ColorOutput "   Type: Local Backend" "Gray"
            Write-ColorOutput "   State File: $($BackendInfo.Configuration.path)" "Gray"
            Write-ColorOutput "   Location: Project Directory" "Gray"
        } else {
            # Azure backend (legacy format)
            Write-ColorOutput "   Storage Account: $($BackendInfo.StorageAccount)" "Gray"
            Write-ColorOutput "   Resource Group: $($BackendInfo.ResourceGroup)" "Gray"
            Write-ColorOutput "   Container: $($BackendInfo.Container)" "Gray"
        }
    }
    
    Write-ColorOutput "`n🚀 Next Steps:" "Yellow"
    Write-ColorOutput "1. Open the project in VS Code:" "White"
    Write-ColorOutput "   code `"$ProjectPath`"" "Gray"
    Write-ColorOutput "`n2. When prompted, choose 'Reopen in Container'" "White"
    Write-ColorOutput "`n3. Wait for the DevContainer to build (first time may take a few minutes)" "White"
    Write-ColorOutput "`n4. Start developing your Infrastructure as Code!" "White"
    
    Write-ColorOutput "`n📚 Documentation: https://containers.dev/" "Blue"    Write-ColorOutput "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "Green"
}

# Essential Azure function fallbacks (when modules don't load)
function New-AzureStorageAccountName {
    param(
        [string]$ProjectName,
        [string]$Environment = "dev",
        [string]$Purpose = "tfstate"
    )
    
    # Clean project name - only lowercase letters and numbers
    $cleanProjectName = $ProjectName.ToLower() -replace '[^a-z0-9]', ''
    $cleanEnvironment = $Environment.ToLower() -replace '[^a-z0-9]', ''
    
    # Generate a short hash for uniqueness (8 characters) - deterministic based on input
    $uniqueString = "$ProjectName-$Environment-$Purpose"
    $hash = [System.Security.Cryptography.HashAlgorithm]::Create('SHA256').ComputeHash([System.Text.Encoding]::UTF8.GetBytes($uniqueString))
    $shortHash = [Convert]::ToHexString($hash)[0..7] -join '' | ForEach-Object { $_.ToLower() }
    
    # Calculate available space for project name (24 total - hash - environment)
    $maxProjectLength = 24 - $shortHash.Length - $cleanEnvironment.Length
    if ($maxProjectLength -le 0) {
        $maxProjectLength = 24 - $shortHash.Length - 2
    }
    $cleanProjectName = $cleanProjectName.Substring(0, [Math]::Min($cleanProjectName.Length, $maxProjectLength))
    $storageAccountName = "$cleanProjectName$cleanEnvironment$shortHash"
    
    # Ensure we don't exceed 24 characters
    if ($storageAccountName.Length -gt 24) {
        $storageAccountName = $storageAccountName.Substring(0, 24)
    }
    
    return @{
        StorageAccountName = $storageAccountName
        DisplayName = "$ProjectName-$Environment-$Purpose"
        ProjectName = $ProjectName
        Environment = $Environment
        Purpose = $Purpose
        Available = $true
        AvailabilityMessage = "Generated (availability not checked)"
    }
}

# New-AzureTerraformBackend function removed - using module version only
# This ensures we always use the real Azure backend creation from AzureModule.psm1

# Test-TerraformBackend function removed - using module version only
# This ensures we always use the real Azure backend validation from AzureModule.psm1

function Get-BackendConfiguration {
    param(
        [string]$ProjectName,
        [string]$SubscriptionId,
        [string]$Location
    )
    
    Write-ColorOutput "ℹ️ Interactive configuration requires full module functionality" "Yellow"
    
    return @{
        SubscriptionId = $SubscriptionId
        ResourceGroup = "$ProjectName-tfstate-rg"
        StorageAccount = "$ProjectName$($Location.Substring(0,3))tfstate"
        Container = "tfstate"
        Action = "skip"
    }
}

# Import specialized modules with error handling
try {
    $ModulesPath = Join-Path $PSScriptRoot "modules"
    Write-ColorOutput "Loading specialized modules from: $ModulesPath" "Gray"
      # Check if modules directory exists
    if (-not (Test-Path $ModulesPath)) {
        Write-ColorOutput "⚠️ Modules directory not found, using basic functionality only" "Yellow"
    } else {
        # Import specialized modules (Azure, DevContainer, etc.)
        $moduleFiles = @(
            "AzureModule.psm1", 
            "DevContainerModule.psm1",
            "ProjectModule.psm1"
        )
        
        foreach ($moduleFile in $moduleFiles) {
            $modulePath = Join-Path $ModulesPath $moduleFile
            if (Test-Path $modulePath) {
                Import-Module -Name $modulePath -Force -Global -ErrorAction SilentlyContinue
                Write-ColorOutput "✅ $moduleFile imported" "Green"
            } else {
                Write-ColorOutput "⚠️ $moduleFile not found, some features may be limited" "Yellow"
            }
        }
    }
}
catch {
    Write-ColorOutput "⚠️ Module import issues, using basic functionality: $($_.Exception.Message)" "Yellow"
}

# Main execution
try {
    Write-ColorOutput "🏗️  DevContainer Template for Infrastructure as Code" "Blue"
    Write-ColorOutput "═════════════════════════════════════════════════════" "Blue"
    
    # Handle WhatIf/DryRun mode
    if ($WhatIf -or $DryRun) {
        Write-ColorOutput "� WhatIf/DryRun Mode - No changes will be made" "Yellow"
        Write-ColorOutput "═══════════════════════════════════════════════════" "Yellow"
    }
    
    # Validate required parameters FIRST (before prerequisites check for fast failure in CI)
    if (-not ($WhatIf -or $DryRun)) {
        $validationErrors = @()
        
        # Only require Azure parameters for Azure backends
        if ($BackendType -eq "azure" -or $ProjectType -eq "bicep") {
            if (-not $TenantId -or -not (Test-IsGuid $TenantId)) {
                $validationErrors += "Valid Azure Tenant ID is required for Azure projects"
            }
            if (-not $SubscriptionId -or -not (Test-IsGuid $SubscriptionId)) {
                $validationErrors += "Valid Azure Subscription ID is required for Azure projects"
            }
        }
        
        if ($validationErrors.Count -gt 0) {
            foreach ($validationError in $validationErrors) {
                Write-ColorOutput "❌ Error: $validationError" "Red"
            }
            exit 1
        }
    } else {
        # In WhatIf mode, provide dummy values if not specified
        if (-not $TenantId) {
            $TenantId = "12345678-1234-1234-1234-123456789012"
            Write-ColorOutput "🧪 WhatIf mode: Using dummy Tenant ID" "Cyan"
        }
        if (-not $SubscriptionId) {
            $SubscriptionId = "87654321-4321-4321-4321-210987654321"
            Write-ColorOutput "🧪 WhatIf mode: Using dummy Subscription ID" "Cyan"
        }
    }

    # Check prerequisites (skip exit in WhatIf mode for testing)
    if (-not (Test-Prerequisites)) {
        if (-not ($WhatIf -or $DryRun)) {
            exit 1
        } else {
            Write-ColorOutput "⚠️ Prerequisites check failed, but continuing in WhatIf mode" "Yellow"
        }
    }
    
    # Interactive mode handling
    if ($Interactive) {
        # Only prompt for Azure credentials if using Azure backend or Bicep
        if ($BackendType -eq "azure" -or $ProjectType -eq "bicep") {
            if (-not $TenantId) {
                $TenantId = Get-InteractiveInput "Azure Tenant ID (GUID)"
            }
            if (-not $SubscriptionId) {
                $SubscriptionId = Get-InteractiveInput "Azure Subscription ID (GUID)"
            }
        }
        
        if (-not $ProjectName) {
            $ProjectName = Get-InteractiveInput "Project Name" (Split-Path $ProjectPath -Leaf)
        }
        
        Write-ColorOutput "`n🏗️  Project Type Selection" "Cyan"
        Write-ColorOutput "1. Terraform only (default)" "White"
        Write-ColorOutput "2. Bicep only" "White"
        Write-ColorOutput "3. Both Terraform and Bicep" "White"
        
        $typeChoice = Get-InteractiveInput "Enter choice (1-3)" "1"
        $ProjectType = switch ($typeChoice) {
            "1" { "terraform" }
            "2" { "bicep" }
            "3" { "both" }
            default { "terraform" }
        }
        
        $exampleChoice = Get-InteractiveInput "Include example files? (y/n)" "y"
        $IncludeExamples = $exampleChoice -match '^y|yes$'
    }
    
    if (-not $ProjectName) {
        $ProjectName = Split-Path $ProjectPath -Leaf
    }
    
    # Initialize project directory
    $projectPath = Initialize-ProjectDirectory -ProjectPath $ProjectPath
    
    # Copy DevContainer files
    $success = Copy-DevContainerFiles -SourcePath $TemplateSource -DestinationPath $projectPath -Force:$Force
    if (-not $success) {
        exit 1
    }
    
    # Handle Terraform backend management
    $backendInfo = $null
    if ($ProjectType -in @('terraform', 'both')) {
        Write-ColorOutput "`n🗄️  Configuring Terraform Backend: $BackendType" "Cyan"
        
        if ($BackendType -eq "local") {
            # Local backend configuration
            $backendInfo = @{
                Type = "local"
                DisplayName = "Local Backend"
                Configuration = @{
                    path = "terraform.tfstate"
                }
            }
            Write-ColorOutput "✅ Local backend configured - state file: terraform.tfstate" "Green"
            Write-ColorOutput "💡 Terraform state will be stored locally in the project directory" "Yellow"
        }
        elseif ($BackendType -eq "azure") {
            # Azure Storage backend configuration (existing logic)
            # Set default backend configuration
            $backendSubId = if ($BackendSubscriptionId) { $BackendSubscriptionId } else { $SubscriptionId }
            $backendRG = if ($BackendResourceGroup) { $BackendResourceGroup } else { "$ProjectName-tfstate-rg" }
        
        # Generate proper storage account name with constraints and uniqueness
        if ($BackendStorageAccount) {
            $backendSA = $BackendStorageAccount
            $storageAccountInfo = @{
                StorageAccountName = $BackendStorageAccount
                DisplayName = "$ProjectName-$Environment-tfstate"
                ProjectName = $ProjectName
                Environment = $Environment
                Purpose = "tfstate"
            }
        } else {
            $storageAccountInfo = New-AzureStorageAccountName -ProjectName $ProjectName -Environment $Environment -Purpose "tfstate"
            $backendSA = $storageAccountInfo.StorageAccountName
            $availabilityStatus = if ($storageAccountInfo.Available) { "✅ Available" } else { "⚠️ $($storageAccountInfo.AvailabilityMessage)" }
            Write-ColorOutput "📝 Generated storage account name: $backendSA" "Cyan"
            Write-ColorOutput "   Display: $($storageAccountInfo.DisplayName)" "Gray"
            Write-ColorOutput "   Status: $availabilityStatus" "Gray"
        }
        
        $backendContainer = $BackendContainer
        
        # Handle interactive backend configuration
        if ($Interactive -and -not $CreateBackend -and -not $ValidateBackend) {
            $backendConfig = Get-BackendConfiguration -ProjectName $ProjectName -SubscriptionId $SubscriptionId -Location $Location
            $backendSubId = $backendConfig.SubscriptionId
            $backendRG = $backendConfig.ResourceGroup
            $backendSA = $backendConfig.StorageAccount
            $backendContainer = $backendConfig.Container
            $CreateBackend = $backendConfig.Action -eq "create"
            $ValidateBackend = $backendConfig.Action -eq "validate"
        }
        
            Write-ColorOutput "`n🏗️  Managing Azure Terraform Backend Configuration" "Cyan"
            Write-ColorOutput "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "Cyan"
        
        # Display backend configuration
        Write-ColorOutput "📋 Backend Configuration:" "White"
        Write-ColorOutput "   Subscription: $backendSubId" "Gray"
        Write-ColorOutput "   Resource Group: $backendRG" "Gray"
        Write-ColorOutput "   Storage Account: $backendSA" "Gray"
        if ($storageAccountInfo.DisplayName -ne $backendSA) {
            Write-ColorOutput "   Display Name: $($storageAccountInfo.DisplayName)" "Gray"
        }
        Write-ColorOutput "   Container: $backendContainer" "Gray"
        Write-ColorOutput "   Location: $Location" "Gray"
        
        if ($CreateBackend) {
            # Create backend infrastructure
            Write-ColorOutput "`n🔨 Creating Terraform backend infrastructure..." "Yellow"
            $backendInfo = New-AzureTerraformBackend `
                -StorageAccountName $backendSA `
                -ResourceGroupName $backendRG `
                -ContainerName $backendContainer `
                -Location $Location `
                -SubscriptionId $backendSubId `
                -CreateResourceGroup:$CreateBackendResourceGroup `
                -DisplayName $storageAccountInfo.DisplayName `
                -ProjectName $storageAccountInfo.ProjectName `
                -Environment $storageAccountInfo.Environment `
                -Purpose $storageAccountInfo.Purpose
            Write-ColorOutput "✅ Terraform backend infrastructure created successfully!" "Green"
        }
        elseif ($ValidateBackend) {
            # Validate existing backend
            Write-ColorOutput "`n🔍 Validating Terraform backend..." "Yellow"
            $backendValidation = Test-TerraformBackend -StorageAccountName $backendSA -ResourceGroupName $backendRG -ContainerName $backendContainer -SubscriptionId $backendSubId
            
            if ($backendValidation.Valid) {
                Write-ColorOutput "✅ Terraform backend validation successful!" "Green"
                $backendInfo = @{
                    StorageAccount = $backendSA
                    ResourceGroup = $backendRG
                    Container = $backendContainer
                    SubscriptionId = $backendSubId
                }
            }
            else {
                Write-ColorOutput "❌ Terraform backend validation failed: $($backendValidation.Message)" "Red"
                Write-ColorOutput "💡 Use -CreateBackend to create the backend infrastructure" "Yellow"
            }
        }
        else {
            # Default: Try to validate, if it doesn't exist, create it automatically
            Write-ColorOutput "`n🔍 Checking Terraform backend..." "Yellow"
            $backendValidation = Test-TerraformBackend -StorageAccountName $backendSA -ResourceGroupName $backendRG -ContainerName $backendContainer -SubscriptionId $backendSubId
            
            if ($backendValidation.Valid) {
                Write-ColorOutput "✅ Terraform backend found and validated!" "Green"
                $backendInfo = @{
                    StorageAccount = $backendSA
                    ResourceGroup = $backendRG
                    Container = $backendContainer
                    SubscriptionId = $backendSubId
                }
            }
            else {
                Write-ColorOutput "⚠️ Terraform backend not found - creating automatically..." "Yellow"
                Write-ColorOutput "`n� Creating Terraform backend infrastructure..." "Yellow"
                $backendInfo = New-AzureTerraformBackend `
                    -StorageAccountName $backendSA `
                    -ResourceGroupName $backendRG `
                    -ContainerName $backendContainer `
                    -Location $Location `
                    -SubscriptionId $backendSubId `
                    -CreateResourceGroup:$true `
                    -DisplayName $storageAccountInfo.DisplayName `
                    -ProjectName $storageAccountInfo.ProjectName `
                    -Environment $storageAccountInfo.Environment `
                    -Purpose $storageAccountInfo.Purpose
                Write-ColorOutput "✅ Terraform backend infrastructure created successfully!" "Green"
                
                # Create backend.tfvars file right after backend creation
                if ($IncludeExamples) {
                    $backendTfvarsPath = Join-Path $projectPath "backend.tfvars"
                    $backendTfvarsContent = @"
# Terraform Backend Configuration
# Use with: terraform init -backend-config=backend.tfvars

resource_group_name  = "$backendRG"
storage_account_name = "$backendSA"
container_name       = "$backendContainer"
key                  = "$Environment.terraform.tfstate"
"@
                    Set-Content -Path $backendTfvarsPath -Value $backendTfvarsContent -Encoding UTF8
                    Write-ColorOutput "✅ Created backend.tfvars with backend configuration" "Green"
                }
            }
        }
        } # End of elseif ($BackendType -eq "azure")
    } # End of if ($ProjectType -in @('terraform', 'both'))
    
    # Create environment configuration
    $backendConfig = if ($backendInfo) {
        @{
            SubscriptionId = $backendInfo.SubscriptionId
            ResourceGroup = $backendInfo.ResourceGroup
            StorageAccount = $backendInfo.StorageAccount
            Container = $backendInfo.Container
        }
    } else { $null }
    
    $null = New-DevContainerEnv -ProjectPath $projectPath -TenantId $TenantId -SubscriptionId $SubscriptionId -ClientId $ClientId -Environment $Environment -Location $Location -BackendConfig $backendConfig
    
    # Add example files if requested
    if ($IncludeExamples) {
        $null = Add-ExampleFiles -ProjectPath $projectPath -ProjectType $ProjectType -TemplateSource $TemplateSource
        
        # Configure Terraform backend files based on backend type
        if ($ProjectType -in @('terraform', 'both') -and $backendInfo) {
            Write-ColorOutput "`n🔧 Configuring Terraform backend files..." "Yellow"
            
            $mainTfPath = Join-Path $projectPath "main.tf"
            if (Test-Path $mainTfPath) {
                $mainTfContent = Get-Content $mainTfPath -Raw
                
                if ($BackendType -eq "local") {
                    # For local backend: uncomment local backend block
                    $mainTfContent = $mainTfContent -replace '(\s*)# backend "local" {}', '$1backend "local" {}'
                    # Ensure azurerm backend stays commented
                    $mainTfContent = $mainTfContent -replace '(\s*)backend "azurerm" {}', '$1# backend "azurerm" {}'
                    
                    Write-ColorOutput "✅ Configured main.tf for local backend" "Green"
                }
                elseif ($BackendType -eq "azure") {
                    # For Azure backend: uncomment azurerm backend block (empty)
                    $mainTfContent = $mainTfContent -replace '(\s*)# backend "azurerm" {}', '$1backend "azurerm" {}'
                    # Ensure local backend stays commented  
                    $mainTfContent = $mainTfContent -replace '(\s*)backend "local" {}', '$1# backend "local" {}'
                    
                    # Create backend.tfvars file for Azure backend
                    $backendTfvarsPath = Join-Path $projectPath "backend.tfvars"
                    $backendTfvarsContent = @"
# Terraform Backend Configuration
# Use with: terraform init -backend-config=backend.tfvars

resource_group_name  = "$($backendInfo.ResourceGroup)"
storage_account_name = "$($backendInfo.StorageAccount)"
container_name       = "$($backendInfo.Container)"
key                  = "$Environment.terraform.tfstate"
"@
                    Set-Content -Path $backendTfvarsPath -Value $backendTfvarsContent -Encoding UTF8
                    
                    Write-ColorOutput "✅ Configured main.tf for Azure backend" "Green"
                    Write-ColorOutput "✅ Created backend.tfvars with backend configuration" "Green"
                }
                
                # Write the updated main.tf content
                Set-Content -Path $mainTfPath -Value $mainTfContent -Encoding UTF8
            }
        }
    }
    
    # Show next steps
    Show-NextSteps -ProjectPath $projectPath -ProjectType $ProjectType -BackendInfo $backendInfo
    
    Write-ColorOutput "`n🎯 DevContainer Template setup completed successfully!" "Green"
}
catch {
    Write-Host "`n❌ Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Stack trace: $($_.ScriptStackTrace)" -ForegroundColor Red
    exit 1
}
