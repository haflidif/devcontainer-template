---
title: "Configuration"
linkTitle: "Configuration"
weight: 2
description: >
  Learn how to customize the DevContainer template for your specific Infrastructure as Code projects.
---

# Configuration

The DevContainer template is highly configurable to meet the needs of different Infrastructure as Code projects and team workflows.

## DevContainer Configuration

### Main Configuration File

The primary configuration is in `.devcontainer/devcontainer.json`:

```json
{
  "name": "Infrastructure as Code DevContainer",
  "build": {
    "dockerfile": "Dockerfile",
    "args": {
      "TERRAFORM_VERSION": "1.6.0",
      "TERRAGRUNT_VERSION": "0.52.0",
      "AZURE_CLI_VERSION": "2.53.0"
    }
  },
  "features": {
    "ghcr.io/devcontainers/features/azure-cli:1": {},
    "ghcr.io/devcontainers/features/docker-in-docker:2": {},
    "ghcr.io/devcontainers/features/kubectl-helm-minikube:1": {}
  },
  "customizations": {
    "vscode": {
      "extensions": [
        "ms-azuretools.vscode-bicep",
        "hashicorp.terraform",
        "ms-vscode.powershell"
      ]
    }
  }
}
```

### Environment Variables

Configure your environment in `.devcontainer/devcontainer.env`:

```bash
# Azure Configuration
AZURE_TENANT_ID=your-tenant-id
AZURE_SUBSCRIPTION_ID=your-subscription-id
AZURE_CLIENT_ID=your-client-id

# Project Configuration
PROJECT_NAME=my-infrastructure-project
PROJECT_TYPE=terraform
ENVIRONMENT=dev
LOCATION=eastus

# Backend Configuration
BACKEND_RESOURCE_GROUP=rg-terraform-state
BACKEND_STORAGE_ACCOUNT=sttfstate
BACKEND_CONTAINER_NAME=tfstate

# Tool Versions (optional overrides)
TERRAFORM_VERSION=1.6.0
BICEP_VERSION=0.22.6
TFLINT_VERSION=0.48.0
```

## Tool Configuration

### Terraform Configuration

Configure Terraform settings in your project:

#### terraform.tf (Backend Configuration)
```hcl
terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "sttfstate"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}
```

#### .tflint.hcl (Linting Configuration)
```hcl
plugin "azurerm" {
    enabled = true
    version = "0.21.0"
    source  = "github.com/terraform-linters/tflint-ruleset-azurerm"
}

rule "terraform_required_version" {
  enabled = true
}

rule "terraform_required_providers" {
  enabled = true
}
```

### Bicep Configuration

Configure Bicep in `bicepconfig.json`:

```json
{
  "analyzers": {
    "core": {
      "verbose": false,
      "enabled": true,
      "rules": {
        "no-unused-params": {
          "level": "warning"
        },
        "no-unused-vars": {
          "level": "warning"
        }
      }
    }
  },
  "moduleAliases": {
    "br": {
      "public": {
        "registry": "mcr.microsoft.com",
        "modulePath": "bicep"
      }
    }
  }
}
```

### Security Scanning Configuration

#### Checkov Configuration (.checkov.yml)
```yaml
framework:
  - terraform
  - bicep
  - dockerfile

skip-check:
  - CKV_AZURE_1  # Example: Skip specific checks
  - CKV2_AZURE_1

quiet: false
compact: false
soft-fail: false

output:
  - cli
  - json
  - junit
```

#### PSRule Configuration (ps-rule.yaml)
```yaml
requires:
  - PSRule.Rules.Azure

configuration:
  AZURE_PARAMETER_FILE_EXPANSION: true
  AZURE_BICEP_FILE_EXPANSION: true

rule:
  baseline: Azure.GA_2023_06

output:
  culture:
    - 'en-US'
  format: Wide
```

## PowerShell Module Configuration

### DevContainer Accelerator Settings

The PowerShell module can be configured via parameters or configuration files:

#### Default Configuration
```powershell
# Default settings in modular architecture
$script:DefaultConfig = @{
    TerraformVersion = "1.6.0"
    BicepVersion = "0.22.6"
    DefaultLocation = "eastus"
    DefaultEnvironment = "dev"
    BackendNamingPattern = "st{0}tfstate{1}"  # {0}=project, {1}=environment
    ResourceGroupPattern = "rg-{0}-{1}"       # {0}=project, {1}=environment
}
```

#### Custom Configuration File
Create `DevContainerConfig.json` in your project root:

```json
{
  "defaultLocation": "westus2",
  "defaultEnvironment": "prod",
  "backendNaming": {
    "storageAccount": "st{0}state{1}",
    "resourceGroup": "rg-{0}-tfstate-{1}",
    "containerName": "tfstate"
  },
  "toolVersions": {
    "terraform": "1.6.0",
    "bicep": "0.22.6",
    "tflint": "0.48.0"
  },
  "security": {
    "enableCheckov": true,
    "enableTfsec": true,
    "enablePSRule": true
  }
}
```

## VS Code Configuration

### Tasks Configuration

The template includes pre-configured tasks in `.vscode/tasks.json`:

```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Test DevContainer (Quick)",
      "type": "shell",
      "command": "pwsh",
      "args": ["-File", "./tests/Test-DevContainer.ps1", "-Mode", "Quick"],
      "group": "test",
      "presentation": {
        "echo": true,
        "reveal": "always",
        "focus": false,
        "panel": "shared"
      }
    }
  ]
}
```

### Extensions Configuration

Recommended extensions are automatically installed:

```json
{
  "recommendations": [
    "ms-azuretools.vscode-bicep",
    "hashicorp.terraform",
    "ms-vscode.powershell",
    "ms-vscode.vscode-json",
    "redhat.vscode-yaml",
    "ms-python.python"
  ]
}
```

### Settings Configuration

Project-specific settings in `.vscode/settings.json`:

```json
{
  "terraform.languageServer.enable": true,
  "terraform.validation.enable": true,
  "bicep.trace.server": "off",
  "powershell.codeFormatting.preset": "OTBS",
  "files.associations": {
    "*.tf": "terraform",
    "*.tfvars": "terraform",
    "*.bicep": "bicep"
  }
}
```

## Project Type Configuration

### Terraform-Only Projects

For Terraform-only projects, set `PROJECT_TYPE=terraform`:

```bash
PROJECT_TYPE=terraform
```

This configures:
- Terraform-specific linting rules
- Terraform documentation generation
- Terraform-focused VS Code extensions
- Terraform backend management

### Bicep-Only Projects

For Bicep-only projects, set `PROJECT_TYPE=bicep`:

```bash
PROJECT_TYPE=bicep
```

This configures:
- Bicep-specific validation rules
- ARM template generation
- Bicep-focused extensions
- Azure Resource Manager deployment

### Multi-Tool Projects

For projects using both Terraform and Bicep, set `PROJECT_TYPE=both`:

```bash
PROJECT_TYPE=both
```

This enables:
- Full tool chain for both platforms
- Cross-platform validation
- Complete example sets
- Unified documentation

## Environment-Specific Configuration

### Development Environment

```bash
ENVIRONMENT=dev
# Enables development-friendly settings:
# - Verbose logging
# - Additional debugging tools
# - Relaxed security policies for testing
```

### Production Environment

```bash
ENVIRONMENT=prod
# Enables production-ready settings:
# - Enhanced security scanning
# - Strict validation rules
# - Cost optimization checks
# - Compliance validation
```

### Staging Environment

```bash
ENVIRONMENT=staging
# Balanced configuration:
# - Production-like validation
# - Development debugging capabilities
# - Performance testing tools
```

## Advanced Configuration

### Custom Docker Image

To use a custom base image, modify `.devcontainer/Dockerfile`:

```dockerfile
# Use custom base image
FROM your-registry/custom-iac-image:latest

# Install additional tools
RUN apt-get update && apt-get install -y \
    your-custom-tool \
    another-tool

# Copy custom configurations
COPY custom-configs/ /etc/
```

### Multi-Stage Configuration with Modular Approach

For complex projects, use modular staged configuration:

```powershell
# Import required modules
Import-Module .\modules\ProjectModule.psm1
Import-Module .\modules\DevContainerModule.psm1

# Stage 1: Basic setup
New-ProjectConfiguration -ProjectName "my-project" -ConfigStage "basic"
Initialize-DevContainer -ProjectPath . -ProjectType "terraform"

# Stage 2: Add advanced features
Set-ProjectFeatures -Features @("monitoring", "logging", "security")
Update-DevContainerConfig -AddFeatures @("monitoring", "logging")

# Stage 3: Production readiness
Enable-ProductionFeatures -ProjectPath . -EnableSecurity
Test-ProjectConfiguration -ProjectPath . -ValidationLevel "Production"
```

### Custom Validation Rules

Add custom validation to `tests/Custom.Tests.ps1`:

```powershell
Describe "Custom Project Validation" -Tags "Custom" {
    It "Should have required custom files" {
        Test-Path "path/to/custom/file.txt" | Should -Be $true
    }
    
    It "Should meet custom naming conventions" {
        # Your custom validation logic
    }
}
```

## Configuration Best Practices

### Security

1. **Never commit secrets** to version control
2. **Use environment variables** for sensitive data
3. **Enable security scanning** in all environments
4. **Validate configurations** regularly

### Performance

1. **Use appropriate tool versions** for your project
2. **Configure resource limits** in DevContainer
3. **Optimize Docker layer caching**
4. **Use multi-stage builds** for complex setups

### Maintenance

1. **Version your configurations**
2. **Document custom settings**
3. **Test configuration changes**
4. **Automate configuration validation**

For troubleshooting configuration issues, see the [Troubleshooting Guide](/docs/troubleshooting/).
