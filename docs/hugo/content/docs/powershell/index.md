---
title: "PowerShell Module"
linkTitle: "PowerShell"
weight: 5
description: >
  Learn about the DevContainer Accelerator PowerShell module for advanced automation and project management.
---

# DevContainer Accelerator PowerShell Module

The DevContainer Accelerator is a comprehensive PowerShell module that provides advanced automation capabilities for Infrastructure as Code projects.

## Overview

The module includes **12+ automation functions** designed to streamline:

- **Project Creation** - Automated project setup and initialization
- **Backend Management** - Cross-subscription Terraform state management
- **Configuration** - Environment and tool configuration
- **Validation** - Comprehensive project validation and testing
- **Documentation** - Automated documentation generation

## Installation

### Quick Installation

```powershell
# Install from the repository
.\Install-DevContainerAccelerator.ps1

# Verify installation
Get-Module DevContainerAccelerator -ListAvailable
```

### Manual Installation

```powershell
# Import the module directly
Import-Module .\DevContainerAccelerator\DevContainerAccelerator.psm1 -Force

# Check available functions
Get-Command -Module DevContainerAccelerator
```

### Persistent Installation

```powershell
# Install to PowerShell modules directory
$modulePath = "$env:PSModulePath".Split(';')[0]
Copy-Item -Path ".\DevContainerAccelerator" -Destination $modulePath -Recurse -Force

# Import in profile for automatic loading
Add-Content $PROFILE "Import-Module DevContainerAccelerator"
```

## Core Functions

### Project Management

#### New-IaCProject

Creates a complete Infrastructure as Code project with full configuration:

```powershell
# Basic project creation
New-IaCProject -ProjectName "my-app" `
               -TenantId "your-tenant-id" `
               -SubscriptionId "your-subscription-id"

# Advanced project with all features
New-IaCProject -ProjectName "enterprise-app" `
               -TenantId "your-tenant-id" `
               -SubscriptionId "your-subscription-id" `
               -ProjectType "both" `
               -Environment "prod" `
               -Location "westus2" `
               -CreateBackend `
               -IncludeExamples `
               -InitializeGit `
               -EnableSecurity
```

**Parameters:**
- `ProjectName` - Name of the project (required)
- `TenantId` - Azure tenant ID (required)
- `SubscriptionId` - Azure subscription ID (required)
- `ProjectType` - "terraform", "bicep", or "both" (default: "terraform")
- `Environment` - Environment name (default: "dev")
- `Location` - Azure region (default: "eastus")
- `CreateBackend` - Create Terraform backend automatically
- `IncludeExamples` - Include example configurations
- `InitializeGit` - Initialize Git repository
- `EnableSecurity` - Enable security scanning tools

#### Initialize-DevContainer

Initializes DevContainer in existing projects:

```powershell
# Basic initialization
Initialize-DevContainer -TenantId "your-tenant-id" `
                       -SubscriptionId "your-subscription-id"

# With custom configuration
Initialize-DevContainer -TenantId "your-tenant-id" `
                       -SubscriptionId "your-subscription-id" `
                       -ProjectName "existing-project" `
                       -Environment "staging" `
                       -ConfigureBicep `
                       -ConfigureTerraform
```

### Backend Management

#### New-TerraformBackend

Creates and configures Terraform state backends:

```powershell
# Basic backend creation
$backend = New-TerraformBackend -SubscriptionId "your-subscription-id" `
                               -TenantId "your-tenant-id" `
                               -ProjectName "my-app" `
                               -Environment "dev"

# Cross-subscription backend
$backend = New-TerraformBackend -SubscriptionId "project-subscription-id" `
                               -BackendSubscriptionId "backend-subscription-id" `
                               -TenantId "your-tenant-id" `
                               -ProjectName "shared-app" `
                               -Environment "prod" `
                               -Location "centralus"

# Output backend configuration
Write-Host "Storage Account: $($backend.StorageAccountName)"
Write-Host "Resource Group: $($backend.ResourceGroupName)"
Write-Host "Container: $($backend.ContainerName)"
```

**Backend Features:**
- Automatic resource group creation
- Storage account with encryption
- Container initialization
- Access key retrieval
- Cross-subscription support
- Naming convention enforcement

#### Test-TerraformBackend

Validates backend configuration and connectivity:

```powershell
# Test backend connectivity
$result = Test-TerraformBackend -SubscriptionId "your-subscription-id" `
                               -ResourceGroupName "rg-terraform-state" `
                               -StorageAccountName "sttfstate001"

if ($result.Success) {
    Write-Host "✅ Backend is accessible and properly configured"
} else {
    Write-Host "❌ Backend issues found:"
    $result.Issues | ForEach-Object { Write-Host "  - $_" }
}
```

#### Get-TerraformBackendConfig

Retrieves backend configuration for Terraform:

```powershell
# Get backend configuration
$config = Get-TerraformBackendConfig -SubscriptionId "your-subscription-id" `
                                    -ProjectName "my-app" `
                                    -Environment "dev"

# Generate Terraform backend configuration
$terraformConfig = @"
terraform {
  backend "azurerm" {
    resource_group_name  = "$($config.ResourceGroupName)"
    storage_account_name = "$($config.StorageAccountName)"
    container_name       = "$($config.ContainerName)"
    key                  = "terraform.tfstate"
  }
}
"@

$terraformConfig | Out-File "backend.tf"
```

### Configuration Management

#### Set-DevContainerConfiguration

Configures DevContainer settings and environment:

```powershell
# Configure for Terraform development
Set-DevContainerConfiguration -ProjectType "terraform" `
                             -TerraformVersion "1.6.0" `
                             -EnableTflint `
                             -EnableCheckov

# Configure for Bicep development
Set-DevContainerConfiguration -ProjectType "bicep" `
                             -BicepVersion "0.22.6" `
                             -EnablePSRule `
                             -EnableSecurity

# Configure for both platforms
Set-DevContainerConfiguration -ProjectType "both" `
                             -EnableAllTools `
                             -SecurityLevel "strict"
```

#### Get-DevContainerConfiguration

Retrieves current configuration settings:

```powershell
# Get current configuration
$config = Get-DevContainerConfiguration

# Display configuration
Write-Host "Project Type: $($config.ProjectType)"
Write-Host "Terraform Version: $($config.TerraformVersion)"
Write-Host "Bicep Version: $($config.BicepVersion)"
Write-Host "Security Enabled: $($config.SecurityEnabled)"
```

### Validation and Testing

#### Test-DevContainerSetup

Comprehensive validation of DevContainer setup:

```powershell
# Basic validation
$result = Test-DevContainerSetup

# Detailed validation with specific checks
$result = Test-DevContainerSetup -Path "." `
                                -CheckSyntax `
                                -CheckConfiguration `
                                -CheckExamples `
                                -Detailed

# Display results
if ($result.Success) {
    Write-Host "✅ All validations passed" -ForegroundColor Green
    Write-Host "Tests run: $($result.TestsRun)"
    Write-Host "Duration: $($result.Duration)"
} else {
    Write-Host "❌ Validation issues found:" -ForegroundColor Red
    $result.Issues | ForEach-Object { 
        Write-Host "  - $($_.Category): $($_.Message)" -ForegroundColor Yellow
    }
}
```

#### Invoke-SecurityScan

Runs comprehensive security scanning:

```powershell
# Run all security tools
$scanResult = Invoke-SecurityScan -Path "." `
                                 -RunCheckov `
                                 -RunTfsec `
                                 -RunPSRule `
                                 -ExportResults

# Display security summary
Write-Host "Security Scan Results:"
Write-Host "Checkov: $($scanResult.Checkov.Status)"
Write-Host "TFSec: $($scanResult.TFSec.Status)"
Write-Host "PSRule: $($scanResult.PSRule.Status)"

# Check for critical issues
if ($scanResult.CriticalIssues -gt 0) {
    Write-Host "⚠️  $($scanResult.CriticalIssues) critical security issues found" -ForegroundColor Red
}
```

### Documentation

#### Update-ProjectDocumentation

Generates and updates project documentation:

```powershell
# Update all documentation
Update-ProjectDocumentation -Path "." `
                           -UpdateReadme `
                           -GenerateTerraformDocs `
                           -GenerateBicepDocs `
                           -IncludeExamples

# Generate specific documentation
Update-ProjectDocumentation -Path "." `
                           -DocumentationType "terraform" `
                           -OutputFormat "markdown" `
                           -IncludeProviders `
                           -IncludeVariables
```

#### Export-ProjectConfiguration

Exports project configuration for sharing or backup:

```powershell
# Export complete configuration
$config = Export-ProjectConfiguration -Path "." `
                                     -IncludeSecrets:$false `
                                     -Format "json"

$config | ConvertTo-Json -Depth 10 | Out-File "project-config.json"

# Export for CI/CD
Export-ProjectConfiguration -Path "." `
                           -Format "environment" `
                           -OutputFile ".env.ci"
```

## Advanced Usage

### Batch Operations

#### Multi-Environment Management

```powershell
# Setup multiple environments
$environments = @("dev", "staging", "prod")
$locations = @{
    "dev" = "eastus"
    "staging" = "westus"
    "prod" = "centralus"
}

foreach ($env in $environments) {
    Write-Host "Setting up $env environment..." -ForegroundColor Yellow
    
    $params = @{
        ProjectName = "my-app"
        TenantId = "your-tenant-id"
        SubscriptionId = "your-subscription-id"
        Environment = $env
        Location = $locations[$env]
        CreateBackend = $true
    }
    
    New-IaCProject @params
    
    # Validate each environment
    $validation = Test-DevContainerSetup -Path ".\$env"
    Write-Host "$env validation: $($validation.Success ? '✅' : '❌')"
}
```

#### Cross-Subscription Backend Management

```powershell
# Manage backends across multiple subscriptions
$projects = @(
    @{ Name = "app1"; Subscription = "sub1-id"; BackendSub = "backend-sub-id" }
    @{ Name = "app2"; Subscription = "sub2-id"; BackendSub = "backend-sub-id" }
    @{ Name = "app3"; Subscription = "sub3-id"; BackendSub = "backend-sub-id" }
)

foreach ($project in $projects) {
    $backend = New-TerraformBackend -SubscriptionId $project.Subscription `
                                   -BackendSubscriptionId $project.BackendSub `
                                   -TenantId "your-tenant-id" `
                                   -ProjectName $project.Name `
                                   -Environment "prod"
    
    Write-Host "Created backend for $($project.Name): $($backend.StorageAccountName)"
}
```

### Custom Configurations

#### Enterprise Configuration

```powershell
# Enterprise-grade project setup
$enterpriseConfig = @{
    ProjectName = "enterprise-platform"
    TenantId = "your-tenant-id"
    SubscriptionId = "your-subscription-id"
    ProjectType = "both"
    Environment = "prod"
    Location = "westus2"
    CreateBackend = $true
    EnableSecurity = $true
    SecurityLevel = "strict"
    ComplianceFramework = "SOC2"
    EnableMonitoring = $true
    EnableLogging = $true
    EnableBackup = $true
    Tags = @{
        Department = "Engineering"
        CostCenter = "12345"
        Environment = "Production"
        Compliance = "SOC2"
    }
}

New-IaCProject @enterpriseConfig

# Apply enterprise security policies
Invoke-SecurityScan -Path "." -ComplianceLevel "enterprise"
```

#### Development Team Configuration

```powershell
# Setup for development team
$teamConfig = @{
    ProjectType = "terraform"
    Environment = "dev"
    EnableWatchMode = $true
    EnableQuickTests = $true
    DeveloperMode = $true
    VerboseLogging = $true
}

Set-DevContainerConfiguration @teamConfig

# Setup team-specific validation
$validation = @{
    RequiredTags = @("Owner", "Project", "Environment")
    NamingConvention = "kebab-case"
    SecurityLevel = "relaxed"
    EnablePreCommitHooks = $true
}

Set-ValidationConfiguration @validation
```

## Integration Examples

### CI/CD Integration

#### Azure DevOps

```powershell
# Setup for Azure DevOps pipeline
$ciConfig = @{
    Platform = "AzureDevOps"
    EnableAutomation = $true
    GeneratePipeline = $true
    PipelineFile = "azure-pipelines.yml"
    EnableTesting = $true
    EnableSecurity = $true
}

Initialize-CIIntegration @ciConfig
```

#### GitHub Actions

```powershell
# Setup for GitHub Actions
$githubConfig = @{
    Platform = "GitHubActions"
    WorkflowPath = ".github/workflows"
    EnableSecrets = $true
    EnableEnvironments = $true
    MatrixStrategy = $true
}

Initialize-CIIntegration @githubConfig
```

### Monitoring Integration

```powershell
# Setup monitoring and alerting
$monitoringConfig = @{
    EnableAzureMonitor = $true
    EnableApplicationInsights = $true
    EnableLogAnalytics = $true
    AlertingRules = @(
        "deployment-failures",
        "security-violations",
        "performance-degradation"
    )
}

Initialize-MonitoringIntegration @monitoringConfig
```

## Error Handling and Debugging

### Common Issues and Solutions

```powershell
# Debug authentication issues
Test-AzureAuthentication -TenantId "your-tenant-id" -Verbose

# Debug backend connectivity
Test-TerraformBackend -SubscriptionId "your-subscription-id" `
                     -ResourceGroupName "rg-terraform-state" `
                     -StorageAccountName "sttfstate001" `
                     -Verbose

# Debug module loading
Import-Module DevContainerAccelerator -Verbose -Force

# Get detailed error information
$Error[0] | Format-List * -Force
```

### Logging and Diagnostics

```powershell
# Enable detailed logging
$env:DEVCONTAINER_DEBUG = "true"
$env:DEVCONTAINER_LOG_LEVEL = "verbose"

# Run with diagnostics
Test-DevContainerSetup -Path "." -Verbose -Debug

# Export diagnostic information
Export-DiagnosticInformation -Path "." -OutputFile "diagnostics.json"
```

## Best Practices

### Module Usage

1. **Import Once**: Import the module at the beginning of your session
2. **Use Splatting**: Use parameter splatting for complex function calls
3. **Error Handling**: Always check return values and handle errors
4. **Logging**: Enable logging for troubleshooting
5. **Testing**: Validate configurations after changes

### Performance Optimization

```powershell
# Cache authentication for multiple operations
Connect-AzAccount -TenantId "your-tenant-id"

# Use background jobs for parallel operations
$jobs = @()
foreach ($env in $environments) {
    $jobs += Start-Job -ScriptBlock {
        param($environment)
        # Your parallel operations here
    } -ArgumentList $env
}

$jobs | Wait-Job | Receive-Job
```

### Security Best Practices

```powershell
# Never store secrets in code
$secureParams = @{
    TenantId = $env:AZURE_TENANT_ID
    SubscriptionId = $env:AZURE_SUBSCRIPTION_ID
    ClientSecret = ConvertTo-SecureString $env:AZURE_CLIENT_SECRET -AsPlainText -Force
}

# Use managed identities when possible
$params = @{
    UseManagedIdentity = $true
    SubscriptionId = "your-subscription-id"
}
```

For more information and advanced examples, see the complete module documentation and the [Examples section](/docs/examples/).
