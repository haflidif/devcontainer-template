# Terraform Examples

This directory contains Terraform configuration examples and best practices for Azure infrastructure deployment.

## 📋 Contents

### Core Files
- **main.tf** - Main Terraform configuration with example Azure resources
- **variables.tf** - Input variable definitions with descriptions and validation
- **outputs.tf** - Output value definitions for resource references
- **terraform.tfvars.example** - Example variable values template

### Configuration Files
- **.tflint.hcl** - Terraform linting rules and configuration

## 🚀 Quick Start

### 1. Copy and Configure Variables
```bash
# Copy the example variables file
cp terraform.tfvars.example terraform.tfvars

# Edit with your specific values
# Required: subscription_id, tenant_id, resource_group_name, etc.
```

### 2. Initialize and Plan
```bash
# Initialize Terraform
terraform init

# Review the deployment plan
terraform plan
```

### 3. Deploy Infrastructure
```bash
# Apply the configuration
terraform apply
```

## 📁 File Descriptions

### main.tf
Contains example Azure resources including:
- Resource Group
- Virtual Network
- Storage Account
- Key Vault
- Log Analytics Workspace

### variables.tf
Defines input variables with:
- Type constraints
- Default values
- Validation rules
- Descriptions

### outputs.tf
Exposes important resource attributes:
- Resource IDs
- Connection strings
- Endpoint URLs
- Important configuration values

### terraform.tfvars.example
Template for your environment-specific values:
```hcl
# Azure Configuration
subscription_id = "your-subscription-id"
tenant_id      = "your-tenant-id"

# Project Configuration
project_name = "myproject"
environment  = "dev"
location     = "East US"

# Resource Configuration
enable_monitoring = true
storage_tier     = "Standard"
```

## 🔧 Terraform Backend Configuration

The DevContainer is pre-configured to support Azure Storage backends. Use the PowerShell automation:

```powershell
# Import the module
Import-Module ../DevContainerAccelerator

# Create a backend
New-TerraformBackend -StorageAccountName "mytfstate" -ResourceGroupName "tf-state-rg"
```

## 🧪 Testing and Validation

### Pre-deployment Validation
```bash
# Format code
terraform fmt -recursive

# Validate configuration
terraform validate

# Run security scans
tfsec .
checkov -d .
```

### Post-deployment Testing
```bash
# Verify outputs
terraform output

# Test connectivity
terraform console
```

## 📊 Monitoring and Troubleshooting

### View Terraform State
```bash
# List resources in state
terraform state list

# Show specific resource
terraform state show azurerm_resource_group.main
```

### Debug Issues
```bash
# Enable detailed logging
export TF_LOG=DEBUG
terraform plan

# Check Azure CLI authentication
az account show
az account list
```

## 🔄 Best Practices Implemented

### Security
- ✅ Remote state storage in Azure
- ✅ State file encryption
- ✅ Service principal authentication
- ✅ Key Vault integration for secrets

### Code Quality
- ✅ Variable validation
- ✅ Consistent naming conventions
- ✅ Resource tagging strategy
- ✅ Output documentation

### DevOps Integration
- ✅ Pre-commit hooks (see [../configuration/](../configuration/))
- ✅ Automated testing with tfsec/checkov
- ✅ CI/CD pipeline compatibility

## 🔗 Related Examples

- [PowerShell Backend Management](../powershell/Backend-Management-Examples.ps1)
- [Configuration Files](../configuration/)
- [Getting Started Guide](../getting-started/)

## 📚 Additional Resources

- [Terraform Azure Provider Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Azure Terraform Best Practices](https://docs.microsoft.com/azure/developer/terraform/best-practices)
- [Terraform State Management](https://developer.hashicorp.com/terraform/language/state)
