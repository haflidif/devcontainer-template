---
title: "API Reference"
linkTitle: "API Reference"
weight: 7
description: >
  Complete API reference for the DevContainer Accelerator PowerShell module functions.
---

# API Reference

This section provides detailed API documentation for all functions in the DevContainer Accelerator PowerShell module.

## Project Management Functions

### New-IaCProject

Creates a complete Infrastructure as Code project with full configuration.

#### Syntax

```powershell
New-IaCProject
    [-ProjectName] <String>
    [-TenantId] <String>
    [-SubscriptionId] <String>
    [[-ProjectType] <String>]
    [[-Environment] <String>]
    [[-Location] <String>]
    [-CreateBackend]
    [-IncludeExamples]
    [-InitializeGit]
    [-EnableSecurity]
    [<CommonParameters>]
```

#### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| ProjectName | String | Yes | Name of the project to create |
| TenantId | String | Yes | Azure tenant ID |
| SubscriptionId | String | Yes | Azure subscription ID |
| ProjectType | String | No | "terraform", "bicep", or "both" (default: "terraform") |
| Environment | String | No | Environment name (default: "dev") |
| Location | String | No | Azure region (default: "eastus") |
| CreateBackend | Switch | No | Create Terraform backend automatically |
| IncludeExamples | Switch | No | Include example configurations |
| InitializeGit | Switch | No | Initialize Git repository |
| EnableSecurity | Switch | No | Enable security scanning tools |

#### Returns

Returns a project configuration object with the following properties:

```powershell
@{
    ProjectName = "my-project"
    ProjectType = "terraform"
    Environment = "dev"
    Location = "eastus"
    BackendCreated = $true
    ExamplesIncluded = $true
    GitInitialized = $true
    SecurityEnabled = $true
    CreatedDate = (Get-Date)
    Status = "Success"
}
```

#### Examples

```powershell
# Basic project creation
$project = New-IaCProject -ProjectName "my-app" `
                         -TenantId "tenant-id" `
                         -SubscriptionId "subscription-id"

# Advanced project with all features
$project = New-IaCProject -ProjectName "enterprise-app" `
                         -TenantId "tenant-id" `
                         -SubscriptionId "subscription-id" `
                         -ProjectType "both" `
                         -Environment "prod" `
                         -Location "westus2" `
                         -CreateBackend `
                         -IncludeExamples `
                         -InitializeGit `
                         -EnableSecurity
```

### Initialize-DevContainer

Initializes DevContainer configuration in existing projects.

#### Syntax

```powershell
Initialize-DevContainer
    [-TenantId] <String>
    [-SubscriptionId] <String>
    [[-ProjectName] <String>]
    [[-Environment] <String>]
    [[-ProjectType] <String>]
    [-ConfigureTerraform]
    [-ConfigureBicep]
    [-Force]
    [<CommonParameters>]
```

#### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| TenantId | String | Yes | Azure tenant ID |
| SubscriptionId | String | Yes | Azure subscription ID |
| ProjectName | String | No | Name of existing project |
| Environment | String | No | Environment name (default: "dev") |
| ProjectType | String | No | "terraform", "bicep", or "both" |
| ConfigureTerraform | Switch | No | Configure Terraform-specific settings |
| ConfigureBicep | Switch | No | Configure Bicep-specific settings |
| Force | Switch | No | Overwrite existing configuration |

#### Examples

```powershell
# Basic initialization
Initialize-DevContainer -TenantId "tenant-id" -SubscriptionId "subscription-id"

# Custom configuration
Initialize-DevContainer -TenantId "tenant-id" `
                       -SubscriptionId "subscription-id" `
                       -ProjectName "existing-project" `
                       -Environment "staging" `
                       -ConfigureTerraform `
                       -ConfigureBicep
```

## Backend Management Functions

### New-TerraformBackend

Creates and configures Terraform state backends.

#### Syntax

```powershell
New-TerraformBackend
    [-SubscriptionId] <String>
    [-TenantId] <String>
    [-ProjectName] <String>
    [-Environment] <String>
    [[-Location] <String>]
    [[-BackendSubscriptionId] <String>]
    [-Force]
    [<CommonParameters>]
```

#### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| SubscriptionId | String | Yes | Azure subscription ID for the project |
| TenantId | String | Yes | Azure tenant ID |
| ProjectName | String | Yes | Name of the project |
| Environment | String | Yes | Environment name |
| Location | String | No | Azure region (default: "eastus") |
| BackendSubscriptionId | String | No | Separate subscription for backend storage |
| Force | Switch | No | Overwrite existing backend |

#### Returns

Returns a backend configuration object:

```powershell
@{
    ResourceGroupName = "rg-terraform-state"
    StorageAccountName = "sttfstate001"
    ContainerName = "tfstate"
    AccessKey = "storage-access-key"
    SubscriptionId = "subscription-id"
    Location = "eastus"
    Created = $true
}
```

#### Examples

```powershell
# Basic backend creation
$backend = New-TerraformBackend -SubscriptionId "sub-id" `
                               -TenantId "tenant-id" `
                               -ProjectName "my-app" `
                               -Environment "dev"

# Cross-subscription backend
$backend = New-TerraformBackend -SubscriptionId "project-sub-id" `
                               -BackendSubscriptionId "backend-sub-id" `
                               -TenantId "tenant-id" `
                               -ProjectName "shared-app" `
                               -Environment "prod"
```

### Test-TerraformBackend

Validates backend configuration and connectivity.

#### Syntax

```powershell
Test-TerraformBackend
    [-SubscriptionId] <String>
    [-ResourceGroupName] <String>
    [-StorageAccountName] <String>
    [[-ContainerName] <String>]
    [-Detailed]
    [<CommonParameters>]
```

#### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| SubscriptionId | String | Yes | Azure subscription ID |
| ResourceGroupName | String | Yes | Resource group name |
| StorageAccountName | String | Yes | Storage account name |
| ContainerName | String | No | Container name (default: "tfstate") |
| Detailed | Switch | No | Return detailed test results |

#### Returns

Returns a test result object:

```powershell
@{
    Success = $true
    ResourceGroupExists = $true
    StorageAccountExists = $true
    ContainerExists = $true
    AccessKeyValid = $true
    Issues = @()
    TestDuration = "00:00:03.1234567"
}
```

### Get-TerraformBackendConfig

Retrieves backend configuration for Terraform.

#### Syntax

```powershell
Get-TerraformBackendConfig
    [-SubscriptionId] <String>
    [-ProjectName] <String>
    [-Environment] <String>
    [[-OutputFormat] <String>]
    [<CommonParameters>]
```

#### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| SubscriptionId | String | Yes | Azure subscription ID |
| ProjectName | String | Yes | Project name |
| Environment | String | Yes | Environment name |
| OutputFormat | String | No | "object", "terraform", or "json" (default: "object") |

#### Examples

```powershell
# Get configuration object
$config = Get-TerraformBackendConfig -SubscriptionId "sub-id" `
                                    -ProjectName "my-app" `
                                    -Environment "dev"

# Get Terraform configuration
$terraformConfig = Get-TerraformBackendConfig -SubscriptionId "sub-id" `
                                             -ProjectName "my-app" `
                                             -Environment "dev" `
                                             -OutputFormat "terraform"
```

## Configuration Functions

### Set-DevContainerConfiguration

Configures DevContainer settings and environment.

#### Syntax

```powershell
Set-DevContainerConfiguration
    [[-ProjectType] <String>]
    [[-TerraformVersion] <String>]
    [[-BicepVersion] <String>]
    [-EnableTflint]
    [-EnableCheckov]
    [-EnableTfsec]
    [-EnablePSRule]
    [-EnableSecurity]
    [[-SecurityLevel] <String>]
    [<CommonParameters>]
```

#### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| ProjectType | String | No | "terraform", "bicep", or "both" |
| TerraformVersion | String | No | Terraform version to use |
| BicepVersion | String | No | Bicep version to use |
| EnableTflint | Switch | No | Enable TFLint linting |
| EnableCheckov | Switch | No | Enable Checkov security scanning |
| EnableTfsec | Switch | No | Enable TFSec security scanning |
| EnablePSRule | Switch | No | Enable PSRule validation |
| EnableSecurity | Switch | No | Enable all security tools |
| SecurityLevel | String | No | "relaxed", "standard", or "strict" |

### Get-DevContainerConfiguration

Retrieves current configuration settings.

#### Syntax

```powershell
Get-DevContainerConfiguration
    [[-ConfigFile] <String>]
    [[-OutputFormat] <String>]
    [<CommonParameters>]
```

## Validation Functions

### Test-DevContainerSetup

Comprehensive validation of DevContainer setup.

#### Syntax

```powershell
Test-DevContainerSetup
    [[-Path] <String>]
    [-CheckSyntax]
    [-CheckConfiguration]
    [-CheckExamples]
    [-CheckSecurity]
    [-Detailed]
    [[-Tags] <String[]>]
    [<CommonParameters>]
```

#### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| Path | String | No | Path to project directory (default: current) |
| CheckSyntax | Switch | No | Validate PowerShell syntax |
| CheckConfiguration | Switch | No | Validate configuration files |
| CheckExamples | Switch | No | Validate example files |
| CheckSecurity | Switch | No | Run security validation |
| Detailed | Switch | No | Return detailed results |
| Tags | String[] | No | Specific test tags to run |

#### Returns

Returns a validation result object:

```powershell
@{
    Success = $true
    TestsRun = 15
    TestsPassed = 15
    TestsFailed = 0
    Duration = "00:00:30.1234567"
    Issues = @()
    Details = @{
        Syntax = @{ Passed = 5; Failed = 0 }
        Configuration = @{ Passed = 4; Failed = 0 }
        Examples = @{ Passed = 3; Failed = 0 }
        Security = @{ Passed = 3; Failed = 0 }
    }
}
```

### Invoke-SecurityScan

Runs comprehensive security scanning.

#### Syntax

```powershell
Invoke-SecurityScan
    [[-Path] <String>]
    [-RunCheckov]
    [-RunTfsec]
    [-RunPSRule]
    [-ExportResults]
    [[-OutputPath] <String>]
    [<CommonParameters>]
```

## Documentation Functions

### Update-ProjectDocumentation

Generates and updates project documentation.

#### Syntax

```powershell
Update-ProjectDocumentation
    [[-Path] <String>]
    [-UpdateReadme]
    [-GenerateTerraformDocs]
    [-GenerateBicepDocs]
    [-IncludeExamples]
    [[-DocumentationType] <String>]
    [[-OutputFormat] <String>]
    [<CommonParameters>]
```

### Export-ProjectConfiguration

Exports project configuration for sharing or backup.

#### Syntax

```powershell
Export-ProjectConfiguration
    [[-Path] <String>]
    [-IncludeSecrets]
    [[-Format] <String>]
    [[-OutputFile] <String>]
    [<CommonParameters>]
```

## Utility Functions

### Get-AzureContext

Gets current Azure authentication context.

#### Syntax

```powershell
Get-AzureContext
    [[-TenantId] <String>]
    [[-SubscriptionId] <String>]
    [-Validate]
    [<CommonParameters>]
```

### Set-AzureContext

Sets Azure authentication context.

#### Syntax

```powershell
Set-AzureContext
    [-TenantId] <String>
    [-SubscriptionId] <String>
    [[-AuthenticationMethod] <String>]
    [-Force]
    [<CommonParameters>]
```

### Test-Prerequisites

Tests system prerequisites for DevContainer functionality.

#### Syntax

```powershell
Test-Prerequisites
    [-CheckPowerShell]
    [-CheckDocker]
    [-CheckAzureCLI]
    [-CheckModules]
    [-Detailed]
    [<CommonParameters>]
```

## Error Handling

All functions include comprehensive error handling and return consistent error objects:

```powershell
@{
    Success = $false
    Error = @{
        Category = "InvalidOperation"
        Message = "Detailed error message"
        Exception = $_.Exception
        ScriptStackTrace = $_.ScriptStackTrace
    }
    Timestamp = (Get-Date)
}
```

## Common Parameters

All functions support PowerShell common parameters:
- `-Verbose` - Detailed operation output
- `-Debug` - Debug information
- `-ErrorAction` - Error handling behavior
- `-WarningAction` - Warning handling behavior
- `-InformationAction` - Information stream behavior
- `-ErrorVariable` - Error variable assignment
- `-WarningVariable` - Warning variable assignment
- `-InformationVariable` - Information variable assignment
- `-OutVariable` - Output variable assignment
- `-OutBuffer` - Output buffering
- `-PipelineVariable` - Pipeline variable assignment

## Examples

For practical examples of using these functions, see the [Examples documentation](/docs/examples/) and the PowerShell usage examples in the repository.
