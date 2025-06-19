---
title: "API Reference"
linkTitle: "API Reference"
weight: 6
description: >
  Complete function reference for all PowerShell modules in the DevContainer template.
---

# API Reference

Complete reference for all functions and cmdlets available in the DevContainer template PowerShell modules.

## CommonModule Functions

### Test-Prerequisites

Validates that all required tools are installed and available.

**Syntax:**
```powershell
Test-Prerequisites [[-RequiredTools] <string[]>] [<CommonParameters>]
```

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| RequiredTools | string[] | No | Array of required tool names. Default: @("git", "docker", "az") |

**Returns:** Boolean - `$true` if all tools are available, `$false` otherwise

**Example:**
```powershell
# Test default tools
$prereqsMet = Test-Prerequisites

# Test custom tools
$customPrereqs = Test-Prerequisites -RequiredTools @("git", "terraform", "kubectl")
```

---

### Initialize-ProjectDirectory

Creates the basic project directory structure for DevContainer projects.

**Syntax:**
```powershell
Initialize-ProjectDirectory [-ProjectName] <string> [-ProjectPath] <string> [[-ProjectType] <string>] [-IncludeExamples] [<CommonParameters>]
```

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| ProjectName | string | Yes | Name of the project |
| ProjectPath | string | Yes | Full path where project should be created |
| ProjectType | string | No | Type of project (terraform, bicep). Default: "terraform" |
| IncludeExamples | switch | No | Include example files and templates |

**Returns:** String - Path to the created project directory

**Example:**
```powershell
# Create basic Terraform project
$projectPath = Initialize-ProjectDirectory -ProjectName "webapp" -ProjectPath "C:\Projects\webapp" -ProjectType "terraform"

# Create Bicep project with examples
$projectPath = Initialize-ProjectDirectory -ProjectName "infrastructure" -ProjectPath "C:\Projects\infra" -ProjectType "bicep" -IncludeExamples
```

---

### Copy-TemplateFiles

Copies template files from source to destination with filtering options.

**Syntax:**
```powershell
Copy-TemplateFiles [-SourcePath] <string> [-DestinationPath] <string> [[-ExcludePatterns] <string[]>] [-Force] [<CommonParameters>]
```

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| SourcePath | string | Yes | Source directory path |
| DestinationPath | string | Yes | Destination directory path |
| ExcludePatterns | string[] | No | Patterns to exclude. Default: @("*.backup", "hugo-backup") |
| Force | switch | No | Overwrite existing files |

**Returns:** None

**Example:**
```powershell
# Copy template files excluding backups
Copy-TemplateFiles -SourcePath ".\templates\terraform" -DestinationPath "C:\Projects\webapp\terraform"

# Copy with custom exclusions
Copy-TemplateFiles -SourcePath ".\templates" -DestinationPath "C:\Projects\webapp" -ExcludePatterns @("*.tmp", "*.log") -Force
```

---

### Write-Log

Writes log messages with different severity levels.

**Syntax:**
```powershell
Write-Log [-Message] <string> [[-Level] <string>] [<CommonParameters>]
```

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| Message | string | Yes | Log message text |
| Level | string | No | Log level (Info, Warning, Error). Default: "Info" |

**Returns:** None

**Example:**
```powershell
Write-Log "Project initialization started"
Write-Log "Missing configuration file" -Level "Warning"
Write-Log "Failed to connect to Azure" -Level "Error"
```

## AzureModule Functions

### Test-AzureConnection

Validates Azure CLI authentication and connection status.

**Syntax:**
```powershell
Test-AzureConnection [[-TenantId] <string>] [[-SubscriptionId] <string>] [<CommonParameters>]
```

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| TenantId | string | No | Azure tenant ID to validate against |
| SubscriptionId | string | No | Azure subscription ID to validate against |

**Returns:** Boolean - `$true` if connected and validated, `$false` otherwise

**Example:**
```powershell
# Test basic connection
$isConnected = Test-AzureConnection

# Test connection with specific tenant and subscription
$isValid = Test-AzureConnection -TenantId "your-tenant-id" -SubscriptionId "your-subscription-id"
```

---

### Connect-AzureAccount

Handles Azure CLI authentication with tenant and subscription validation.

**Syntax:**
```powershell
Connect-AzureAccount [-TenantId] <string> [-SubscriptionId] <string> [-Force] [<CommonParameters>]
```

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| TenantId | string | Yes | Azure tenant ID |
| SubscriptionId | string | Yes | Azure subscription ID |
| Force | switch | No | Force re-authentication even if already connected |

**Returns:** Boolean - `$true` if authentication successful, `$false` otherwise

**Example:**
```powershell
# Connect to Azure
$connected = Connect-AzureAccount -TenantId "your-tenant-id" -SubscriptionId "your-subscription-id"

# Force reconnection
$reconnected = Connect-AzureAccount -TenantId "your-tenant-id" -SubscriptionId "your-subscription-id" -Force
```

---

### New-AzureResourceGroup

Creates Azure resource groups with standardized naming conventions.

**Syntax:**
```powershell
New-AzureResourceGroup [-Name] <string> [-Location] <string> [[-Environment] <string>] [[-Tags] <hashtable>] [-WhatIf] [<CommonParameters>]
```

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| Name | string | Yes | Base name for the resource group |
| Location | string | Yes | Azure region |
| Environment | string | No | Environment name (dev, staging, prod). Default: "dev" |
| Tags | hashtable | No | Additional tags to apply |
| WhatIf | switch | No | Preview operation without executing |

**Returns:** Object - Azure resource group details

**Example:**
```powershell
# Create basic resource group
$rg = New-AzureResourceGroup -Name "webapp" -Location "eastus" -Environment "dev"

# Create with custom tags
$tags = @{ Owner = "DevTeam"; CostCenter = "IT" }
$rg = New-AzureResourceGroup -Name "webapp" -Location "eastus" -Environment "prod" -Tags $tags

# Preview operation
$rg = New-AzureResourceGroup -Name "webapp" -Location "eastus" -WhatIf
```

---

### New-AzureStorageAccount

Creates Azure storage accounts for Terraform backend or general use.

**Syntax:**
```powershell
New-AzureStorageAccount [-Name] <string> [-ResourceGroupName] <string> [-Location] <string> [[-Sku] <string>] [-CreateContainer] [[-ContainerName] <string>] [-WhatIf] [<CommonParameters>]
```

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| Name | string | Yes | Base name for storage account |
| ResourceGroupName | string | Yes | Resource group name |
| Location | string | Yes | Azure region |
| Sku | string | No | Storage SKU. Default: "Standard_LRS" |
| CreateContainer | switch | No | Create a blob container |
| ContainerName | string | No | Container name. Default: "tfstate" |
| WhatIf | switch | No | Preview operation without executing |

**Returns:** Object - Azure storage account details

**Example:**
```powershell
# Create basic storage account
$storage = New-AzureStorageAccount -Name "webapp" -ResourceGroupName "rg-webapp-dev" -Location "eastus"

# Create with container for Terraform state
$storage = New-AzureStorageAccount -Name "webapp" -ResourceGroupName "rg-webapp-dev" -Location "eastus" -CreateContainer -ContainerName "tfstate"

# Preview with premium storage
$storage = New-AzureStorageAccount -Name "webapp" -ResourceGroupName "rg-webapp-dev" -Location "eastus" -Sku "Premium_LRS" -WhatIf
```

---

### Get-AzureNamingConvention

Generates standardized Azure resource names following naming conventions.

**Syntax:**
```powershell
Get-AzureNamingConvention [-ResourceType] <string> [-Name] <string> [[-Environment] <string>] [[-Location] <string>] [<CommonParameters>]
```

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| ResourceType | string | Yes | Azure resource type (rg, st, kv, app, etc.) |
| Name | string | Yes | Base resource name |
| Environment | string | No | Environment name. Default: "dev" |
| Location | string | No | Azure region for location code |

**Returns:** String - Formatted resource name

**Example:**
```powershell
# Generate resource group name
$rgName = Get-AzureNamingConvention -ResourceType "rg" -Name "webapp" -Environment "prod"
# Returns: rg-webapp-prod

# Generate storage account name with location
$stName = Get-AzureNamingConvention -ResourceType "st" -Name "webapp" -Environment "dev" -Location "eastus"
# Returns: stwebappdeveus
```

## DevContainerModule Functions

### New-DevContainerConfiguration

Creates DevContainer configuration files with project-specific settings.

**Syntax:**
```powershell
New-DevContainerConfiguration [-ProjectPath] <string> [[-ProjectType] <string>] [[-EnvironmentVariables] <hashtable>] [[-AdditionalFeatures] <string[]>] [-WhatIf] [<CommonParameters>]
```

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| ProjectPath | string | Yes | Project root directory path |
| ProjectType | string | No | Project type (terraform, bicep). Default: "terraform" |
| EnvironmentVariables | hashtable | No | Environment variables for the container |
| AdditionalFeatures | string[] | No | Additional DevContainer features to include |
| WhatIf | switch | No | Preview operation without executing |

**Returns:** Object - DevContainer configuration object

**Example:**
```powershell
# Create basic Terraform DevContainer
$config = New-DevContainerConfiguration -ProjectPath "C:\Projects\webapp" -ProjectType "terraform"

# Create with environment variables
$envVars = @{
    AZURE_TENANT_ID = "your-tenant-id"
    AZURE_SUBSCRIPTION_ID = "your-subscription-id"
    PROJECT_NAME = "webapp"
}
$config = New-DevContainerConfiguration -ProjectPath "C:\Projects\webapp" -EnvironmentVariables $envVars

# Preview Bicep configuration with additional features
$features = @("ghcr.io/devcontainers/features/kubectl-helm-minikube:1")
$config = New-DevContainerConfiguration -ProjectPath "C:\Projects\webapp" -ProjectType "bicep" -AdditionalFeatures $features -WhatIf
```

---

### Copy-DevContainerScripts

Copies DevContainer setup and post-creation scripts to the project.

**Syntax:**
```powershell
Copy-DevContainerScripts [-ProjectPath] <string> [[-SourceScriptsPath] <string>] [-WhatIf] [<CommonParameters>]
```

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| ProjectPath | string | Yes | Project root directory path |
| SourceScriptsPath | string | No | Source path for scripts. Default: ".devcontainer/scripts" |
| WhatIf | switch | No | Preview operation without executing |

**Returns:** None

**Example:**
```powershell
# Copy default scripts
Copy-DevContainerScripts -ProjectPath "C:\Projects\webapp"

# Copy from custom location
Copy-DevContainerScripts -ProjectPath "C:\Projects\webapp" -SourceScriptsPath ".\custom-scripts"

# Preview operation
Copy-DevContainerScripts -ProjectPath "C:\Projects\webapp" -WhatIf
```

---

### Test-DevContainerConfiguration

Validates DevContainer configuration and prerequisites.

**Syntax:**
```powershell
Test-DevContainerConfiguration [-ProjectPath] <string> [[-RequiredFiles] <string[]>] [<CommonParameters>]
```

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| ProjectPath | string | Yes | Project root directory path |
| RequiredFiles | string[] | No | Additional required files to check |

**Returns:** Object - Validation results with success status and details

**Example:**
```powershell
# Test basic configuration
$result = Test-DevContainerConfiguration -ProjectPath "C:\Projects\webapp"

# Test with additional required files
$requiredFiles = @("terraform\main.tf", "terraform\variables.tf")
$result = Test-DevContainerConfiguration -ProjectPath "C:\Projects\webapp" -RequiredFiles $requiredFiles

# Check results
if ($result.Success) {
    Write-Host "DevContainer configuration is valid"
} else {
    Write-Warning "Issues found: $($result.Issues -join ', ')"
}
```

## Validation Functions

### Test-TerraformConfiguration

Validates Terraform configuration files and structure.

**Syntax:**
```powershell
Test-TerraformConfiguration [-ProjectPath] <string> [-RunValidation] [-CheckSecurity] [<CommonParameters>]
```

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| ProjectPath | string | Yes | Project root directory path |
| RunValidation | switch | No | Run `terraform validate` |
| CheckSecurity | switch | No | Run security scanning with tfsec |

**Returns:** Object - Validation results

**Example:**
```powershell
# Basic structure validation
$result = Test-TerraformConfiguration -ProjectPath "C:\Projects\webapp"

# Full validation with security checks
$result = Test-TerraformConfiguration -ProjectPath "C:\Projects\webapp" -RunValidation -CheckSecurity
```

---

### Test-BicepConfiguration

Validates Azure Bicep configuration files and structure.

**Syntax:**
```powershell
Test-BicepConfiguration [-ProjectPath] <string> [-RunBuild] [-CheckCompliance] [<CommonParameters>]
```

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| ProjectPath | string | Yes | Project root directory path |
| RunBuild | switch | No | Run `az bicep build` |
| CheckCompliance | switch | No | Run compliance checking |

**Returns:** Object - Validation results

**Example:**
```powershell
# Basic structure validation
$result = Test-BicepConfiguration -ProjectPath "C:\Projects\webapp"

# Full validation with build and compliance
$result = Test-BicepConfiguration -ProjectPath "C:\Projects\webapp" -RunBuild -CheckCompliance
```

## Utility Functions

### Get-ProjectType

Automatically detects the project type based on files present.

**Syntax:**
```powershell
Get-ProjectType [-ProjectPath] <string> [<CommonParameters>]
```

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| ProjectPath | string | Yes | Project root directory path |

**Returns:** String - Detected project type (terraform, bicep, or unknown)

**Example:**
```powershell
$projectType = Get-ProjectType -ProjectPath "C:\Projects\webapp"
Write-Host "Detected project type: $projectType"
```

---

### Convert-ParametersToEnvironment

Converts PowerShell parameters to environment variables format.

**Syntax:**
```powershell
Convert-ParametersToEnvironment [-Parameters] <hashtable> [[-Prefix] <string>] [<CommonParameters>]
```

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| Parameters | hashtable | Yes | Parameters to convert |
| Prefix | string | No | Prefix for environment variable names |

**Returns:** Hashtable - Environment variables

**Example:**
```powershell
$params = @{ TenantId = "123"; SubscriptionId = "456" }
$envVars = Convert-ParametersToEnvironment -Parameters $params -Prefix "AZURE_"
# Returns: @{ AZURE_TENANT_ID = "123"; AZURE_SUBSCRIPTION_ID = "456" }
```

## Error Handling

All functions include comprehensive error handling and return structured results:

```powershell
# Example of error handling pattern used in all functions
try {
    $result = SomeFunction -Parameter $value
    return @{
        Success = $true
        Result = $result
        Message = "Operation completed successfully"
    }
}
catch {
    return @{
        Success = $false
        Error = $_.Exception.Message
        Message = "Operation failed"
    }
}
```

## Common Parameters

All functions support PowerShell common parameters:

- `-Verbose` - Detailed output
- `-Debug` - Debug information
- `-ErrorAction` - Error handling behavior
- `-WarningAction` - Warning handling behavior
- `-WhatIf` - Preview mode (where supported)

## Module Import

To use these functions, import the required modules:

```powershell
# Import all modules
Get-ChildItem -Path ".\modules\*.psm1" | Import-Module -Force

# Import specific modules
Import-Module .\modules\CommonModule.psm1 -Force
Import-Module .\modules\AzureModule.psm1 -Force
Import-Module .\modules\DevContainerModule.psm1 -Force
```

## Next Steps

- Check out [Examples](../examples/) for practical usage scenarios
- Review [Configuration](../configuration/) for customization options
- See [Testing](../testing/) for validation and testing guidance
