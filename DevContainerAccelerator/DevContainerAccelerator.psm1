#Requires -Version 5.1

<#
.SYNOPSIS
    DevContainer Accelerator PowerShell Module for Infrastructure as Code projects.

.DESCRIPTION
    This module provides functions to quickly set up DevContainer environments for
    Terraform and Bicep development, with Azure authentication, project scaffolding,
    and Terraform backend management.
#>

# Module variables
$script:ModuleRoot = $PSScriptRoot

#region Helper Functions

function Write-ColorOutput {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,
        
        [Parameter(Mandatory = $false)]
        [ValidateSet('Black', 'DarkBlue', 'DarkGreen', 'DarkCyan', 'DarkRed', 'DarkMagenta', 'DarkYellow', 'Gray', 'DarkGray', 'Blue', 'Green', 'Cyan', 'Red', 'Magenta', 'Yellow', 'White')]
        [string]$Color = 'White'
    )
    
    if ($Host.UI.SupportsVirtualTerminal -or $env:TERM) {
        Write-Host $Message -ForegroundColor $Color
    } else {
        Write-Output $Message
    }
}

function Test-IsGuid {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$InputString
    )
    
    $guidRegex = '^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$'
    return $InputString -match $guidRegex
}

function Get-TemplateFiles {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$TemplatePath
    )
    
    $templateFiles = @{
        Required = @('devcontainer.json', 'Dockerfile')
        Optional = @('devcontainer.env.example', 'scripts')
        Examples = @('examples')
    }
    
    $result = @{
        Valid = $true
        MissingRequired = @()
        FoundFiles = @()
    }
    
    foreach ($file in $templateFiles.Required) {
        $filePath = Join-Path $TemplatePath $file
        if (Test-Path $filePath) {
            $result.FoundFiles += $file
        } else {
            $result.MissingRequired += $file
            $result.Valid = $false
        }
    }
    
    foreach ($file in ($templateFiles.Optional + $templateFiles.Examples)) {
        $filePath = Join-Path $TemplatePath $file
        if (Test-Path $filePath) {
            $result.FoundFiles += $file
        }
    }
    
    return $result
}

function Test-AzureAuthentication {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string]$SubscriptionId
    )
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
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$StorageAccountName,
        
        [Parameter(Mandatory = $true)]
        [string]$ResourceGroupName,
        
        [Parameter(Mandatory = $false)]
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
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$StorageAccountName,
        
        [Parameter(Mandatory = $true)]
        [string]$ContainerName,
        
        [Parameter(Mandatory = $true)]
        [string]$ResourceGroupName,
        
        [Parameter(Mandatory = $false)]
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
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$StorageAccountName,
        
        [Parameter(Mandatory = $true)]
        [string]$ResourceGroupName,
        
        [Parameter(Mandatory = $true)]
        [string]$ContainerName,
        
        [Parameter(Mandatory = $true)]
        [string]$Location,
        
        [Parameter(Mandatory = $false)]
        [string]$SubscriptionId,
        
        [Parameter(Mandatory = $false)]
        [switch]$CreateResourceGroup
    )
    
    try {
        $accountInfo = Test-AzureAuthentication -SubscriptionId $SubscriptionId
        
        Write-ColorOutput "🏗️  Creating Terraform backend infrastructure..." "Magenta"
          # Check/Create Resource Group
        if ($CreateResourceGroup) {
            Write-ColorOutput "📁 Creating resource group '$ResourceGroupName'..." "Cyan"
            $rgResult = az group create --name $ResourceGroupName --location $Location --output json
            if ($LASTEXITCODE -ne 0) {
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
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$StorageAccountName,
        
        [Parameter(Mandatory = $true)]
        [string]$ResourceGroupName,
        
        [Parameter(Mandatory = $true)]
        [string]$ContainerName,
        
        [Parameter(Mandatory = $false)]
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

function Initialize-ProjectDirectory {
    [CmdletBinding()]
    param(
        [string]$Path,
        [switch]$Force
    )
    
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
    [CmdletBinding()]
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
    [CmdletBinding()]
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
# Generated by DevContainer Accelerator on $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')

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
    [CmdletBinding()]
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
    [CmdletBinding()]
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
}

#endregion

#region Public Functions

function Test-DevContainerPrerequisites {
    <#
    .SYNOPSIS
        Tests if the system has the required prerequisites for DevContainer development.
    
    .DESCRIPTION
        Checks for Docker, VS Code, and other tools required for DevContainer development.
    
    .EXAMPLE
        Test-DevContainerPrerequisites
        
        Checks all prerequisites and displays the results.
    #>
    [CmdletBinding()]
    param()
    
    Write-ColorOutput "🔍 Checking DevContainer prerequisites..." "Cyan"
    
    $prerequisites = @{
        Docker = @{
            Command = 'docker'
            Name = 'Docker Desktop'
            Url = 'https://www.docker.com/products/docker-desktop'
            Required = $true
        }
        VSCode = @{
            Command = 'code'
            Name = 'Visual Studio Code'
            Url = 'https://code.visualstudio.com/'
            Required = $false
        }
        Git = @{
            Command = 'git'
            Name = 'Git'
            Url = 'https://git-scm.com/'
            Required = $false
        }
        AzureCLI = @{
            Command = 'az'
            Name = 'Azure CLI'
            Url = 'https://docs.microsoft.com/en-us/cli/azure/install-azure-cli'
            Required = $false
        }
    }
    
    $results = @{}
    $allGood = $true
    
    foreach ($tool in $prerequisites.Keys) {
        $prereq = $prerequisites[$tool]
        try {
            $null = Get-Command $prereq.Command -ErrorAction Stop
            Write-ColorOutput "✅ $($prereq.Name) - Found" "Green"
            $results[$tool] = $true
        }
        catch {
            $status = if ($prereq.Required) { "❌" } else { "⚠️" }
            $color = if ($prereq.Required) { "Red" } else { "Yellow" }
            Write-ColorOutput "$status $($prereq.Name) - Not found" $color
            Write-ColorOutput "   Install from: $($prereq.Url)" "Gray"
            $results[$tool] = $false
            
            if ($prereq.Required) {
                $allGood = $false
            }
        }
    }
    
    if ($allGood) {
        Write-ColorOutput "`n🎉 All required prerequisites are installed!" "Green"
    } else {
        Write-ColorOutput "`n⚠️  Some required prerequisites are missing." "Yellow"
    }
    
    return $results
}

function New-TerraformBackend {
    <#
    .SYNOPSIS
        Creates Azure storage infrastructure for Terraform remote state.
    
    .DESCRIPTION
        Creates the necessary Azure storage account and container for storing Terraform state files.
        Supports both same-subscription and cross-subscription scenarios.
    
    .PARAMETER StorageAccountName
        Name of the storage account to create or validate.
    
    .PARAMETER ResourceGroupName
        Name of the resource group containing the storage account.
    
    .PARAMETER ContainerName
        Name of the storage container for state files.
    
    .PARAMETER Location
        Azure region for the storage account.
    
    .PARAMETER SubscriptionId
        Optional: Azure subscription ID. If not specified, uses current context.
    
    .PARAMETER CreateResourceGroup
        Create the resource group if it doesn't exist.
    
    .PARAMETER ValidateOnly
        Only validate existing infrastructure without creating anything.
    
    .EXAMPLE
        New-TerraformBackend -StorageAccountName "myprojecttfstate" -ResourceGroupName "terraform-rg" -ContainerName "tfstate" -Location "eastus" -CreateResourceGroup
    
    .EXAMPLE
        New-TerraformBackend -StorageAccountName "myprojecttfstate" -ResourceGroupName "terraform-rg" -ContainerName "tfstate" -SubscriptionId "different-sub-id" -ValidateOnly
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$StorageAccountName,
        
        [Parameter(Mandatory = $true)]
        [string]$ResourceGroupName,
        
        [Parameter(Mandatory = $true)]
        [string]$ContainerName,
        
        [Parameter(Mandatory = $false)]
        [string]$Location = 'eastus',
        
        [Parameter(Mandatory = $false)]
        [string]$SubscriptionId,
        
        [Parameter(Mandatory = $false)]
        [switch]$CreateResourceGroup,
        
        [Parameter(Mandatory = $false)]
        [switch]$ValidateOnly
    )
    
    if ($ValidateOnly) {
        return Test-TerraformBackend -StorageAccountName $StorageAccountName -ResourceGroupName $ResourceGroupName -ContainerName $ContainerName -SubscriptionId $SubscriptionId
    } else {
        return New-AzureTerraformBackend -StorageAccountName $StorageAccountName -ResourceGroupName $ResourceGroupName -ContainerName $ContainerName -Location $Location -SubscriptionId $SubscriptionId -CreateResourceGroup:$CreateResourceGroup
    }
}

function Initialize-DevContainer {
    <#
    .SYNOPSIS
        Initializes a DevContainer setup for Infrastructure as Code projects.
    
    .DESCRIPTION
        Sets up a complete DevContainer environment for Terraform and/or Bicep development
        with Azure authentication, project-specific configuration, and Terraform backend management.
    
    .PARAMETER ProjectPath
        The path to your project directory. Defaults to current directory.
    
    .PARAMETER TenantId
        Azure Active Directory Tenant ID (GUID format).
    
    .PARAMETER SubscriptionId
        Azure Subscription ID (GUID format) for project resources.
    
    .PARAMETER ClientId
        Optional: Azure Client ID for Service Principal authentication.
    
    .PARAMETER ProjectName
        Name of your project (used for naming conventions).
    
    .PARAMETER Environment
        Target environment (dev, staging, prod, etc.).
    
    .PARAMETER Location
        Primary Azure region for deployments.
    
    .PARAMETER ProjectType
        Type of IaC project: 'terraform', 'bicep', or 'both'.
    
    .PARAMETER IncludeExamples
        Include example Terraform/Bicep files in the project.
    
    .PARAMETER TemplateSource
        Path to the DevContainer template. Defaults to module directory.
    
    .PARAMETER Force
        Overwrite existing DevContainer configuration.
    
    .PARAMETER BackendSubscriptionId
        Optional: Different subscription ID for Terraform backend storage. If not specified, uses SubscriptionId.
    
    .PARAMETER BackendResourceGroup
        Optional: Custom resource group name for Terraform backend. If not specified, uses project-based naming.
    
    .PARAMETER BackendStorageAccount
        Optional: Custom storage account name for Terraform backend. If not specified, uses project-based naming.
    
    .PARAMETER BackendContainer
        Optional: Custom container name for Terraform backend. Defaults to 'tfstate'.
    
    .PARAMETER CreateBackend
        Create the Terraform backend infrastructure if it doesn't exist.
    
    .PARAMETER CreateBackendResourceGroup
        Create the backend resource group if it doesn't exist (only when CreateBackend is used).
    
    .PARAMETER ValidateBackend
        Validate that the Terraform backend exists and is accessible.
    
    .EXAMPLE
        Initialize-DevContainer -TenantId "12345678-1234-1234-1234-123456789012" -SubscriptionId "87654321-4321-4321-4321-210987654321" -ProjectName "my-infrastructure"
    
    .EXAMPLE
        Initialize-DevContainer -ProjectPath "C:\MyProject" -TenantId "12345678-1234-1234-1234-123456789012" -SubscriptionId "87654321-4321-4321-4321-210987654321" -ProjectType "both" -IncludeExamples -CreateBackend
    
    .EXAMPLE
        Initialize-DevContainer -ProjectName "webapp" -TenantId "..." -SubscriptionId "..." -BackendSubscriptionId "different-sub-id" -CreateBackend -CreateBackendResourceGroup
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string]$ProjectPath = (Get-Location).Path,

        [Parameter(Mandatory = $true, HelpMessage = "Enter your Azure Tenant ID (GUID)")]
        [string]$TenantId,

        [Parameter(Mandatory = $true, HelpMessage = "Enter your Azure Subscription ID (GUID)")]
        [string]$SubscriptionId,

        [Parameter(Mandatory = $false)]
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
        [string]$TemplateSource,

        [Parameter(Mandatory = $false)]
        [switch]$Force,

        # Backend management parameters
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
        [switch]$ValidateBackend
    )

    # Validate GUIDs
    if (-not (Test-IsGuid $TenantId)) {
        throw "TenantId must be a valid GUID format"
    }
    
    if (-not (Test-IsGuid $SubscriptionId)) {
        throw "SubscriptionId must be a valid GUID format"
    }
    
    if ($ClientId -and -not (Test-IsGuid $ClientId)) {
        throw "ClientId must be a valid GUID format"
    }

    if ($BackendSubscriptionId -and -not (Test-IsGuid $BackendSubscriptionId)) {
        throw "BackendSubscriptionId must be a valid GUID format"
    }

    # Set default backend configuration
    $backendSubId = if ($BackendSubscriptionId) { $BackendSubscriptionId } else { $SubscriptionId }
    $backendRG = if ($BackendResourceGroup) { $BackendResourceGroup } else { "$ProjectName-tfstate-rg" }
    $backendSA = if ($BackendStorageAccount) { $BackendStorageAccount } else { ($ProjectName.ToLower() -replace '[^a-z0-9]', '') + 'tfstate' }

    # Determine template source
    if (-not $TemplateSource) {
        $TemplateSource = Split-Path $script:ModuleRoot -Parent
    }

    # Validate template source
    $templateValidation = Get-TemplateFiles -TemplatePath $TemplateSource
    if (-not $templateValidation.Valid) {
        throw "Template source is missing required files: $($templateValidation.MissingRequired -join ', ')"
    }

    try {
        Write-ColorOutput "🚀 DevContainer Accelerator for Infrastructure as Code" "Magenta"
        Write-ColorOutput "═════════════════════════════════════════════════════" "Magenta"
        
        # Handle Terraform backend management
        $backendInfo = $null
        if ($ProjectType -in @('terraform', 'both')) {
            Write-ColorOutput "`n🏗️  Managing Terraform Backend Configuration" "Cyan"
            Write-ColorOutput "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "Cyan"
            
            # Display backend configuration
            Write-ColorOutput "📋 Backend Configuration:" "White"
            Write-ColorOutput "   Subscription: $backendSubId" "Gray"
            Write-ColorOutput "   Resource Group: $backendRG" "Gray"
            Write-ColorOutput "   Storage Account: $backendSA" "Gray"
            Write-ColorOutput "   Container: $BackendContainer" "Gray"
            Write-ColorOutput "   Location: $Location" "Gray"
            
            if ($CreateBackend) {
                # Create backend infrastructure
                Write-ColorOutput "`n🔨 Creating Terraform backend infrastructure..." "Yellow"
                $backendInfo = New-AzureTerraformBackend -StorageAccountName $backendSA -ResourceGroupName $backendRG -ContainerName $BackendContainer -Location $Location -SubscriptionId $backendSubId -CreateResourceGroup:$CreateBackendResourceGroup
                Write-ColorOutput "✅ Terraform backend infrastructure created successfully!" "Green"
            }
            elseif ($ValidateBackend) {
                # Validate existing backend
                Write-ColorOutput "`n🔍 Validating Terraform backend..." "Yellow"
                $backendValidation = Test-TerraformBackend -StorageAccountName $backendSA -ResourceGroupName $backendRG -ContainerName $BackendContainer -SubscriptionId $backendSubId
                
                if ($backendValidation.Valid) {
                    Write-ColorOutput "✅ Terraform backend validation successful!" "Green"
                    $backendInfo = @{
                        StorageAccount = $backendSA
                        ResourceGroup = $backendRG
                        Container = $BackendContainer
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
                # Check if backend exists without creating
                Write-ColorOutput "`n🔍 Checking Terraform backend availability..." "Yellow"
                $backendValidation = Test-TerraformBackend -StorageAccountName $backendSA -ResourceGroupName $backendRG -ContainerName $BackendContainer -SubscriptionId $backendSubId
                
                if ($backendValidation.Valid) {
                    Write-ColorOutput "✅ Terraform backend is available!" "Green"
                    $backendInfo = @{
                        StorageAccount = $backendSA
                        ResourceGroup = $backendRG
                        Container = $BackendContainer
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
                        Container = $BackendContainer
                        SubscriptionId = $backendSubId
                    }
                }
            }
        }

        # Continue with standard DevContainer setup
        Write-ColorOutput "`n🛠️  Setting up DevContainer Environment" "Cyan"
        Write-ColorOutput "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "Cyan"
        
        # Initialize project directory and copy files
        $devcontainerPath = Initialize-ProjectDirectory -Path $ProjectPath -Force:$Force
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
        
        Write-ColorOutput "`n✨ DevContainer initialization completed successfully!" "Green"
        
    }
    catch {
        Write-ColorOutput "❌ Error initializing DevContainer: $($_.Exception.Message)" "Red"
        throw
    }
}

function New-IaCProject {
    <#
    .SYNOPSIS
        Creates a new Infrastructure as Code project with DevContainer setup.
    
    .DESCRIPTION
        Creates a new directory, initializes it as a Git repository, and sets up
        a complete DevContainer environment for Infrastructure as Code development.
    
    .PARAMETER ProjectName
        Name of the new project (will be used as directory name).
    
    .PARAMETER ProjectPath
        Parent directory where the project will be created. Defaults to current directory.
    
    .PARAMETER TenantId
        Azure Active Directory Tenant ID.
    
    .PARAMETER SubscriptionId
        Azure Subscription ID.
    
    .PARAMETER ProjectType
        Type of IaC project: 'terraform', 'bicep', or 'both'.
    
    .PARAMETER Environment
        Target environment (dev, staging, prod, etc.).
    
    .PARAMETER Location
        Primary Azure region for deployments.
    
    .PARAMETER InitializeGit
        Initialize the project as a Git repository.
    
    .PARAMETER IncludeExamples
        Include example Terraform/Bicep files.
    
    .PARAMETER CreateBackend
        Create the Terraform backend infrastructure.
    
    .PARAMETER BackendSubscriptionId
        Optional: Different subscription ID for Terraform backend storage.
    
    .EXAMPLE
        New-IaCProject -ProjectName "my-infrastructure" -TenantId "12345678-1234-1234-1234-123456789012" -SubscriptionId "87654321-4321-4321-4321-210987654321"
    
    .EXAMPLE
        New-IaCProject -ProjectName "azure-webapp" -ProjectPath "C:\Projects" -ProjectType "both" -InitializeGit -IncludeExamples -CreateBackend
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidatePattern('^[a-zA-Z0-9\-_]+$')]
        [string]$ProjectName,

        [Parameter(Mandatory = $false)]
        [string]$ProjectPath = (Get-Location).Path,

        [Parameter(Mandatory = $true)]
        [string]$TenantId,

        [Parameter(Mandatory = $true)]
        [string]$SubscriptionId,

        [Parameter(Mandatory = $false)]
        [ValidateSet('terraform', 'bicep', 'both')]
        [string]$ProjectType = 'terraform',

        [Parameter(Mandatory = $false)]
        [ValidateSet('dev', 'test', 'staging', 'prod', 'sandbox')]
        [string]$Environment = 'dev',

        [Parameter(Mandatory = $false)]
        [string]$Location = 'eastus',

        [Parameter(Mandatory = $false)]
        [switch]$InitializeGit,

        [Parameter(Mandatory = $false)]
        [switch]$IncludeExamples,

        [Parameter(Mandatory = $false)]
        [switch]$CreateBackend,

        [Parameter(Mandatory = $false)]
        [string]$BackendSubscriptionId
    )

    $fullProjectPath = Join-Path $ProjectPath $ProjectName
    
    Write-ColorOutput "🏗️  Creating new IaC project: $ProjectName" "Cyan"
    
    # Create project directory
    if (Test-Path $fullProjectPath) {
        throw "Project directory '$fullProjectPath' already exists"
    }
    
    New-Item -ItemType Directory -Path $fullProjectPath -Force | Out-Null
    Write-ColorOutput "✅ Created project directory" "Green"
    
    # Initialize Git repository if requested
    if ($InitializeGit) {
        Push-Location $fullProjectPath
        try {
            git init
            Write-ColorOutput "✅ Initialized Git repository" "Green"
            
            # Create .gitignore
            $gitignoreContent = @'
# Terraform
*.tfstate
*.tfstate.*
.terraform/
.terraform.lock.hcl
*.tfvars
!*.tfvars.example

# Bicep
*.bicep.json

# Azure
.azure/

# DevContainer
.devcontainer/devcontainer.env

# IDE
.vscode/settings.json
.idea/

# OS
.DS_Store
Thumbs.db

# Logs
*.log
'@
            $gitignoreContent | Out-File -FilePath ".gitignore" -Encoding UTF8
            Write-ColorOutput "✅ Created .gitignore" "Green"
        }
        finally {
            Pop-Location
        }
    }
    
    # Initialize DevContainer
    $initParams = @{
        ProjectPath = $fullProjectPath
        TenantId = $TenantId
        SubscriptionId = $SubscriptionId
        ProjectName = $ProjectName
        Environment = $Environment
        Location = $Location
        ProjectType = $ProjectType
        IncludeExamples = $IncludeExamples
        CreateBackend = $CreateBackend
        CreateBackendResourceGroup = $CreateBackend
    }

    if ($BackendSubscriptionId) {
        $initParams.BackendSubscriptionId = $BackendSubscriptionId
    }
    
    Initialize-DevContainer @initParams
    
    Write-ColorOutput "`n🎉 New IaC project '$ProjectName' created successfully!" "Green"
    Write-ColorOutput "📁 Project location: $fullProjectPath" "Gray"
}

function Update-DevContainerTemplate {
    <#
    .SYNOPSIS
        Updates the DevContainer template files in an existing project.
    
    .DESCRIPTION
        Updates DevContainer configuration files while preserving custom environment settings.
    
    .PARAMETER ProjectPath
        Path to the project containing the DevContainer to update.
    
    .PARAMETER TemplateSource
        Path to the updated template source.
    
    .PARAMETER PreserveEnv
        Preserve existing devcontainer.env file.
    
    .PARAMETER BackupExisting
        Create backup of existing DevContainer files.
    
    .EXAMPLE
        Update-DevContainerTemplate -ProjectPath "C:\MyProject" -PreserveEnv
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string]$ProjectPath = (Get-Location).Path,

        [Parameter(Mandatory = $false)]
        [string]$TemplateSource,

        [Parameter(Mandatory = $false)]
        [switch]$PreserveEnv,

        [Parameter(Mandatory = $false)]
        [switch]$BackupExisting
    )

    $devcontainerPath = Join-Path $ProjectPath ".devcontainer"
    
    if (-not (Test-Path $devcontainerPath)) {
        throw "No DevContainer found in project path: $ProjectPath"
    }

    Write-ColorOutput "🔄 Updating DevContainer template..." "Cyan"
    
    # Determine template source
    if (-not $TemplateSource) {
        $TemplateSource = Split-Path $script:ModuleRoot -Parent
    }

    # Backup existing files if requested
    if ($BackupExisting) {
        $backupPath = Join-Path $devcontainerPath "backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
        New-Item -ItemType Directory -Path $backupPath -Force | Out-Null
        
        Get-ChildItem $devcontainerPath -File | ForEach-Object {
            Copy-Item $_.FullName $backupPath -Force
        }
        Write-ColorOutput "✅ Created backup at: $backupPath" "Green"
    }

    # Update files
    $filesToUpdate = @('devcontainer.json', 'Dockerfile')
    if (-not $PreserveEnv) {
        $filesToUpdate += 'devcontainer.env.example'
    }

    foreach ($file in $filesToUpdate) {
        $sourcePath = Join-Path $TemplateSource $file
        if (Test-Path $sourcePath) {
            Copy-Item $sourcePath $devcontainerPath -Force
            Write-ColorOutput "✅ Updated $file" "Green"
        }
    }

    # Update scripts directory
    $scriptsPath = Join-Path $TemplateSource "scripts"
    if (Test-Path $scriptsPath) {
        $destScriptsPath = Join-Path $devcontainerPath "scripts"
        if (Test-Path $destScriptsPath) {
            Remove-Item $destScriptsPath -Recurse -Force
        }
        Copy-Item $scriptsPath $devcontainerPath -Recurse -Force
        Write-ColorOutput "✅ Updated scripts directory" "Green"
    }

    Write-ColorOutput "🎉 DevContainer template updated successfully!" "Green"
}

#endregion

#region Additional Helper Functions

function Get-AzureSubscriptions {
    <#
    .SYNOPSIS
        Lists all available Azure subscriptions for the authenticated user.
    
    .DESCRIPTION
        Retrieves all Azure subscriptions accessible to the current authenticated user.
        Useful for selecting the right subscription for projects or backend storage.
    
    .EXAMPLE
        Get-AzureSubscriptions
        
        Lists all available subscriptions with names and IDs.
    #>
    [CmdletBinding()]
    param()
    
    try {
        # Check if Azure CLI is available
        $null = Get-Command az -ErrorAction Stop
        
        # Check if logged in
        $accountInfo = az account show --output json 2>$null | ConvertFrom-Json
        if (-not $accountInfo) {
            throw "Not authenticated with Azure CLI. Please run 'az login'"
        }
        
        Write-ColorOutput "📋 Available Azure Subscriptions:" "Cyan"
        
        $subscriptions = az account list --output json | ConvertFrom-Json
        if (-not $subscriptions) {
            throw "No subscriptions found or failed to retrieve subscription list"
        }
        
        $results = @()
        foreach ($sub in $subscriptions) {
            $status = if ($sub.id -eq $accountInfo.id) { "✅ (Current)" } else { "  " }
            Write-ColorOutput "$status Name: $($sub.name)" "White"
            Write-ColorOutput "   ID: $($sub.id)" "Gray"
            Write-ColorOutput "   State: $($sub.state)" "Gray"
            Write-ColorOutput "" "White"
            
            $results += @{
                Name = $sub.name
                Id = $sub.id
                State = $sub.state
                IsCurrent = ($sub.id -eq $accountInfo.id)
            }
        }
        
        return $results
    }
    catch {
        Write-ColorOutput "❌ Error retrieving subscriptions: $($_.Exception.Message)" "Red"
        throw
    }
}

function Invoke-GuidedBackendSetup {
    <#
    .SYNOPSIS
        Provides an interactive guided setup for Terraform backend configuration.
    
    .DESCRIPTION
        Interactive wizard to help users configure Terraform remote state backend,
        including subscription selection, resource naming, and creation options.
    
    .PARAMETER ProjectName
        The name of the project (used for default naming).
    
    .PARAMETER Location
        The Azure region for backend resources.
    
    .EXAMPLE
        Invoke-GuidedBackendSetup -ProjectName "my-infrastructure" -Location "eastus"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ProjectName,
        
        [Parameter(Mandatory = $false)]
        [string]$Location = 'eastus'
    )
    
    Write-ColorOutput "`n🧭 Guided Terraform Backend Setup" "Magenta"
    Write-ColorOutput "═══════════════════════════════════════════════════════" "Magenta"
    Write-ColorOutput "This wizard will help you configure Azure Storage for Terraform remote state." "White"
    
    # Step 1: List and select subscription
    Write-ColorOutput "`n📋 Step 1: Select Azure Subscription" "Cyan"
    try {
        $subscriptions = Get-AzureSubscriptions
        
        Write-ColorOutput "`nChoose a subscription for your Terraform backend:" "Yellow"
        for ($i = 0; $i -lt $subscriptions.Count; $i++) {
            $current = if ($subscriptions[$i].IsCurrent) { " (Current)" } else { "" }
            Write-ColorOutput "$($i + 1). $($subscriptions[$i].Name)$current" "White"
            Write-ColorOutput "    ID: $($subscriptions[$i].Id)" "Gray"
        }
        
        do {
            $choice = Read-Host "`nEnter subscription number (1-$($subscriptions.Count))"
            $selectedIndex = [int]$choice - 1
        } while ($selectedIndex -lt 0 -or $selectedIndex -ge $subscriptions.Count)
        
        $selectedSubscription = $subscriptions[$selectedIndex]
        Write-ColorOutput "✅ Selected: $($selectedSubscription.Name)" "Green"
        
        # Switch to selected subscription if not current
        if (-not $selectedSubscription.IsCurrent) {
            Write-ColorOutput "🔄 Switching to selected subscription..." "Cyan"
            az account set --subscription $selectedSubscription.Id
            if ($LASTEXITCODE -ne 0) {
                throw "Failed to switch to subscription: $($selectedSubscription.Id)"
            }
        }
    }
    catch {
        Write-ColorOutput "❌ Failed to list subscriptions: $($_.Exception.Message)" "Red"
        throw
    }
    
    # Step 2: Configure resource names
    Write-ColorOutput "`n🏷️  Step 2: Configure Resource Names" "Cyan"
    
    $defaultRG = "$ProjectName-tfstate-rg"
    $defaultSA = ($ProjectName.ToLower() -replace '[^a-z0-9]', '') + 'tfstate'
    $defaultContainer = 'tfstate'
    
    Write-ColorOutput "Suggested names based on your project:" "White"
    Write-ColorOutput "  Resource Group: $defaultRG" "Gray"
    Write-ColorOutput "  Storage Account: $defaultSA" "Gray"
    Write-ColorOutput "  Container: $defaultContainer" "Gray"
    
    $useDefaults = Read-Host "`nUse suggested names? (y/n) [y]"
    if ($useDefaults -match '^n|no$') {
        $resourceGroup = Read-Host "Resource Group name [$defaultRG]"
        if ([string]::IsNullOrWhiteSpace($resourceGroup)) { $resourceGroup = $defaultRG }
        
        $storageAccount = Read-Host "Storage Account name [$defaultSA]"
        if ([string]::IsNullOrWhiteSpace($storageAccount)) { $storageAccount = $defaultSA }
        
        $container = Read-Host "Container name [$defaultContainer]"
        if ([string]::IsNullOrWhiteSpace($container)) { $container = $defaultContainer }
    }
    else {
        $resourceGroup = $defaultRG
        $storageAccount = $defaultSA
        $container = $defaultContainer
    }
    
    # Step 3: Check existing resources
    Write-ColorOutput "`n🔍 Step 3: Checking Existing Resources" "Cyan"
    
    $backendValidation = Test-TerraformBackend -StorageAccountName $storageAccount -ResourceGroupName $resourceGroup -ContainerName $container -SubscriptionId $selectedSubscription.Id
    
    if ($backendValidation.Valid) {
        Write-ColorOutput "✅ Terraform backend already exists and is accessible!" "Green"
        Write-ColorOutput "   Storage Account: $storageAccount" "Gray"
        Write-ColorOutput "   Resource Group: $resourceGroup" "Gray"
        Write-ColorOutput "   Container: $container" "Gray"
        
        return @{
            SubscriptionId = $selectedSubscription.Id
            ResourceGroup = $resourceGroup
            StorageAccount = $storageAccount
            Container = $container
            Action = 'existing'
            Valid = $true
        }
    }
    else {
        Write-ColorOutput "⚠️  Backend infrastructure not found:" "Yellow"
        foreach ($issue in $backendValidation.Issues) {
            Write-ColorOutput "   • $issue" "Yellow"
        }
        
        # Step 4: Create missing resources
        Write-ColorOutput "`n🔨 Step 4: Create Missing Resources" "Cyan"
        $createChoice = Read-Host "Would you like to create the missing infrastructure? (y/n) [y]"
        
        if ($createChoice -notmatch '^n|no$') {
            $createRG = $false
            if (-not $backendValidation.StorageAccountExists) {
                $createRGChoice = Read-Host "Create resource group '$resourceGroup' if it doesn't exist? (y/n) [y]"
                $createRG = $createRGChoice -notmatch '^n|no$'
            }
            
            try {
                $result = New-AzureTerraformBackend -StorageAccountName $storageAccount -ResourceGroupName $resourceGroup -ContainerName $container -Location $Location -SubscriptionId $selectedSubscription.Id -CreateResourceGroup:$createRG
                
                return @{
                    SubscriptionId = $selectedSubscription.Id
                    ResourceGroup = $resourceGroup
                    StorageAccount = $storageAccount
                    Container = $container
                    Action = 'created'
                    Valid = $true
                    CreationResult = $result
                }
            }
            catch {
                Write-ColorOutput "❌ Failed to create backend infrastructure: $($_.Exception.Message)" "Red"
                throw
            }
        }
        else {
            Write-ColorOutput "📝 Backend configuration will be saved for manual creation later." "Yellow"
            return @{
                SubscriptionId = $selectedSubscription.Id
                ResourceGroup = $resourceGroup
                StorageAccount = $storageAccount
                Container = $container
                Action = 'manual'
                Valid = $false
            }
        }
    }
}

function Test-BackendConnectivity {
    <#
    .SYNOPSIS
        Tests connectivity and permissions for Terraform backend storage.
    
    .DESCRIPTION
        Performs comprehensive testing of Terraform backend infrastructure including
        authentication, permissions, and basic storage operations.
    
    .PARAMETER StorageAccountName
        Name of the storage account to test.
    
    .PARAMETER ResourceGroupName
        Name of the resource group containing the storage account.
    
    .PARAMETER ContainerName
        Name of the storage container to test.
    
    .PARAMETER SubscriptionId
        Azure subscription ID. If not specified, uses current context.
    
    .EXAMPLE
        Test-BackendConnectivity -StorageAccountName "mytfstate" -ResourceGroupName "terraform-rg" -ContainerName "tfstate"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$StorageAccountName,
        
        [Parameter(Mandatory = $true)]
        [string]$ResourceGroupName,
        
        [Parameter(Mandatory = $true)]
        [string]$ContainerName,
        
        [Parameter(Mandatory = $false)]
        [string]$SubscriptionId
    )
    
    Write-ColorOutput "🔍 Testing Terraform Backend Connectivity" "Cyan"
    Write-ColorOutput "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "Cyan"
    
    $testResults = @{
        Authentication = $false
        StorageAccountAccess = $false
        ContainerAccess = $false
        WritePermissions = $false
        ReadPermissions = $false
        OverallStatus = $false
        Issues = @()
    }
    
    try {
        # Test 1: Authentication
        Write-ColorOutput "1. Testing Azure authentication..." "White"
        try {
            $accountInfo = Test-AzureAuthentication -SubscriptionId $SubscriptionId
            Write-ColorOutput "   ✅ Authentication successful" "Green"
            Write-ColorOutput "   📧 Logged in as: $($accountInfo.user.name)" "Gray"
            Write-ColorOutput "   🏢 Subscription: $($accountInfo.name)" "Gray"
            $testResults.Authentication = $true
        }
        catch {
            Write-ColorOutput "   ❌ Authentication failed: $($_.Exception.Message)" "Red"
            $testResults.Issues += "Authentication failed"
            return $testResults
        }
        
        # Test 2: Storage Account Access
        Write-ColorOutput "2. Testing storage account access..." "White"
        try {
            $storageCheck = Test-AzureStorageAccount -StorageAccountName $StorageAccountName -ResourceGroupName $ResourceGroupName -SubscriptionId $SubscriptionId
            if ($storageCheck.Exists) {
                Write-ColorOutput "   ✅ Storage account accessible" "Green"
                Write-ColorOutput "   📦 Account: $($storageCheck.StorageAccount.name)" "Gray"
                Write-ColorOutput "   🌍 Location: $($storageCheck.StorageAccount.primaryLocation)" "Gray"
                $testResults.StorageAccountAccess = $true
            }
            else {
                Write-ColorOutput "   ❌ Storage account not found or inaccessible" "Red"
                $testResults.Issues += "Storage account '$StorageAccountName' not found"
                return $testResults
            }
        }
        catch {
            Write-ColorOutput "   ❌ Storage account check failed: $($_.Exception.Message)" "Red"
            $testResults.Issues += "Storage account access failed"
            return $testResults
        }
        
        # Test 3: Container Access
        Write-ColorOutput "3. Testing container access..." "White"
        try {
            $containerCheck = Test-AzureStorageContainer -StorageAccountName $StorageAccountName -ContainerName $ContainerName -ResourceGroupName $ResourceGroupName -SubscriptionId $SubscriptionId
            if ($containerCheck.Exists) {
                Write-ColorOutput "   ✅ Container accessible" "Green"
                Write-ColorOutput "   📁 Container: $($containerCheck.Container.name)" "Gray"
                $testResults.ContainerAccess = $true
                $storageKey = $containerCheck.StorageKey
            }
            else {
                Write-ColorOutput "   ❌ Container not found or inaccessible" "Red"
                $testResults.Issues += "Container '$ContainerName' not found"
                return $testResults
            }
        }
        catch {
            Write-ColorOutput "   ❌ Container check failed: $($_.Exception.Message)" "Red"
            $testResults.Issues += "Container access failed"
            return $testResults
        }
        
        # Test 4: Write Permissions
        Write-ColorOutput "4. Testing write permissions..." "White"
        try {
            $testBlobName = "connectivity-test-$(Get-Date -Format 'yyyyMMdd-HHmmss').txt"
            $testContent = "Terraform backend connectivity test - $(Get-Date)"
            
            # Create a temporary file
            $tempFile = [System.IO.Path]::GetTempFileName()
            $testContent | Out-File -FilePath $tempFile -Encoding UTF8
            
            # Upload test blob
            $uploadResult = az storage blob upload `
                --account-name $StorageAccountName `
                --account-key $storageKey `
                --container-name $ContainerName `
                --name $testBlobName `
                --file $tempFile `
                --output json 2>$null
                
            if ($LASTEXITCODE -eq 0) {
                Write-ColorOutput "   ✅ Write permissions confirmed" "Green"
                $testResults.WritePermissions = $true
                
                # Test 5: Read Permissions
                Write-ColorOutput "5. Testing read permissions..." "White"
                $downloadResult = az storage blob download `
                    --account-name $StorageAccountName `
                    --account-key $storageKey `
                    --container-name $ContainerName `
                    --name $testBlobName `
                    --file "$tempFile.download" `
                    --output json 2>$null
                    
                if ($LASTEXITCODE -eq 0) {
                    Write-ColorOutput "   ✅ Read permissions confirmed" "Green"
                    $testResults.ReadPermissions = $true
                }
                else {
                    Write-ColorOutput "   ❌ Read permissions failed" "Red"
                    $testResults.Issues += "Read permissions denied"
                }
                
                # Cleanup test blob
                az storage blob delete `
                    --account-name $StorageAccountName `
                    --account-key $storageKey `
                    --container-name $ContainerName `
                    --name $testBlobName `
                    --output none 2>$null
            }
            else {
                Write-ColorOutput "   ❌ Write permissions failed" "Red"
                $testResults.Issues += "Write permissions denied"
            }
            
            # Cleanup temp files
            if (Test-Path $tempFile) { Remove-Item $tempFile -Force }
            if (Test-Path "$tempFile.download") { Remove-Item "$tempFile.download" -Force }
        }
        catch {
            Write-ColorOutput "   ❌ Permission test failed: $($_.Exception.Message)" "Red"
            $testResults.Issues += "Permission test failed"
        }
        
        # Overall Status
        $testResults.OverallStatus = $testResults.Authentication -and 
                                   $testResults.StorageAccountAccess -and 
                                   $testResults.ContainerAccess -and 
                                   $testResults.WritePermissions -and 
                                   $testResults.ReadPermissions
        
        Write-ColorOutput "`n📊 Test Summary:" "Cyan"
        if ($testResults.OverallStatus) {
            Write-ColorOutput "✅ All tests passed! Backend is ready for Terraform." "Green"
        }
        else {
            Write-ColorOutput "❌ Some tests failed. Review issues above." "Red"
            Write-ColorOutput "Issues found:" "Yellow"
            foreach ($issue in $testResults.Issues) {
                Write-ColorOutput "   • $issue" "Yellow"
            }
        }
        
        return $testResults
    }
    catch {
        Write-ColorOutput "❌ Connectivity test failed: $($_.Exception.Message)" "Red"
        $testResults.Issues += "Unexpected error during testing"
        return $testResults
    }
}

#endregion

#region Aliases
Set-Alias -Name 'init-devcontainer' -Value 'Initialize-DevContainer'
Set-Alias -Name 'new-iac' -Value 'New-IaCProject'
#endregion

#region Module Initialization
Write-Verbose "DevContainer Accelerator module loaded successfully"
#endregion

# Export module members
Export-ModuleMember -Function @(
    'Initialize-DevContainer',
    'New-IaCProject', 
    'Test-DevContainerPrerequisites',
    'Update-DevContainerTemplate',
    'New-TerraformBackend',
    'Get-AzureSubscriptions',
    'Invoke-GuidedBackendSetup',
    'Test-BackendConnectivity',
    'Test-IsGuid',
    'Write-ColorOutput'
) -Alias @(
    'init-devcontainer',
    'new-iac'
)
