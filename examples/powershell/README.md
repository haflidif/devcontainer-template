# PowerShell Examples

This directory contains PowerShell scripts demonstrating automation capabilities and usage patterns for the DevContainer Accelerator module.

## 📋 Contents

### Script Files
- **Backend-Management-Examples.ps1** - Advanced Terraform backend management scenarios
- **PowerShell-Usage.ps1** - DevContainer Accelerator module usage examples and patterns

## 🚀 Quick Start

### 1. Import the Module
```powershell
# Import the DevContainer Accelerator module
Import-Module ../DevContainerAccelerator

# Verify module is loaded
Get-Module DevContainerAccelerator
```

### 2. Run Examples
```powershell
# Execute backend management examples
./Backend-Management-Examples.ps1

# Explore module usage patterns
./PowerShell-Usage.ps1
```

## 📁 Script Descriptions

### Backend-Management-Examples.ps1
Comprehensive examples demonstrating:

#### Basic Backend Operations
- Creating new Terraform backends
- Configuring remote state storage
- Setting up encryption and access controls

#### Advanced Scenarios
- Cross-subscription backend management
- Multi-environment backend strategies
- Backend validation and health checks
- Automated backend provisioning workflows

#### Integration Patterns
- CI/CD pipeline integration
- Team collaboration scenarios
- Security and compliance configurations

### PowerShell-Usage.ps1
Module usage examples covering:

#### Core Functions
- Module installation and setup
- Function discovery and help
- Parameter validation and examples

#### Utility Functions
- GUID validation helpers
- Colorized output functions
- Error handling patterns

#### Workflow Examples
- Complete deployment workflows
- Integration with Azure CLI
- Terraform automation patterns

## 🔧 Module Functions Overview

### Backend Management
```powershell
# Create a new backend
New-TerraformBackend -StorageAccountName "mytfstate" -ResourceGroupName "rg-tfstate"

# Initialize backend configuration
Initialize-TerraformBackend -BackendConfigPath "./backend.conf"

# Validate backend connectivity
Test-TerraformBackend -StorageAccount "mytfstate" -Container "tfstate"
```

### Utility Functions
```powershell
# Validate GUIDs
Test-IsGuid -InputString "123e4567-e89b-12d3-a456-426614174000"

# Colorized output
Write-ColorOutput -Message "Success!" -Color "Green"
Write-ColorOutput -Message "Warning!" -Color "Yellow"
```

### Azure Integration
```powershell
# Verify Azure authentication
Test-AzureAuthentication

# Get current subscription context
Get-AzureContext

# Set up service principal authentication
Set-AzureServicePrincipal -TenantId $tenantId -ClientId $clientId -ClientSecret $secret
```

## 🧪 Testing and Validation

### Function Testing
```powershell
# Test individual functions
Test-IsGuid -InputString "invalid-guid"  # Should return $false
Test-IsGuid -InputString "123e4567-e89b-12d3-a456-426614174000"  # Should return $true

# Test backend operations (requires Azure access)
Test-TerraformBackend -StorageAccount "nonexistent" -Container "test"  # Should handle gracefully
```

### Module Validation
```powershell
# Check module exports
Get-Command -Module DevContainerAccelerator

# Verify help documentation
Get-Help New-TerraformBackend -Full
Get-Help Write-ColorOutput -Examples
```

## 🔄 Workflow Examples

### Complete Backend Setup Workflow
```powershell
# 1. Authenticate to Azure
Connect-AzAccount

# 2. Create resource group for state storage
New-AzResourceGroup -Name "rg-terraform-state" -Location "East US"

# 3. Create Terraform backend
$backend = New-TerraformBackend -StorageAccountName "mytfstate" -ResourceGroupName "rg-terraform-state"

# 4. Initialize Terraform with the backend
Initialize-TerraformBackend -BackendConfig $backend.Configuration

# 5. Verify backend connectivity
Test-TerraformBackend -StorageAccount $backend.StorageAccountName -Container $backend.ContainerName
```

### Multi-Environment Setup
```powershell
# Development environment
$devBackend = New-TerraformBackend -StorageAccountName "devtfstate" -Environment "dev"

# Staging environment
$stagingBackend = New-TerraformBackend -StorageAccountName "stagingtfstate" -Environment "staging"

# Production environment
$prodBackend = New-TerraformBackend -StorageAccountName "prodtfstate" -Environment "prod"
```

## 🔒 Security Considerations

### Authentication Methods
The scripts support multiple authentication methods:
- **Azure CLI**: Recommended for local development
- **Service Principal**: Required for CI/CD pipelines
- **Managed Identity**: For Azure-hosted runners

### Access Control
```powershell
# Set up proper RBAC for backend storage
Set-BackendAccessControl -StorageAccount "mytfstate" -PrincipalId $principalId -Role "Storage Blob Data Contributor"

# Configure Key Vault integration
Set-KeyVaultIntegration -VaultName "myvault" -SecretName "tf-backend-key"
```

## 🚀 CI/CD Integration

### Pipeline Examples
```powershell
# Azure DevOps pipeline step
./Backend-Management-Examples.ps1 -Environment $env:ENVIRONMENT -WhatIf:$false

# GitHub Actions integration
$backend = New-TerraformBackend -StorageAccountName $env:TF_BACKEND_STORAGE -WhatIf:$($env:GITHUB_EVENT_NAME -eq "pull_request")
```

### Environment Variables
The scripts respect common environment variables:
- `ARM_SUBSCRIPTION_ID`
- `ARM_TENANT_ID`
- `ARM_CLIENT_ID`
- `ARM_CLIENT_SECRET`
- `TF_BACKEND_*` variables

## 🔗 Related Examples

- [Terraform Examples](../terraform/) - Infrastructure templates
- [Configuration Files](../configuration/) - Tool configurations
- [Getting Started Guide](../getting-started/) - Initial setup

## 📚 Additional Resources

- [PowerShell Documentation](https://docs.microsoft.com/powershell/)
- [Azure PowerShell Documentation](https://docs.microsoft.com/powershell/azure/)
- [Terraform Backend Configuration](https://developer.hashicorp.com/terraform/language/settings/backends)
- [Azure Storage for Terraform State](https://docs.microsoft.com/azure/developer/terraform/store-state-in-azure-storage)
