---
title: "Backend Configuration"
linkTitle: "Backend Configuration"
weight: 3
description: >
  Configure Terraform backends for local development or Azure production with automatic infrastructure provisioning.
---

## Overview

The DevContainer template supports flexible Terraform backend configuration, allowing you to seamlessly switch between local development and Azure production scenarios.

## Backend Types

### 🔧 Local Backend

Perfect for development, testing, and learning scenarios.

**Features:**
- ✅ No cloud credentials required
- ✅ Instant setup and initialization
- ✅ State stored locally in `.terraform` directory
- ✅ Works completely offline
- ✅ Ideal for experimentation and learning

**Usage:**
```powershell
.\Initialize-DevContainer.ps1 -ProjectName "my-project" `
                             -BackendType "local" `
                             -IncludeExamples
```

**Generated Configuration:**
```hcl
# main.tf
terraform {
  backend "local" {}
  # backend "azurerm" {}
}
```

### ☁️ Azure Backend

Enterprise-ready backend with automatic Azure infrastructure provisioning.

**Features:**
- ✅ Automatic resource group creation
- ✅ Storage account provisioning with unique naming
- ✅ Blob container setup for state storage
- ✅ Complete `backend.tfvars` generation
- ✅ Team collaboration support
- ✅ Production-ready security

**Usage:**
```powershell
.\Initialize-DevContainer.ps1 -TenantId "your-tenant-id" `
                             -SubscriptionId "your-subscription-id" `
                             -ProjectName "my-project" `
                             -BackendType "azure" `
                             -Environment "dev" `
                             -Location "eastus" `
                             -IncludeExamples
```

**Generated Configuration:**
```hcl
# main.tf
terraform {
  backend "azurerm" {}
  # backend "local" {}
}
```

**Generated backend.tfvars:**
```hcl
# backend.tfvars
resource_group_name  = "my-project-tfstate-rg"
storage_account_name = "myprojectdev1a2b3c4d"
container_name       = "tfstate"
key                  = "dev.terraform.tfstate"
```

## Azure Backend Infrastructure

### Automatic Resource Creation

When using Azure backend, the script automatically creates:

1. **Resource Group**: `{ProjectName}-tfstate-rg`
2. **Storage Account**: Unique name following Azure conventions
3. **Blob Container**: `tfstate` container for state files
4. **Access Configuration**: Proper permissions and security settings

### Naming Conventions

**Resource Group:**
- Pattern: `{ProjectName}-tfstate-rg`
- Example: `my-project-tfstate-rg`

**Storage Account:**
- Pattern: `{projectname}{environment}{randomhash}`
- Length: Exactly 24 characters (Azure requirement)
- Example: `myprojectdev1a2b3c4d5e`
- Validation: Availability check before creation

**State File:**
- Pattern: `{Environment}.terraform.tfstate`
- Example: `dev.terraform.tfstate`

## Using the Backend

### Local Backend Usage

```powershell
# Initialize Terraform (local backend)
terraform init

# Plan and apply as normal
terraform plan
terraform apply
```

### Azure Backend Usage

```powershell
# Initialize with backend configuration
terraform init -backend-config=backend.tfvars

# Plan and apply as normal
terraform plan
terraform apply
```

## Backend Migration

### From Local to Azure

1. **Create Azure backend project:**
   ```powershell
   .\Initialize-DevContainer.ps1 -ProjectName "my-project" `
                                -BackendType "azure" `
                                -TenantId "xxx" -SubscriptionId "xxx"
   ```

2. **Migrate existing state:**
   ```powershell
   # Copy your existing .tf files to the new project
   # Then initialize with the new backend
   terraform init -backend-config=backend.tfvars
   ```

### From Azure to Local

1. **Create local backend project:**
   ```powershell
   .\Initialize-DevContainer.ps1 -ProjectName "my-project-local" `
                                -BackendType "local"
   ```

2. **Initialize with local backend:**
   ```powershell
   terraform init
   ```

## Advanced Configuration

### Custom Backend Settings

For advanced scenarios, you can modify the generated configurations:

**Custom State File Name:**
```hcl
# backend.tfvars
key = "custom-name.terraform.tfstate"
```

**Custom Container:**
```hcl
# backend.tfvars
container_name = "custom-container"
```

### Multiple Environments

Create separate backend configurations for different environments:

```powershell
# Development environment
.\Initialize-DevContainer.ps1 -ProjectName "myapp" `
                             -Environment "dev" `
                             -BackendType "azure"

# Production environment  
.\Initialize-DevContainer.ps1 -ProjectName "myapp" `
                             -Environment "prod" `
                             -BackendType "azure"
```

## Troubleshooting

### Common Issues

**Azure Authentication:**
```powershell
# Ensure you're logged into Azure
az login
az account set --subscription "your-subscription-id"
```

**Storage Account Name Conflicts:**
The script automatically generates unique names and checks availability. If issues persist, try a different project name.

**Backend Configuration Errors:**
Ensure the `backend.tfvars` file exists and contains valid values:
```powershell
Get-Content backend.tfvars
```

### Validation

Test your backend configuration:
```powershell
# Validate the backend setup
terraform init -backend-config=backend.tfvars

# Check state location
terraform state list
```

## Best Practices

1. **Development**: Use local backend for development and testing
2. **Production**: Always use Azure backend for production workloads
3. **Team Collaboration**: Share `backend.tfvars` securely with team members
4. **Environment Separation**: Use different storage accounts for dev/prod
5. **Access Control**: Configure appropriate Azure RBAC permissions
6. **Backup**: Azure backend provides built-in redundancy and backup

## Security Considerations

- **Storage Account Access**: Configured with minimum required permissions
- **State File Encryption**: Azure Storage provides encryption at rest
- **Network Security**: Consider network access restrictions for production
- **Access Logging**: Enable Azure Storage logging for audit trails

---

**Next Steps:** Learn about [Project Configuration](../configuration/) to customize your DevContainer setup further.
