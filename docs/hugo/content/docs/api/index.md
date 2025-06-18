---
title: "Module Reference"
linkTitle: "Module Reference"
weight: 7
description: >
  Complete function reference for the DevContainer Template modular PowerShell architecture.
---

# DevContainer Template Module Reference

This section provides detailed function documentation for the DevContainer Template's modular PowerShell architecture.

## Module Overview

The DevContainer Template uses a modular architecture with five specialized modules:

- **CommonModule** - Shared utilities and prerequisites
- **AzureModule** - Azure authentication and backend management
- **InteractiveModule** - User input and configuration prompts
- **DevContainerModule** - DevContainer setup and configuration
- **ProjectModule** - Project structure and example management

## CommonModule Functions

### Write-ColorOutput

Writes colored output to the console for better user experience.

#### Syntax

```powershell
Write-ColorOutput
    [-Message] <String>
    [-Color] <String>
```

### Test-IsGuid

Validates if a string is a valid GUID format.

#### Syntax

```powershell
Test-IsGuid
    [-InputString] <String>
```

### Test-Prerequisites

Tests system prerequisites for DevContainer operation.

#### Syntax

```powershell
Test-Prerequisites
```

### Show-NextSteps

Displays next steps after successful initialization.

#### Syntax

```powershell
Show-NextSteps
    [-ProjectName] <String>
```

## AzureModule Functions

### Test-AzureAuthentication

Tests Azure authentication and subscription access.

#### Syntax

```powershell
Test-AzureAuthentication
    [-TenantId] <String>
    [-SubscriptionId] <String>
```

### New-AzureTerraformBackend

Creates Azure storage backend for Terraform state management.

#### Syntax

```powershell
New-AzureTerraformBackend
    [-SubscriptionId] <String>
    [-ResourceGroupName] <String>
    [-StorageAccountName] <String>
    [-ContainerName] <String>
    [-Location] <String>
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

```

### Test-AzureStorageAccount

Tests if an Azure storage account exists.

#### Syntax

```powershell
Test-AzureStorageAccount
    [-StorageAccountName] <String>
    [-ResourceGroupName] <String>
```

### Test-TerraformBackend

Tests Terraform backend connectivity and configuration.

#### Syntax

```powershell
Test-TerraformBackend
    [-StorageAccountName] <String>
    [-ContainerName] <String>
    [-ResourceGroupName] <String>
```

## InteractiveModule Functions

### Get-InteractiveInput

Prompts user for configuration input with validation.

#### Syntax

```powershell
Get-InteractiveInput
```

### Get-BackendConfiguration

Prompts user for backend configuration settings.

#### Syntax

```powershell
Get-BackendConfiguration
    [-TenantId] <String>
    [-SubscriptionId] <String>
    [-ProjectName] <String>
```

## DevContainerModule Functions

### Initialize-ProjectDirectory

Creates and initializes the project directory structure.

#### Syntax

```powershell
Initialize-ProjectDirectory
    [-ProjectName] <String>
    [-ProjectPath] <String>
```

### Copy-DevContainerFiles

Copies DevContainer configuration files to the project.

#### Syntax

```powershell
Copy-DevContainerFiles
    [-ProjectPath] <String>
```

### New-DevContainerEnv

Creates environment configuration for the DevContainer.

#### Syntax

```powershell
New-DevContainerEnv
    [-TenantId] <String>
    [-SubscriptionId] <String>
    [-ProjectName] <String>
    [-StorageAccountName] <String>
    [-ContainerName] <String>
    [-ResourceGroupName] <String>
```

## ProjectModule Functions

### Add-ExampleFiles

Adds example Infrastructure as Code files to the project.

#### Syntax

```powershell
Add-ExampleFiles
    [-ProjectPath] <String>
    [-ProjectType] <String>
```

## Usage Examples

### Basic DevContainer Initialization

```powershell
# Load the main script which imports all modules
.\Initialize-DevContainer.ps1 -TenantId "your-tenant-id" `
                              -SubscriptionId "your-subscription-id" `
                              -ProjectName "my-project"
```

### Testing Prerequisites

```powershell
# Import CommonModule and test prerequisites
Import-Module .\modules\CommonModule.psm1
Test-Prerequisites
```

### Azure Backend Creation

```powershell
# Import AzureModule and create backend
Import-Module .\modules\AzureModule.psm1
$backend = New-AzureTerraformBackend -SubscriptionId "sub-id" `
                                     -ResourceGroupName "rg-terraform" `
                                     -StorageAccountName "tfstate" `
                                     -ContainerName "tfstate" `
                                     -Location "eastus"
```

### Interactive Configuration

```powershell
# Import InteractiveModule for user prompts
Import-Module .\modules\InteractiveModule.psm1
$config = Get-InteractiveInput
```

## Module Dependencies

The modules have the following dependencies:

- **CommonModule**: No dependencies (base module)
- **AzureModule**: Requires Azure PowerShell modules
- **InteractiveModule**: Depends on CommonModule
- **DevContainerModule**: Depends on CommonModule  
- **ProjectModule**: Depends on CommonModule

## Error Handling

All modules include comprehensive error handling with:

- **Detailed error messages** for troubleshooting
- **Graceful fallbacks** when possible
- **Consistent error codes** across modules
- **Logging support** for debugging

## Testing

The modules are tested using Pester with comprehensive unit and integration tests:

```powershell
# Run all tests
.\tests\Run-Tests.ps1

# Run module-specific tests
Invoke-Pester .\tests\unit\CommonModule.Tests.ps1
Invoke-Pester .\tests\unit\AzureModule.Tests.ps1
```

For more information on troubleshooting, see the [Troubleshooting Guide](/docs/troubleshooting/).

## Contributing

When contributing new functions to the modules:

1. Follow PowerShell naming conventions
2. Include comprehensive parameter validation
3. Add proper help documentation
4. Include unit tests
5. Update this documentation

For more details, see the [Contributing Guide](https://github.com/haflidif/devcontainer-template/blob/main/CONTRIBUTING.md).
