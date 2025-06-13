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

.PARAMETER IncludeExamples
    Include example Terraform/Bicep files in the project.

.PARAMETER TemplateSource
    Path or URL to the DevContainer template. Defaults to current script directory.

.PARAMETER Force
    Overwrite existing DevContainer configuration if it exists.

.EXAMPLE
    .\Initialize-DevContainer.ps1 -TenantId "12345678-1234-1234-1234-123456789012" -SubscriptionId "87654321-4321-4321-4321-210987654321" -ProjectName "my-infrastructure"

.EXAMPLE
    .\Initialize-DevContainer.ps1 -ProjectPath "C:\MyProject" -TenantId "12345678-1234-1234-1234-123456789012" -SubscriptionId "87654321-4321-4321-4321-210987654321" -ProjectType "both" -IncludeExamples

.NOTES
    Author: DevContainer Template
    Version: 1.0
    Requires: PowerShell 5.1+, Docker Desktop (for DevContainer usage)
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$ProjectPath = (Get-Location).Path,

    [Parameter(Mandatory = $true, HelpMessage = "Enter your Azure Tenant ID (GUID)")]
    [ValidatePattern('^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$')]
    [string]$TenantId,

    [Parameter(Mandatory = $true, HelpMessage = "Enter your Azure Subscription ID (GUID)")]
    [ValidatePattern('^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$')]
    [string]$SubscriptionId,

    [Parameter(Mandatory = $false)]
    [ValidatePattern('^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$')]
    [string]$ClientId,

    [Parameter(Mandatory = $true, HelpMessage = "Enter your project name")]
    [ValidatePattern('^[a-zA-Z0-9\-_]+$')]
    [string]$ProjectName,

    [Parameter(Mandatory = $false)]
    [ValidateSet('dev', 'test', 'staging', 'prod', 'sandbox')]
    [string]$Environment = 'dev',

    [Parameter(Mandatory = $false)]
    [ValidateSet('eastus', 'westus', 'westus2', 'centralus', 'northeurope', 'westeurope', 'uksouth', 'ukwest', 'australiaeast', 'southeastasia')]
    [string]$Location = 'eastus',

    [Parameter(Mandatory = $false)]
    [ValidateSet('terraform', 'bicep', 'both')]
    [string]$ProjectType = 'terraform',

    [Parameter(Mandatory = $false)]
    [switch]$IncludeExamples,

    [Parameter(Mandatory = $false)]
    [string]$TemplateSource = $PSScriptRoot,    [Parameter(Mandatory = $false)]
    [switch]$Force,

    # Terraform Backend Management Parameters
    [Parameter(Mandatory = $false)]
    [string]$BackendSubscriptionId,

    [Parameter(Mandatory = $false)]
    [string]$BackendResourceGroup,

    [Parameter(Mandatory = $false)]
    [string]$BackendStorageAccount,

    [Parameter(Mandatory = $false)]
    [string]$BackendContainer = 'tfstate',

    [Parameter(Mandatory = $false)]
    [switch]$CreateBackend,

    [Parameter(Mandatory = $false)]
    [switch]$CreateBackendResourceGroup,

    [Parameter(Mandatory = $false)]
    [switch]$ValidateBackend,

    [Parameter(Mandatory = $false)]
    [switch]$Interactive
)

# Set strict mode for better error handling
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

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

function Test-AzureAuthentication {
    param([string]$SubscriptionId)
    
    try {
        # Check if Azure CLI is available
        $null = Get-Command az -ErrorAction Stop
        
        # Check if logged in
        $accountInfo = az account show --output json 2>$null | ConvertFrom-Json
        if (-not $accountInfo) {
            throw "Not authenticated with Azure CLI. Please run 'az login'"
        }
        
        # Switch to specified subscription if provided
        if ($SubscriptionId -and $accountInfo.id -ne $SubscriptionId) {
            Write-ColorOutput "🔄 Switching to subscription: $SubscriptionId" "Cyan"
            az account set --subscription $SubscriptionId
            if ($LASTEXITCODE -ne 0) {
                throw "Failed to switch to subscription: $SubscriptionId"
            }
        }
        
        return $accountInfo
    }
    catch {
        throw "Azure authentication failed: $($_.Exception.Message)"
    }
}

function Test-AzureStorageAccount {
    param(
        [string]$StorageAccountName,
        [string]$ResourceGroupName,
        [string]$SubscriptionId
    )
      try {
        $null = Test-AzureAuthentication -SubscriptionId $SubscriptionId
        
        Write-ColorOutput "🔍 Checking if storage account '$StorageAccountName' exists..." "Cyan"
        
        $storageAccount = az storage account show --name $StorageAccountName --resource-group $ResourceGroupName --output json 2>$null
        if ($LASTEXITCODE -eq 0 -and $storageAccount) {
            $storageInfo = $storageAccount | ConvertFrom-Json
            Write-ColorOutput "✅ Storage account found: $($storageInfo.name)" "Green"
            return @{
                Exists = $true
                StorageAccount = $storageInfo
                ResourceGroup = $ResourceGroupName
            }
        }
        else {
            Write-ColorOutput "⚠️  Storage account '$StorageAccountName' not found" "Yellow"
            return @{
                Exists = $false
                StorageAccount = $null
                ResourceGroup = $ResourceGroupName
            }
        }
    }
    catch {
        Write-ColorOutput "❌ Error checking storage account: $($_.Exception.Message)" "Red"
        return @{
            Exists = $false
            StorageAccount = $null
            ResourceGroup = $ResourceGroupName
            Error = $_.Exception.Message
        }
    }
}

function Test-AzureStorageContainer {
    param(
        [string]$StorageAccountName,
        [string]$ContainerName,
        [string]$ResourceGroupName,
        [string]$SubscriptionId
    )
    
    try {
        $null = Test-AzureAuthentication -SubscriptionId $SubscriptionId
        
        Write-ColorOutput "🔍 Checking if container '$ContainerName' exists in storage account..." "Cyan"
        
        # Get storage account key
        $keys = az storage account keys list --account-name $StorageAccountName --resource-group $ResourceGroupName --output json | ConvertFrom-Json
        if ($LASTEXITCODE -ne 0 -or -not $keys) {
            throw "Failed to get storage account keys"
        }
        
        $storageKey = $keys[0].value
        
        # Check if container exists
        $container = az storage container show --name $ContainerName --account-name $StorageAccountName --account-key $storageKey --output json 2>$null
        if ($LASTEXITCODE -eq 0 -and $container) {
            $containerInfo = $container | ConvertFrom-Json
            Write-ColorOutput "✅ Container found: $($containerInfo.name)" "Green"
            return @{
                Exists = $true
                Container = $containerInfo
                StorageKey = $storageKey
            }
        }
        else {
            Write-ColorOutput "⚠️  Container '$ContainerName' not found" "Yellow"
            return @{
                Exists = $false
                Container = $null
                StorageKey = $storageKey
            }
        }
    }
    catch {
        Write-ColorOutput "❌ Error checking storage container: $($_.Exception.Message)" "Red"
        return @{
            Exists = $false
            Container = $null
            Error = $_.Exception.Message
        }
    }
}

function New-AzureTerraformBackend {
    param(
        [string]$StorageAccountName,
        [string]$ResourceGroupName,
        [string]$ContainerName,
        [string]$Location,
        [string]$SubscriptionId,
        [switch]$CreateResourceGroup
    )
    
    try {
        $accountInfo = Test-AzureAuthentication -SubscriptionId $SubscriptionId
        
        Write-ColorOutput "🏗️  Creating Terraform backend infrastructure..." "Magenta"
        
        # Check/Create Resource Group
        if ($CreateResourceGroup) {
            Write-ColorOutput "📁 Creating resource group '$ResourceGroupName'..." "Cyan"
            $rgResult = az group create --name $ResourceGroupName --location $Location --output json            if ($LASTEXITCODE -ne 0) {
                throw "Failed to create resource group"
            }
            $resourceGroup = $rgResult | ConvertFrom-Json
            Write-ColorOutput "✅ Resource group created: $($resourceGroup.name)" "Green"
        }
        else {
            # Check if resource group exists
            $null = az group show --name $ResourceGroupName --output json 2>$null
            if ($LASTEXITCODE -ne 0) {
                throw "Resource group '$ResourceGroupName' does not exist. Use -CreateResourceGroup to create it."
            }
        }
        
        # Check if storage account already exists
        $storageCheck = Test-AzureStorageAccount -StorageAccountName $StorageAccountName -ResourceGroupName $ResourceGroupName -SubscriptionId $SubscriptionId
        
        if (-not $storageCheck.Exists) {
            Write-ColorOutput "💾 Creating storage account '$StorageAccountName'..." "Cyan"
            
            $storageResult = az storage account create `
                --name $StorageAccountName `
                --resource-group $ResourceGroupName `
                --location $Location `
                --sku Standard_LRS `
                --kind StorageV2 `
                --access-tier Hot `
                --encryption-services blob `
                --https-only true `
                --min-tls-version TLS1_2 `
                --allow-blob-public-access false `
                --output json
                
            if ($LASTEXITCODE -ne 0) {
                throw "Failed to create storage account"
            }
            
            $storageAccount = $storageResult | ConvertFrom-Json
            Write-ColorOutput "✅ Storage account created: $($storageAccount.name)" "Green"
        }
        else {
            Write-ColorOutput "✅ Using existing storage account: $StorageAccountName" "Green"
            $storageAccount = $storageCheck.StorageAccount
        }
        
        # Check/Create Container
        $containerCheck = Test-AzureStorageContainer -StorageAccountName $StorageAccountName -ContainerName $ContainerName -ResourceGroupName $ResourceGroupName -SubscriptionId $SubscriptionId
          if (-not $containerCheck.Exists) {
            Write-ColorOutput "📦 Creating storage container '$ContainerName'..." "Cyan"
            
            $keys = az storage account keys list --account-name $StorageAccountName --resource-group $ResourceGroupName --output json | ConvertFrom-Json
            $storageKey = $keys[0].value
            
            $null = az storage container create `
                --name $ContainerName `
                --account-name $StorageAccountName `
                --account-key $storageKey `
                --public-access off `
                --output json
                
            if ($LASTEXITCODE -ne 0) {
                throw "Failed to create storage container"
            }
            
            Write-ColorOutput "✅ Storage container created: $ContainerName" "Green"
        }
        else {
            Write-ColorOutput "✅ Using existing storage container: $ContainerName" "Green"
        }
        
        # Enable versioning for better state management
        Write-ColorOutput "🔧 Configuring storage account settings..." "Cyan"
        az storage account blob-service-properties update `
            --account-name $StorageAccountName `
            --resource-group $ResourceGroupName `
            --enable-versioning true `
            --enable-delete-retention true `
            --delete-retention-days 30 `
            --output none
            
        if ($LASTEXITCODE -eq 0) {
            Write-ColorOutput "✅ Enabled blob versioning and soft delete" "Green"
        }
        
        return @{
            Success = $true
            StorageAccount = $StorageAccountName
            ResourceGroup = $ResourceGroupName
            Container = $ContainerName
            Location = $Location
            SubscriptionId = $accountInfo.id
        }
    }
    catch {
        Write-ColorOutput "❌ Failed to create Terraform backend: $($_.Exception.Message)" "Red"
        throw
    }
}

function Test-TerraformBackend {
    param(
        [string]$StorageAccountName,
        [string]$ResourceGroupName,
        [string]$ContainerName,
        [string]$SubscriptionId
    )
    
    try {
        Write-ColorOutput "🔍 Validating Terraform backend configuration..." "Cyan"
        
        # Test authentication
        $accountInfo = Test-AzureAuthentication -SubscriptionId $SubscriptionId
        
        # Test storage account
        $storageCheck = Test-AzureStorageAccount -StorageAccountName $StorageAccountName -ResourceGroupName $ResourceGroupName -SubscriptionId $SubscriptionId
        if (-not $storageCheck.Exists) {
            return @{
                Valid = $false
                Issues = @("Storage account '$StorageAccountName' does not exist")
                StorageAccountExists = $false
                ContainerExists = $false
            }
        }
        
        # Test container
        $containerCheck = Test-AzureStorageContainer -StorageAccountName $StorageAccountName -ContainerName $ContainerName -ResourceGroupName $ResourceGroupName -SubscriptionId $SubscriptionId
        if (-not $containerCheck.Exists) {
            return @{
                Valid = $false
                Issues = @("Storage container '$ContainerName' does not exist")
                StorageAccountExists = $true
                ContainerExists = $false
            }
        }
        
        Write-ColorOutput "✅ Terraform backend configuration is valid" "Green"
        return @{
            Valid = $true
            Issues = @()
            StorageAccountExists = $true
            ContainerExists = $true
            SubscriptionId = $accountInfo.id
        }
    }
    catch {
        return @{
            Valid = $false
            Issues = @("Authentication or access error: $($_.Exception.Message)")
            StorageAccountExists = $false
            ContainerExists = $false
        }
    }
}

function Get-InteractiveInput {
    param(
        [string]$Prompt,
        [string]$DefaultValue = "",
        [switch]$Secure
    )
      $promptText = if ($DefaultValue) {
        "${Prompt} [${DefaultValue}]: "
    } else {
        "${Prompt}: "
    }
    
    if ($Secure) {
        $secureInput = Read-Host -Prompt $promptText -AsSecureString
        $plainText = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureInput))
        $userResponse = $plainText
    } else {
        $userResponse = Read-Host -Prompt $promptText
    }
    
    if ([string]::IsNullOrWhiteSpace($userResponse) -and $DefaultValue) {
        return $DefaultValue
    }
    return $userResponse
}

function Get-BackendConfiguration {
    param(
        [string]$ProjectName,
        [string]$SubscriptionId,
        [string]$Location
    )
    
    Write-ColorOutput "`n🏗️  Terraform Backend Configuration" "Cyan"
    Write-ColorOutput "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "Cyan"
    Write-ColorOutput "Configure Azure Storage for Terraform remote state management." "White"
    
    # Default values based on project
    $defaultRG = "$ProjectName-tfstate-rg"
    $defaultSA = ($ProjectName.ToLower() -replace '[^a-z0-9]', '') + 'tfstate'
    $defaultContainer = 'tfstate'
    
    # Get user input with defaults
    $backendSubId = Get-InteractiveInput "Backend Subscription ID" $SubscriptionId
    $backendRG = Get-InteractiveInput "Resource Group for backend" $defaultRG
    $backendSA = Get-InteractiveInput "Storage Account name" $defaultSA
    $backendContainer = Get-InteractiveInput "Container name" $defaultContainer
    
    Write-ColorOutput "`n🔍 What would you like to do with the backend?" "Yellow"
    Write-ColorOutput "1. Validate existing backend (default)" "White"
    Write-ColorOutput "2. Create backend if it doesn't exist" "White"
    Write-ColorOutput "3. Skip backend setup (configure manually later)" "White"
    
    $choice = Get-InteractiveInput "Enter choice (1-3)" "1"
    
    $action = switch ($choice) {
        "1" { "validate" }
        "2" { "create" }
        "3" { "skip" }
        default { "validate" }
    }
    
    return @{
        SubscriptionId = $backendSubId
        ResourceGroup = $backendRG
        StorageAccount = $backendSA
        Container = $backendContainer
        Action = $action
    }
}

function Test-Prerequisites {
    Write-ColorOutput "🔍 Checking prerequisites..." "Cyan"
    
    # Check if Docker is available
    try {
        $null = Get-Command docker -ErrorAction Stop
        Write-ColorOutput "✅ Docker CLI found" "Green"
    }
    catch {
        Write-ColorOutput "⚠️  Docker CLI not found. DevContainers require Docker Desktop." "Yellow"
        Write-ColorOutput "   Please install Docker Desktop from: https://www.docker.com/products/docker-desktop" "Yellow"
    }

    # Check if VS Code is available
    try {
        $null = Get-Command code -ErrorAction Stop
        Write-ColorOutput "✅ VS Code CLI found" "Green"
    }
    catch {
        Write-ColorOutput "⚠️  VS Code CLI not found. Consider installing VS Code." "Yellow"
        Write-ColorOutput "   Download from: https://code.visualstudio.com/" "Yellow"
    }
}

function Initialize-ProjectDirectory {
    param([string]$Path)
    
    Write-ColorOutput "📁 Initializing project directory: $Path" "Cyan"
    
    if (-not (Test-Path $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
        Write-ColorOutput "✅ Created project directory" "Green"
    }
    
    Set-Location $Path
    
    # Create .devcontainer directory
    $devcontainerPath = Join-Path $Path ".devcontainer"
    if (Test-Path $devcontainerPath) {
        if ($Force) {
            Write-ColorOutput "🔄 Removing existing .devcontainer directory" "Yellow"
            Remove-Item $devcontainerPath -Recurse -Force
        }
        else {
            throw "DevContainer directory already exists. Use -Force to overwrite."
        }
    }
    
    New-Item -ItemType Directory -Path $devcontainerPath -Force | Out-Null
    Write-ColorOutput "✅ Created .devcontainer directory" "Green"
    
    return $devcontainerPath
}

function Copy-DevContainerFiles {
    param(
        [string]$SourcePath,
        [string]$DestinationPath
    )
    
    Write-ColorOutput "📋 Copying DevContainer files..." "Cyan"
    
    $filesToCopy = @(
        'devcontainer.json',
        'Dockerfile',
        'devcontainer.env.example'
    )
    
    foreach ($file in $filesToCopy) {
        $sourcePath = Join-Path $SourcePath $file
        if (Test-Path $sourcePath) {
            Copy-Item $sourcePath $DestinationPath -Force
            Write-ColorOutput "✅ Copied $file" "Green"
        }
        else {
            Write-ColorOutput "⚠️  Warning: $file not found in template source" "Yellow"
        }
    }
    
    # Copy scripts directory if it exists
    $scriptsPath = Join-Path $SourcePath "scripts"
    if (Test-Path $scriptsPath) {
        Copy-Item $scriptsPath $DestinationPath -Recurse -Force
        Write-ColorOutput "✅ Copied scripts directory" "Green"
    }
}

function New-DevContainerEnv {
    param(
        [string]$Path,
        [hashtable]$Config
    )
    
    Write-ColorOutput "⚙️  Creating devcontainer.env file..." "Cyan"
    
    # Determine backend subscription (could be different from main subscription)
    $backendSubId = if ($Config.BackendInfo -and $Config.BackendInfo.SubscriptionId) {
        $Config.BackendInfo.SubscriptionId
    } else {
        $Config.SubscriptionId
    }
    
    # Build the environment content in parts
    $envContent = @"
# DevContainer Environment Configuration
# Generated by Initialize-DevContainer.ps1 on $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')

# ===========================================
# Azure Authentication
# ===========================================
# Your Azure tenant ID (always required)
ARM_TENANT_ID=$($Config.TenantId)

# Azure subscription ID where resources will be deployed (always required)
ARM_SUBSCRIPTION_ID=$($Config.SubscriptionId)

# OPTIONAL: Service Principal or Managed Identity Client ID
# Leave empty to use Azure CLI authentication (recommended for local development)
$(if ($Config.ClientId) { "ARM_CLIENT_ID=$($Config.ClientId)" } else { "# ARM_CLIENT_ID=" })

# OPTIONAL: For service principal authentication (CI/CD only)
# Leave empty to use Azure CLI authentication (recommended for local development)
# ARM_CLIENT_SECRET=your-secret-here

# Authentication methods (in order of precedence):
# 1. Service Principal (if ARM_CLIENT_SECRET is set)
# 2. Azure CLI (if you've run 'az login' - recommended for local dev)
# 3. Managed Identity (when running on Azure services)

# ===========================================
# Terraform Backend Configuration
# ===========================================
"@

    # Add backend configuration based on whether BackendInfo exists
    if ($Config.BackendInfo) {
        $backendSection = @"
# Resource group containing the storage account for Terraform state
TF_BACKEND_RESOURCE_GROUP=$($Config.BackendInfo.ResourceGroup)

# Storage account name for Terraform remote state
TF_BACKEND_STORAGE_ACCOUNT=$($Config.BackendInfo.StorageAccount)

# Container name within the storage account
TF_BACKEND_CONTAINER=$($Config.BackendInfo.Container)

# Blob name for the state file (typically ending in .tfstate)
TF_BACKEND_KEY=$($Config.ProjectName).$($Config.Environment).terraform.tfstate

# Azure region for the backend resources
TF_BACKEND_LOCATION=$($Config.Location)

# Backend subscription (may differ from main subscription)
TF_BACKEND_SUBSCRIPTION_ID=$backendSubId
"@
    } else {
        $backendSection = @"
# Resource group containing the storage account for Terraform state
TF_BACKEND_RESOURCE_GROUP=$($Config.ProjectName)-tfstate-rg

# Storage account name for Terraform remote state
TF_BACKEND_STORAGE_ACCOUNT=$($Config.ProjectName.ToLower() -replace '[^a-z0-9]', '')tfstate

# Container name within the storage account
TF_BACKEND_CONTAINER=tfstate

# Blob name for the state file (typically ending in .tfstate)
TF_BACKEND_KEY=$($Config.ProjectName).$($Config.Environment).terraform.tfstate

# Azure region for the backend resources
TF_BACKEND_LOCATION=$($Config.Location)

# Backend subscription (may differ from main subscription)
TF_BACKEND_SUBSCRIPTION_ID=$($Config.SubscriptionId)
"@
    }

    # Add the rest of the configuration
    $projectSection = @"

# ===========================================
# Project-Specific Terraform Variables
# ===========================================
# These will be available as TF_VAR_* in your Terraform code

# Environment (dev, staging, prod, etc.)
TF_VAR_ENVIRONMENT=$($Config.Environment)

# Project or application name
TF_VAR_PROJECT_NAME=$($Config.ProjectName)

# Primary Azure region for deployments
TF_VAR_LOCATION=$($Config.Location)

# ===========================================
# Tool Versions (Optional Customization)
# ===========================================
TERRAFORM_VERSION=1.10
BICEP_VERSION=latest
TFLINT_VERSION=latest
TERRAFORM_DOCS_VERSION=latest
TERRAGRUNT_VERSION=latest
INSTALL_BICEP=$($Config.InstallBicep)
"@

    # Combine all sections
    $fullEnvContent = $envContent + "`n" + $backendSection + $projectSection

    $envFile = Join-Path $Path "devcontainer.env"
    $fullEnvContent | Out-File -FilePath $envFile -Encoding UTF8
    Write-ColorOutput "✅ Created devcontainer.env file" "Green"
}

function Add-ExampleFiles {
    param(
        [string]$ProjectPath,
        [string]$ProjectType,
        [string]$TemplateSource
    )
    
    Write-ColorOutput "📝 Adding example files..." "Cyan"
    
    $examplesPath = Join-Path $TemplateSource "examples"
    if (-not (Test-Path $examplesPath)) {
        Write-ColorOutput "⚠️  Examples directory not found in template source" "Yellow"
        return
    }
    
    if ($ProjectType -in @('terraform', 'both')) {
        $terraformFiles = @('main.tf', 'variables.tf', 'outputs.tf', 'terraform.tfvars.example')
        foreach ($file in $terraformFiles) {
            $sourcePath = Join-Path $examplesPath $file
            if (Test-Path $sourcePath) {
                Copy-Item $sourcePath $ProjectPath -Force
                Write-ColorOutput "✅ Added Terraform example: $file" "Green"
            }
        }
    }
    
    if ($ProjectType -in @('bicep', 'both')) {
        $bicepFiles = @('main.bicep', 'main.bicepparam', 'bicepconfig.json')
        foreach ($file in $bicepFiles) {
            $sourcePath = Join-Path $examplesPath $file
            if (Test-Path $sourcePath) {
                Copy-Item $sourcePath $ProjectPath -Force
                Write-ColorOutput "✅ Added Bicep example: $file" "Green"
            }
        }
    }
    
    # Add common files
    $commonFiles = @('ps-rule.yaml')
    foreach ($file in $commonFiles) {
        $sourcePath = Join-Path $examplesPath $file
        if (Test-Path $sourcePath) {
            Copy-Item $sourcePath $ProjectPath -Force
            Write-ColorOutput "✅ Added configuration: $file" "Green"
        }
    }
}

function Show-NextSteps {
    param(
        [string]$ProjectPath, 
        [string]$ProjectType,
        [hashtable]$BackendInfo
    )
    
    Write-ColorOutput "`n🎉 DevContainer initialization complete!" "Green"
    Write-ColorOutput "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "Green"
    
    Write-ColorOutput "`n📋 Next Steps:" "Cyan"
    Write-ColorOutput "1. Open your project in VS Code:" "White"
    Write-ColorOutput "   code `"$ProjectPath`"" "Gray"
    
    Write-ColorOutput "`n2. VS Code will detect the DevContainer and prompt to reopen" "White"
    Write-ColorOutput "   Click 'Reopen in Container' when prompted" "Gray"
    
    Write-ColorOutput "`n3. Once inside the container, authenticate with Azure:" "White"
    Write-ColorOutput "   az login" "Gray"
    
    if ($BackendInfo) {
        Write-ColorOutput "`n4. Your Terraform backend is configured:" "White"
        Write-ColorOutput "   Storage Account: $($BackendInfo.StorageAccount)" "Gray"
        Write-ColorOutput "   Resource Group: $($BackendInfo.ResourceGroup)" "Gray"
        Write-ColorOutput "   Container: $($BackendInfo.Container)" "Gray"
    }
    
    if ($ProjectType -in @('terraform', 'both')) {
        Write-ColorOutput "`n5. Initialize Terraform (if you have .tf files):" "White"
        Write-ColorOutput "   terraform init" "Gray"
    }
    
    Write-ColorOutput "`n📁 Files created:" "Cyan"
    Write-ColorOutput "   .devcontainer/devcontainer.json" "Gray"
    Write-ColorOutput "   .devcontainer/Dockerfile" "Gray"
    Write-ColorOutput "   .devcontainer/devcontainer.env" "Gray"
    Write-ColorOutput "   .devcontainer/scripts/" "Gray"
    
    Write-ColorOutput "`n💡 Pro Tips:" "Cyan"
    Write-ColorOutput "   • Use Ctrl+Shift+P → 'Tasks: Run Task' for built-in commands" "Gray"
    Write-ColorOutput "   • Edit .devcontainer/devcontainer.env to customize your setup" "Gray"
    Write-ColorOutput "   • The container includes Terraform, Bicep, Azure CLI, and security tools" "Gray"
    
    if ($BackendInfo) {
        Write-ColorOutput "`n🔧 Backend Management:" "Cyan"
        Write-ColorOutput "   • Your Terraform backend is ready to use" "Gray"
        Write-ColorOutput "   • State files are stored securely in Azure Storage" "Gray"
        Write-ColorOutput "   • Blob versioning and soft delete are enabled" "Gray"
    }
    
    Write-ColorOutput "`n🔗 Documentation:" "Cyan"
    Write-ColorOutput "   • README.md in the DevContainer template for full documentation" "Gray"
    Write-ColorOutput "   • VS Code DevContainer docs: https://code.visualstudio.com/docs/devcontainers/containers" "Gray"
}

# Main execution
try {
    Write-ColorOutput "🚀 DevContainer Accelerator for Infrastructure as Code" "Magenta"
    Write-ColorOutput "═════════════════════════════════════════════════════" "Magenta"
    
    # Test prerequisites
    Test-Prerequisites
    
    # Handle interactive mode if no required parameters provided
    if ($Interactive -or (-not $TenantId -or -not $SubscriptionId -or -not $ProjectName)) {
        Write-ColorOutput "`n🤔 Interactive Mode" "Cyan"
        Write-ColorOutput "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "Cyan"
        
        if (-not $TenantId) {
            do {
                $TenantId = Get-InteractiveInput "Azure Tenant ID (GUID format)"
            } while (-not (Test-IsGuid $TenantId))
        }
        
        if (-not $SubscriptionId) {
            do {
                $SubscriptionId = Get-InteractiveInput "Azure Subscription ID (GUID format)"
            } while (-not (Test-IsGuid $SubscriptionId))
        }
        
        if (-not $ProjectName) {
            do {
                $ProjectName = Get-InteractiveInput "Project Name (alphanumeric, dashes, underscores only)"
            } while ($ProjectName -notmatch '^[a-zA-Z0-9\-_]+$')
        }
        
        if (-not $Environment) {
            $Environment = Get-InteractiveInput "Environment" "dev"
        }
        
        if (-not $Location) {
            $Location = Get-InteractiveInput "Azure Location" "eastus"
        }
        
        if (-not $ProjectType) {
            Write-ColorOutput "`n📋 Project Type:" "Yellow"
            Write-ColorOutput "1. Terraform only" "White"
            Write-ColorOutput "2. Bicep only" "White"
            Write-ColorOutput "3. Both Terraform and Bicep" "White"
            
            $typeChoice = Get-InteractiveInput "Enter choice (1-3)" "1"
            $ProjectType = switch ($typeChoice) {
                "1" { "terraform" }
                "2" { "bicep" }
                "3" { "both" }
                default { "terraform" }
            }
        }
        
        # Ask about examples
        $exampleChoice = Get-InteractiveInput "Include example files? (y/n)" "y"
        $IncludeExamples = $exampleChoice -match '^y|yes$'
    }
    
    # Handle Terraform backend management
    $backendInfo = $null
    if ($ProjectType -in @('terraform', 'both')) {
        # Set default backend configuration
        $backendSubId = if ($BackendSubscriptionId) { $BackendSubscriptionId } else { $SubscriptionId }
        $backendRG = if ($BackendResourceGroup) { $BackendResourceGroup } else { "$ProjectName-tfstate-rg" }
        $backendSA = if ($BackendStorageAccount) { $BackendStorageAccount } else { ($ProjectName.ToLower() -replace '[^a-z0-9]', '') + 'tfstate' }
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
            $CreateBackendResourceGroup = $CreateBackend
        }
        
        Write-ColorOutput "`n🏗️  Managing Terraform Backend Configuration" "Cyan"
        Write-ColorOutput "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "Cyan"
        
        # Display backend configuration
        Write-ColorOutput "📋 Backend Configuration:" "White"
        Write-ColorOutput "   Subscription: $backendSubId" "Gray"
        Write-ColorOutput "   Resource Group: $backendRG" "Gray"
        Write-ColorOutput "   Storage Account: $backendSA" "Gray"
        Write-ColorOutput "   Container: $backendContainer" "Gray"
        Write-ColorOutput "   Location: $Location" "Gray"
        
        if ($CreateBackend) {
            # Create backend infrastructure
            Write-ColorOutput "`n🔨 Creating Terraform backend infrastructure..." "Yellow"
            $backendInfo = New-AzureTerraformBackend -StorageAccountName $backendSA -ResourceGroupName $backendRG -ContainerName $backendContainer -Location $Location -SubscriptionId $backendSubId -CreateResourceGroup:$CreateBackendResourceGroup
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
                    SubscriptionId = $backendValidation.SubscriptionId
                }
            }
            else {
                Write-ColorOutput "❌ Backend validation failed:" "Red"
                foreach ($issue in $backendValidation.Issues) {
                    Write-ColorOutput "   • $issue" "Red"
                }
                Write-ColorOutput "`n💡 Use -CreateBackend to create the backend infrastructure" "Yellow"
                throw "Terraform backend validation failed"
            }
        }
        else {
            # Check if backend exists without creating (default behavior)
            Write-ColorOutput "`n🔍 Checking Terraform backend availability..." "Yellow"
            $backendValidation = Test-TerraformBackend -StorageAccountName $backendSA -ResourceGroupName $backendRG -ContainerName $backendContainer -SubscriptionId $backendSubId
            
            if ($backendValidation.Valid) {
                Write-ColorOutput "✅ Terraform backend is available!" "Green"
                $backendInfo = @{
                    StorageAccount = $backendSA
                    ResourceGroup = $backendRG
                    Container = $backendContainer
                    SubscriptionId = $backendValidation.SubscriptionId
                }
            }
            else {
                Write-ColorOutput "⚠️  Terraform backend infrastructure not found or inaccessible:" "Yellow"
                foreach ($issue in $backendValidation.Issues) {
                    Write-ColorOutput "   • $issue" "Yellow"
                }
                Write-ColorOutput "`n💡 Backend configuration will be created in devcontainer.env" "Yellow"
                Write-ColorOutput "   Use -CreateBackend to create the infrastructure automatically" "Yellow"
                Write-ColorOutput "   Or use -ValidateBackend to ensure it exists before proceeding" "Yellow"
                
                # Set backend info anyway for configuration
                $backendInfo = @{
                    StorageAccount = $backendSA
                    ResourceGroup = $backendRG
                    Container = $backendContainer
                    SubscriptionId = $backendSubId
                }
            }
        }
    }
    
    # Continue with standard DevContainer setup
    Write-ColorOutput "`n🛠️  Setting up DevContainer Environment" "Cyan"
    Write-ColorOutput "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "Cyan"
    
    # Initialize project directory
    $devcontainerPath = Initialize-ProjectDirectory -Path $ProjectPath
    
    # Copy DevContainer files
    Copy-DevContainerFiles -SourcePath $TemplateSource -DestinationPath $devcontainerPath
    
    # Create enhanced configuration with backend info
    $config = @{
        TenantId = $TenantId
        SubscriptionId = $SubscriptionId
        ClientId = $ClientId
        ProjectName = $ProjectName
        Environment = $Environment
        Location = $Location
        InstallBicep = if ($ProjectType -in @('bicep', 'both')) { 'true' } else { 'false' }
        BackendInfo = $backendInfo
    }
    
    New-DevContainerEnv -Path $devcontainerPath -Config $config
    
    # Add example files if requested
    if ($IncludeExamples) {
        Add-ExampleFiles -ProjectPath $ProjectPath -ProjectType $ProjectType -TemplateSource $TemplateSource
    }
    
    # Show next steps
    Show-NextSteps -ProjectPath $ProjectPath -ProjectType $ProjectType -BackendInfo $backendInfo
    
    Write-ColorOutput "`n✨ Success! Your DevContainer environment is ready." "Green"
}
catch {
    Write-ColorOutput "`n❌ Error: $($_.Exception.Message)" "Red"
    Write-ColorOutput "Stack trace: $($_.ScriptStackTrace)" "Red"
    exit 1
}
