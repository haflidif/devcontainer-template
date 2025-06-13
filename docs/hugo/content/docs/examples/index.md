---
title: "Examples"
linkTitle: "Examples"
weight: 4
description: >
  Practical examples and use cases for Terraform, Bicep, and PowerShell automation.
---

# Examples and Use Cases

The DevContainer template includes comprehensive examples for common Infrastructure as Code scenarios and automation patterns.

## Overview

The examples are organized by technology and use case:

- **[Getting Started Examples](#getting-started)** - Basic project setup
- **[Terraform Examples](#terraform)** - Infrastructure as Code with Terraform
- **[Bicep Examples](#bicep)** - Azure native Infrastructure as Code
- **[ARM Templates](#arm-templates)** - Azure Resource Manager templates
- **[PowerShell Automation](#powershell-automation)** - Advanced automation scenarios
- **[Configuration Examples](#configuration)** - Tool and environment configuration

## Getting Started

### Quick Project Setup

Simple project initialization:

```powershell
# Clone template and initialize new project
git clone https://github.com/haflidif/devcontainer-template.git my-new-project
cd my-new-project

# Initialize with basic settings
.\Initialize-DevContainer.ps1 -ProjectName "my-app" `
                             -TenantId "your-tenant-id" `
                             -SubscriptionId "your-subscription-id"

# Validate setup
.\tests\Test-DevContainer.ps1 -Mode Quick
```

### Multi-Environment Setup

Setting up development, staging, and production environments:

```powershell
# Development environment
.\Initialize-DevContainer.ps1 -ProjectName "my-app" `
                             -Environment "dev" `
                             -Location "eastus" `
                             -CreateBackend

# Staging environment  
.\Initialize-DevContainer.ps1 -ProjectName "my-app" `
                             -Environment "staging" `
                             -Location "westus" `
                             -CreateBackend

# Production environment
.\Initialize-DevContainer.ps1 -ProjectName "my-app" `
                             -Environment "prod" `
                             -Location "centralus" `
                             -CreateBackend
```

## Terraform Examples

### Basic Azure Infrastructure

**File: `examples/terraform/main.tf`**

```hcl
# Configure the Azure Provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  
  backend "azurerm" {
    # Backend configuration from environment variables
  }
}

provider "azurerm" {
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location

  tags = var.tags
}

# Create a storage account
resource "azurerm_storage_account" "main" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = var.tags
}
```

**File: `examples/terraform/variables.tf`**

```hcl
variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "East US"
}

variable "storage_account_name" {
  description = "Name of the storage account"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    Environment = "dev"
    Project     = "devcontainer-template"
  }
}
```

**File: `examples/terraform/terraform.tfvars.example`**

```hcl
# Copy to terraform.tfvars and customize
resource_group_name    = "rg-my-app-dev"
location              = "East US"
storage_account_name  = "stmyappdev001"

tags = {
  Environment = "dev"
  Project     = "my-app"
  Owner       = "team@company.com"
}
```

### Advanced Terraform with Modules

**File: `examples/terraform/modules/networking/main.tf`**

```hcl
# Virtual Network
resource "azurerm_virtual_network" "main" {
  name                = var.vnet_name
  address_space       = var.address_space
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = var.tags
}

# Subnets
resource "azurerm_subnet" "subnets" {
  for_each = var.subnets

  name                 = each.key
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = each.value.address_prefixes

  dynamic "delegation" {
    for_each = lookup(each.value, "delegation", {})
    content {
      name = delegation.key
      service_delegation {
        name    = delegation.value.name
        actions = delegation.value.actions
      }
    }
  }
}

# Network Security Groups
resource "azurerm_network_security_group" "main" {
  for_each = var.subnets

  name                = "nsg-${each.key}"
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = var.tags
}
```

## Bicep Examples

### Basic Azure Resources

**File: `examples/bicep/main.bicep`**

```bicep
@description('Name of the resource group')
param resourceGroupName string

@description('Azure region for resources')
param location string = resourceGroup().location

@description('Name of the storage account')
param storageAccountName string

@description('Tags to apply to resources')
param tags object = {
  Environment: 'dev'
  Project: 'devcontainer-template'
}

// Storage Account
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
  }
  tags: tags
}

// App Service Plan
resource appServicePlan 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: 'plan-${resourceGroupName}'
  location: location
  sku: {
    name: 'F1'
    tier: 'Free'
  }
  tags: tags
}

// Web App
resource webApp 'Microsoft.Web/sites@2022-09-01' = {
  name: 'app-${uniqueString(resourceGroup().id)}'
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: {
      minTlsVersion: '1.2'
      ftpsState: 'Disabled'
    }
  }
  tags: tags
}

output storageAccountName string = storageAccount.name
output webAppUrl string = 'https://${webApp.properties.defaultHostName}'
```

**File: `examples/bicep/main.bicepparam`**

```bicep
using 'main.bicep'

param resourceGroupName = 'rg-my-app-dev'
param location = 'eastus'
param storageAccountName = 'stmyappdev001'
param tags = {
  Environment: 'dev'
  Project: 'my-app'
  Owner: 'team@company.com'
}
```

### Advanced Bicep with Modules

**File: `examples/bicep/modules/networking.bicep`**

```bicep
@description('Virtual network configuration')
param vnetConfig object

@description('Subnet configurations')
param subnets array

@description('Location for resources')
param location string = resourceGroup().location

@description('Resource tags')
param tags object = {}

// Virtual Network
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: vnetConfig.name
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: vnetConfig.addressPrefixes
    }
    subnets: [for subnet in subnets: {
      name: subnet.name
      properties: {
        addressPrefix: subnet.addressPrefix
        networkSecurityGroup: {
          id: networkSecurityGroups[subnet.name].id
        }
      }
    }]
  }
  tags: tags
}

// Network Security Groups
resource networkSecurityGroups 'Microsoft.Network/networkSecurityGroups@2023-05-01' = [for subnet in subnets: {
  name: 'nsg-${subnet.name}'
  location: location
  properties: {
    securityRules: subnet.securityRules
  }
  tags: tags
}]

output vnetId string = virtualNetwork.id
output subnetIds array = [for i in range(0, length(subnets)): virtualNetwork.properties.subnets[i].id]
```

## PowerShell Automation

### Backend Management Examples

**File: `examples/powershell/Backend-Management-Examples.ps1`**

```powershell
# Import the DevContainer Accelerator module
Import-Module .\DevContainerAccelerator -Force

# Example 1: Create backend for new project
$backendParams = @{
    SubscriptionId = "your-subscription-id"
    TenantId = "your-tenant-id"
    ProjectName = "my-app"
    Environment = "dev"
    Location = "eastus"
}

$backend = New-TerraformBackend @backendParams
Write-Host "Backend created: $($backend.StorageAccountName)"

# Example 2: Manage multiple environments
$environments = @("dev", "staging", "prod")
$locations = @{
    "dev" = "eastus"
    "staging" = "westus"
    "prod" = "centralus"
}

foreach ($env in $environments) {
    $params = @{
        SubscriptionId = "your-subscription-id"
        TenantId = "your-tenant-id"
        ProjectName = "my-app"
        Environment = $env
        Location = $locations[$env]
    }
    
    $backend = New-TerraformBackend @params
    Write-Host "Created $env backend: $($backend.StorageAccountName)"
}

# Example 3: Cross-subscription backend management
$backendSubscription = "backend-subscription-id"
$projectSubscription = "project-subscription-id"

$params = @{
    SubscriptionId = $projectSubscription
    BackendSubscriptionId = $backendSubscription
    TenantId = "your-tenant-id"
    ProjectName = "shared-infrastructure"
    Environment = "prod"
    Location = "centralus"
}

$backend = New-TerraformBackend @params
Write-Host "Cross-subscription backend: $($backend.StorageAccountName)"
```

### Project Automation Examples

**File: `examples/powershell/PowerShell-Usage.ps1`**

```powershell
# Advanced project setup with validation
$projectConfig = @{
    ProjectName = "enterprise-app"
    TenantId = "your-tenant-id"
    SubscriptionId = "your-subscription-id"
    ProjectType = "both"  # Terraform and Bicep
    Environment = "prod"
    Location = "westus2"
    CreateBackend = $true
    IncludeExamples = $true
    EnableSecurity = $true
    EnableMonitoring = $true
}

# Create new project with full configuration
New-IaCProject @projectConfig

# Validate the setup
$validation = Test-DevContainerSetup -Path "." -Detailed
if ($validation.Success) {
    Write-Host "✅ Project setup successful!" -ForegroundColor Green
} else {
    Write-Host "❌ Setup issues found:" -ForegroundColor Red
    $validation.Issues | ForEach-Object { Write-Host "  - $_" }
}

# Generate documentation
Update-ProjectDocumentation -Path "." -IncludeExamples

# Setup CI/CD integration
Initialize-CIIntegration -ProjectPath "." -Platform "GitHubActions"
```

## Configuration Examples

### Tool Configuration

**File: `examples/configuration/terraform.yml`**

```yaml
# Terraform configuration for different scenarios
configurations:
  development:
    terraform_version: "1.6.0"
    provider_versions:
      azurerm: "~> 3.0"
      random: "~> 3.0"
    backend:
      type: "azurerm"
      encryption: false
    validation:
      strict: false
      
  production:
    terraform_version: "1.6.0"
    provider_versions:
      azurerm: "~> 3.0"
      random: "~> 3.0"
    backend:
      type: "azurerm"
      encryption: true
    validation:
      strict: true
      security_scanning: true
```

**File: `examples/configuration/bicep.yml`**

```yaml
# Bicep configuration profiles
profiles:
  development:
    bicep_version: "0.22.6"
    linting:
      level: "warning"
      rules:
        no-unused-params: "warning"
        no-unused-vars: "warning"
    
  production:
    bicep_version: "0.22.6"
    linting:
      level: "error"
      rules:
        no-unused-params: "error"
        no-unused-vars: "error"
        secure-parameter-default: "error"
```

## Real-World Scenarios

### Scenario 1: Multi-Tier Web Application

Complete infrastructure for a web application with database:

```powershell
# Setup project
.\Initialize-DevContainer.ps1 -ProjectName "webapp" `
                             -ProjectType "terraform" `
                             -Environment "prod" `
                             -CreateBackend

# Deploy infrastructure
cd examples/terraform/multi-tier-app
terraform init
terraform plan -var-file="prod.tfvars"
terraform apply -var-file="prod.tfvars"
```

### Scenario 2: Microservices Platform

Infrastructure for a containerized microservices platform:

```powershell
# Setup with Kubernetes support
.\Initialize-DevContainer.ps1 -ProjectName "microservices" `
                             -ProjectType "both" `
                             -Environment "prod" `
                             -AddFeatures @("kubernetes", "monitoring")

# Deploy using Bicep
cd examples/bicep/microservices
az deployment group create --resource-group rg-microservices-prod `
                          --template-file main.bicep `
                          --parameters @prod.parameters.json
```

### Scenario 3: Data Analytics Platform

Big data and analytics infrastructure:

```powershell
# Setup analytics project
New-IaCProject -ProjectName "analytics" `
               -ProjectType "terraform" `
               -Environment "prod" `
               -AddFeatures @("databricks", "synapse", "storage")

# Validate and deploy
.\tests\Test-DevContainer.ps1 -Mode Full
cd terraform/analytics
terraform apply -var-file="analytics-prod.tfvars"
```

## Testing Examples

### Unit Testing Infrastructure

**File: `examples/testing/infrastructure.tests.ps1`**

```powershell
# Test Terraform configurations
Describe "Terraform Configuration Tests" {
    BeforeAll {
        # Setup test environment
        terraform init -backend=false
    }
    
    It "Should validate Terraform syntax" {
        $result = terraform validate
        $LASTEXITCODE | Should -Be 0
    }
    
    It "Should pass security scanning" {
        $result = tfsec .
        $LASTEXITCODE | Should -Be 0
    }
    
    It "Should generate valid plan" {
        $result = terraform plan -out=test.plan
        $LASTEXITCODE | Should -Be 0
    }
}

# Test Bicep templates
Describe "Bicep Template Tests" {
    It "Should compile successfully" {
        $result = bicep build main.bicep
        $LASTEXITCODE | Should -Be 0
    }
    
    It "Should pass linting" {
        $result = bicep lint main.bicep
        $result | Should -Not -Match "Error"
    }
}
```

## Best Practices Examples

### Security Hardening

```powershell
# Enable comprehensive security scanning
$securityConfig = @{
    EnableCheckov = $true
    EnableTfsec = $true
    EnablePSRule = $true
    StrictMode = $true
    ComplianceFramework = "CIS"
}

Set-SecurityConfiguration @securityConfig

# Run security validation
.\tests\Test-DevContainer.ps1 -Tags "Security" -Mode Full
```

### Performance Optimization

```powershell
# Configure for large-scale deployments
$performanceConfig = @{
    ParallelExecution = $true
    CacheEnabled = $true
    OptimizeForSpeed = $true
    ResourceLimits = @{
        Memory = "8GB"
        CPU = "4"
    }
}

Set-PerformanceConfiguration @performanceConfig
```

## Integration Examples

### CI/CD Pipeline Integration

**GitHub Actions Example:**

```yaml
# .github/workflows/infrastructure.yml
name: Infrastructure Deployment

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Setup DevContainer
        uses: devcontainers/ci@v0.3
        with:
          runCmd: |
            ./tests/Test-DevContainer.ps1 -Mode CI
            terraform init
            terraform plan
```

For more advanced examples and use cases, see the complete examples in the `examples/` directory of the repository.
