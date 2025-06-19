---
title: "Configuration"
linkTitle: "Configuration"
weight: 2
description: >
  Complete configuration guide for customizing the DevContainer template to your needs.
---

# Configuration

This guide covers all configuration options available in the DevContainer template.

## Environment Configuration

### DevContainer Environment File

The main configuration is done through `.devcontainer/devcontainer.env`:

```bash
# Azure Configuration
AZURE_TENANT_ID=your-tenant-id
AZURE_SUBSCRIPTION_ID=your-subscription-id
AZURE_DEFAULT_LOCATION=eastus

# Project Configuration
PROJECT_NAME=my-project
PROJECT_TYPE=terraform  # or bicep
ENVIRONMENT=dev

# Backend Configuration (for Terraform)
BACKEND_STORAGE_ACCOUNT=mystorageaccount
BACKEND_CONTAINER_NAME=tfstate
BACKEND_KEY=terraform.tfstate

# Optional Features
INCLUDE_EXAMPLES=true
CREATE_BACKEND=true
ENABLE_SECURITY_SCANNING=true
```

### DevContainer JSON Configuration

Customize the development environment in `.devcontainer/devcontainer.json`:

```json
{
  "name": "DevContainer Template",
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "features": {
    "ghcr.io/devcontainers/features/azure-cli:1": {},
    "ghcr.io/devcontainers/features/terraform:1": {
      "version": "latest"
    },
    "ghcr.io/devcontainers/features/powershell:1": {
      "version": "7.3"
    }
  },
  "customizations": {
    "vscode": {
      "extensions": [
        "HashiCorp.terraform",
        "ms-azure-devops.azure-pipelines",
        "ms-powershell.powershell"
      ]
    }
  }
}
```

## Module Configuration

### Azure Module Settings

Configure Azure-specific settings in `modules/AzureModule.psm1`:

```powershell
# Default Azure settings
$AzureDefaults = @{
    Location = "East US"
    ResourceGroupPrefix = "rg-"
    StorageAccountPrefix = "st"
    KeyVaultPrefix = "kv-"
    SubscriptionScope = $true
}
```

### Common Module Settings

General configuration options in `modules/CommonModule.psm1`:

```powershell
# Validation settings
$ValidationSettings = @{
    StrictMode = $true
    ValidateParameters = $true
    RequireAuthentication = $true
    EnableLogging = $true
}
```

## Project Type Configuration

### Terraform Projects

For Terraform-based projects:

```powershell
.\Initialize-DevContainer.ps1 -ProjectType "terraform" `
                             -CreateBackend `
                             -BackendStorageAccount "mystorageaccount" `
                             -BackendContainerName "tfstate"
```

Required files structure:
```
terraform/
├── main.tf
├── variables.tf
├── outputs.tf
└── terraform.tfvars.example
```

### Bicep Projects

For Azure Bicep projects:

```powershell
.\Initialize-DevContainer.ps1 -ProjectType "bicep" `
                             -CreateResourceGroup `
                             -Location "eastus"
```

Required files structure:
```
bicep/
├── main.bicep
├── main.bicepparam
└── modules/
```

## Testing Configuration

### Pester Test Settings

Configure testing behavior in `tests/Config.ps1`:

```powershell
$TestConfig = @{
    # Test execution settings
    StrictMode = $true
    EnableCoverage = $true
    CoverageThreshold = 80
    
    # Test categories
    UnitTests = @("Unit", "Function", "Module")
    IntegrationTests = @("Integration", "E2E")
    SecurityTests = @("Security", "Compliance")
    
    # Output settings
    DetailedOutput = $true
    JUnitFormat = $true
    CoverageReport = $true
}
```

### Test Environment Variables

Set testing-specific environment variables:

```bash
# Test execution mode
TEST_MODE=comprehensive  # quick, comprehensive, security

# Test output format
TEST_OUTPUT_FORMAT=detailed  # detailed, minimal, junit

# Test categories to run
TEST_CATEGORIES=Unit,Integration,Security
```

## Security Configuration

### Security Scanning Tools

Enable and configure security tools:

```powershell
# Security tool configuration
$SecurityConfig = @{
    TFSec = @{
        Enabled = $true
        ConfigFile = ".tfsec.yml"
        FailOnHigh = $true
    }
    Checkov = @{
        Enabled = $true
        ConfigFile = ".checkov.yml"
        SkipChecks = @("CKV_AZURE_1")
    }
    PSRule = @{
        Enabled = $true
        ConfigFile = "ps-rule.yaml"
        MinimumVersion = "2.0.0"
    }
}
```

### Security Policy Configuration

Configure security policies in `.tfsec.yml`:

```yaml
severity_overrides:
  - rule: azure-storage-use-secure-tls-policy
    severity: HIGH
  - rule: azure-keyvault-ensure-secret-expiry
    severity: MEDIUM

exclude:
  - azure-storage-default-action-deny  # Allow for development
```

## CI/CD Configuration

### GitHub Actions Configuration

Customize workflows in `.github/workflows/`:

```yaml
name: DevContainer Validation
on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

env:
  AZURE_TENANT_ID: ${{ secrets.AZURE_TENANT_ID }}
  AZURE_SUBSCRIPTION_ID: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
  PROJECT_TYPE: terraform
```

### Required Secrets

Configure these secrets in your GitHub repository:

- `AZURE_TENANT_ID` - Azure tenant identifier
- `AZURE_SUBSCRIPTION_ID` - Azure subscription identifier
- `AZURE_CLIENT_ID` - Service principal client ID
- `AZURE_CLIENT_SECRET` - Service principal client secret

## Advanced Configuration

### Custom Module Development

Create custom modules in the `modules/` directory:

```powershell
# Custom module template
function New-CustomModule {
    param(
        [Parameter(Mandatory)]
        [string]$ModuleName,
        
        [string]$ModulePath = "./modules"
    )
    
    $ModuleFile = Join-Path $ModulePath "$ModuleName.psm1"
    $ModuleManifest = Join-Path $ModulePath "$ModuleName.psd1"
    
    # Create module structure
    New-ModuleManifest -Path $ModuleManifest -ModuleVersion "1.0.0"
    New-Item -Path $ModuleFile -ItemType File
}
```

### Environment-Specific Configuration

Use different configurations for different environments:

```powershell
# Development environment
.\Initialize-DevContainer.ps1 -Environment "dev" `
                             -SkipProduction `
                             -EnableDebugging

# Production environment  
.\Initialize-DevContainer.ps1 -Environment "prod" `
                             -StrictValidation `
                             -EnableMonitoring
```

## Troubleshooting Configuration

Common configuration issues and solutions:

### PowerShell Execution Policy

```powershell
# Fix execution policy issues
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Azure Authentication

```powershell
# Verify Azure connection
az account show
az account set --subscription "your-subscription-id"
```

### Docker Configuration

```bash
# Verify Docker daemon
docker version
docker info
```

For more troubleshooting help, see the [Troubleshooting Guide](/docs/troubleshooting/).

## Next Steps

- Learn about [Testing Framework](/docs/testing/)
- Explore [Examples](/docs/examples/)
- Check [PowerShell Modules](/docs/powershell/)
