---
title: "Getting Started"
linkTitle: "Getting Started"
weight: 1
description: >
  Quick setup guide for the DevContainer template with automated validation and testing.
---

# Getting Started

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

### 2. Initialize with Automation

Run the initialization script with your Azure details:

```powershell
.\Initialize-DevContainer.ps1 -TenantId "your-tenant-id" `
                             -SubscriptionId "your-subscription-id" `
                             -ProjectName "my-project" `
                             -ProjectType "terraform" `
                             -Environment "dev" `
                             -Location "eastus" `
                             -CreateBackend `
                             -IncludeExamples
```

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

### PowerShell Module Installation

For enhanced automation and reusable workflows:

```powershell
# Install the DevContainer Accelerator module
.\Install-DevContainerAccelerator.ps1

# Create a complete new project
New-IaCProject -ProjectName "my-infrastructure" `
               -TenantId "your-tenant-id" `
               -SubscriptionId "your-subscription-id" `
               -ProjectType "both" `
               -Environment "dev" `
               -Location "eastus" `
               -InitializeGit `
               -IncludeExamples
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

- **[Configuration Guide](/docs/configuration/)** - Customize the template for your needs
- **[Testing Framework](/docs/testing/)** - Learn about the Pester testing system
- **[Examples](/docs/examples/)** - Review practical implementation examples
- **[PowerShell Module](/docs/powershell/)** - Use advanced automation features

## Verification

To verify your setup is working correctly:

### Quick Health Check

```powershell
# Test basic functionality
.\tests\Test-DevContainer.ps1 -Mode Quick -Tags "Syntax,Module"

# Expected output: All tests should pass ✅
```

### Full Validation

```powershell
# Run all 38 comprehensive tests
.\tests\Test-DevContainer.ps1 -Mode Full

# Expected: Detailed test results with summary
```

### CI Mode (for automation)

```powershell
# Generate XML output for CI/CD
.\tests\Test-DevContainer.ps1 -Mode CI

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

For more detailed troubleshooting, see the [Troubleshooting Guide](/docs/troubleshooting/).

## What's Next?

Now that your DevContainer is set up:

- Explore the **[configuration options](/docs/configuration/)**
- Learn about **[testing workflows](/docs/testing/)**
- Check out **[practical examples](/docs/examples/)**
- Set up **[automation with PowerShell](/docs/powershell/)**
