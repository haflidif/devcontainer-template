---
title: "Getting Started"
linkTitle: "Getting Started"
weight: 1
description: >
  Quick setup guide for the DevContainer template with automated validation and testing.
---

Welcome! This guide will help you set up the DevContainer template quickly and efficiently.

## Prerequisites

Before you begin, ensure you have:

- **Git** installed and configured
- **Visual Studio Code** with the Dev Containers extension
- **Docker Desktop** running
- **PowerShell 5.1+** or **PowerShell Core 7+**
- **Azure CLI** (optional, for Azure authentication)

## Quick Setup (Recommended)

For the fastest setup with automated validation:

### 1. Clone the Repository

```powershell
git clone https://github.com/haflidif/devcontainer-template.git
cd devcontainer-template
```

### 2. Choose Your Backend Type

**🆕 Enhanced Backend Support**: Choose between local development or Azure production backends.

#### **Option A: Local Development Backend** ⚡ *Fastest Setup*

Perfect for development, testing, and learning:

```powershell
.\Initialize-DevContainer.ps1 -ProjectName "my-project" `
                             -BackendType "local" `
                             -IncludeExamples
```

**Features:**
- ✅ No Azure credentials required
- ✅ Instant setup (local state storage)
- ✅ Perfect for development and testing
- ✅ Works completely offline

#### **Option B: Azure Production Backend** ☁️ *Enterprise Ready*

Automatically creates Azure infrastructure for production use:

```powershell
.\Initialize-DevContainer.ps1 -TenantId "your-tenant-id" `
                             -SubscriptionId "your-subscription-id" `
                             -ProjectName "my-project" `
                             -BackendType "azure" `
                             -Environment "dev" `
                             -Location "eastus" `
                             -IncludeExamples
```

**Features:**
- ✅ Automatic Azure backend infrastructure creation
- ✅ Generates complete `backend.tfvars` configuration
- ✅ Enterprise-ready state management
- ✅ Team collaboration support
- ✅ Zero-touch setup

### 3. Validate Setup

Test that everything is working correctly:

```powershell
# Run comprehensive tests
.\tests\Test-DevContainer.ps1

# Or run quick validation
.\tests\Test-DevContainer.ps1 -Mode Quick
```

### 4. Open in VS Code

```powershell
code .
```

When prompted, choose **"Reopen in Container"** to start the DevContainer.

## Advanced Setup Options

### Modular Architecture

The template now uses a modular PowerShell architecture with specialized modules:

```powershell
# Main initialization script loads all modules automatically
.\Initialize-DevContainer.ps1 -TenantId "your-tenant-id" `
                              -SubscriptionId "your-subscription-id" `
                              -ProjectName "my-project"

# Interactive mode (prompts for inputs)
.\Initialize-DevContainer.ps1

# WhatIf mode (preview without changes)
.\Initialize-DevContainer.ps1 -TenantId "your-tenant-id" `
                              -SubscriptionId "your-subscription-id" `
                              -ProjectName "my-project" `
                              -WhatIf
```

### Manual Module Usage

For advanced users who want to use individual modules:

```powershell
# Load specific modules as needed
Import-Module .\modules\CommonModule.psm1
Import-Module .\modules\AzureModule.psm1
Import-Module .\modules\DevContainerModule.psm1

# Test prerequisites
if (-not (Test-Prerequisites)) {
    Write-Error "Prerequisites not met"
    exit 1
}

# Create project manually
Initialize-ProjectDirectory -ProjectName "my-project" -ProjectPath "C:\Projects"
```

### Manual Setup

If you prefer manual configuration:

1. **Copy DevContainer Files**:
   ```powershell
   # Create .devcontainer directory in your project
   mkdir .devcontainer
   
   # Copy configuration files
   copy .devcontainer/* your-project/.devcontainer/
   ```

2. **Configure Environment**:
   ```powershell
   # Copy and customize environment file
   copy .devcontainer/devcontainer.env.example .devcontainer/devcontainer.env
   # Edit with your specific values
   ```

3. **Add Examples** (optional):
   ```powershell
   copy -r examples your-project/
   ```

## Next Steps

After setup, explore these areas:

- **[Configuration Guide](../configuration/)** - Customize the template for your needs
- **[Testing Framework](../testing/)** - Learn about the Pester testing system
- **[Examples](../examples/)** - Review practical implementation examples
- **[Module Reference](../api/)** - Complete function documentation

## Verification

To verify your setup is working correctly:

### Quick Health Check

```powershell
# Validate DevContainer setup using modular testing
.\tests\Test-DevContainer.ps1 -Mode Quick

# Expected output: All validations should pass ✅
```

### Full Testing

```powershell
# Run all comprehensive tests
.\tests\Run-Tests.ps1

# Run specific test categories
.\tests\Run-Tests.ps1 -Tags "Syntax,Module,Integration"
```

### Module Testing

```powershell
# Test individual modules
Invoke-Pester .\tests\unit\CommonModule.Tests.ps1
Invoke-Pester .\tests\unit\AzureModule.Tests.ps1
Invoke-Pester .\tests\integration\Initialize-DevContainer.Tests.ps1
```

### CI Mode (for automation)

```powershell
# Run tests with CI output format
.\tests\Run-Tests.ps1 -OutputFormat NUnitXml -OutputFile "TestResults.xml"

# Check exit code
echo $LASTEXITCODE  # Should be 0 for success
```

## Common Issues

If you encounter issues during setup:

1. **PowerShell Execution Policy**:
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

2. **Docker Not Running**:
   - Ensure Docker Desktop is running
   - Check Docker daemon status: `docker version`

3. **Azure Authentication**:
   ```powershell
   # Login to Azure
   az login --tenant your-tenant-id
   ```

4. **Pester Not Available**:
   ```powershell
   # Install Pester 5.0+
   Install-Module -Name Pester -Force -SkipPublisherCheck
   ```

For more detailed troubleshooting, see the [Troubleshooting Guide](../troubleshooting/).

## What's Next?

Now that your DevContainer is set up:

- Explore the **[configuration options](../configuration/)**
- Learn about **[testing workflows](../testing/)**
- Check out **[practical examples](../examples/)**
- Set up **[automation with PowerShell](../powershell/)**
