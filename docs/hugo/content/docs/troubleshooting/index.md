---
title: "Troubleshooting"
linkTitle: "Troubleshooting"
weight: 6
description: >
  Common issues, solutions, and debugging techniques for the DevContainer template.
---

# Troubleshooting Guide

This guide covers common issues you might encounter when using the DevContainer template and provides step-by-step solutions.

## Quick Diagnostics

### Health Check Command

Run a quick health check to identify common issues:

```powershell
# Quick validation
.\tests\Test-DevContainer.ps1 -Mode Quick

# Detailed diagnostics
.\tests\Test-DevContainer.ps1 -Mode Full -Verbose
```

### System Requirements Check

```powershell
# Check PowerShell version
$PSVersionTable.PSVersion

# Check Docker status
docker version

# Check available modules
Get-Module -ListAvailable | Where-Object Name -like "*Pester*"
```

## Common Issues

### 1. PowerShell Execution Policy

**Symptoms:**
- Scripts won't run
- "Execution of scripts is disabled" error

**Solution:**
```powershell
# Check current policy
Get-ExecutionPolicy

# Set appropriate policy
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# For development environments
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
```

### 2. Pester Module Issues

**Symptoms:**
- "Pester module not found" errors
- Tests fail to run
- Version compatibility issues

**Solutions:**

#### Install Pester 5.0+
```powershell
# Remove old Pester versions
Get-Module Pester -ListAvailable | Where-Object Version -lt "5.0" | Remove-Module -Force

# Install latest Pester
Install-Module -Name Pester -Force -SkipPublisherCheck -Scope CurrentUser

# Verify installation
Get-Module Pester -ListAvailable
```

#### Force Pester Update
```powershell
# Uninstall all versions
Get-Module Pester -ListAvailable | Uninstall-Module -Force

# Install clean
Install-Module -Name Pester -RequiredVersion "5.5.0" -Force -SkipPublisherCheck
```

#### Use Legacy Mode
```powershell
# If Pester issues persist, use legacy validation
.\tests\Validate-DevContainer.ps1 -ForceLegacy
```

### 3. Docker and DevContainer Issues

**Symptoms:**
- Container won't start
- "Docker daemon not running" error
- DevContainer build failures

**Solutions:**

#### Docker Desktop Issues
```powershell
# Check Docker status
docker version
docker info

# Restart Docker service (Windows)
Restart-Service Docker

# Test Docker functionality
docker run hello-world
```

#### DevContainer Configuration
```powershell
# Validate DevContainer configuration
code .devcontainer/devcontainer.json

# Check for syntax errors
Get-Content .devcontainer/devcontainer.json | ConvertFrom-Json
```

#### Container Build Issues
```powershell
# Build container manually for debugging
docker build -f .devcontainer/Dockerfile .

# Check build logs
docker build --no-cache -f .devcontainer/Dockerfile .
```

### 4. Azure Authentication Issues

**Symptoms:**
- "Authentication failed" errors
- "Subscription not found" errors
- Backend creation failures

**Solutions:**

#### Check Azure CLI Authentication
```powershell
# Check current login status
az account show

# Login with specific tenant
az login --tenant "your-tenant-id"

# Set active subscription
az account set --subscription "your-subscription-id"

# List available subscriptions
az account list --output table
```

#### PowerShell Azure Authentication
```powershell
# Install Azure PowerShell module
Install-Module -Name Az -Force -AllowClobber

# Connect to Azure
Connect-AzAccount -TenantId "your-tenant-id"

# Select subscription
Select-AzSubscription -SubscriptionId "your-subscription-id"
```

#### Service Principal Authentication
```powershell
# Using service principal
$credential = New-Object System.Management.Automation.PSCredential(
    $env:AZURE_CLIENT_ID,
    (ConvertTo-SecureString $env:AZURE_CLIENT_SECRET -AsPlainText -Force)
)

Connect-AzAccount -ServicePrincipal -Credential $credential -TenantId $env:AZURE_TENANT_ID
```

### 5. Backend Storage Issues

**Symptoms:**
- Terraform backend initialization fails
- "Storage account not found" errors
- Access denied errors

**Solutions:**

#### Verify Backend Resources
```powershell
# Check if resources exist
az group show --name "rg-terraform-state"
az storage account show --name "sttfstate001" --resource-group "rg-terraform-state"

# List storage containers
az storage container list --account-name "sttfstate001"
```

#### Test Backend Connectivity
```powershell
# Using PowerShell module
Test-TerraformBackend -SubscriptionId "your-subscription-id" `
                     -ResourceGroupName "rg-terraform-state" `
                     -StorageAccountName "sttfstate001" `
                     -Verbose
```

#### Recreate Backend
```powershell
# Delete and recreate backend
Remove-AzResourceGroup -Name "rg-terraform-state" -Force

# Create new backend
New-TerraformBackend -SubscriptionId "your-subscription-id" `
                     -TenantId "your-tenant-id" `
                     -ProjectName "my-project" `
                     -Environment "dev"
```

### 6. VS Code Task Issues

**Symptoms:**
- Tasks not appearing in VS Code
- Task execution failures
- "Command not found" errors

**Solutions:**

#### Verify Tasks Configuration
```powershell
# Check tasks.json syntax
Get-Content .vscode/tasks.json | ConvertFrom-Json

# Validate task definitions
code .vscode/tasks.json
```

#### Reload VS Code Window
1. Press `Ctrl+Shift+P`
2. Type "Developer: Reload Window"
3. Press Enter

#### Reset Tasks
```powershell
# Backup existing tasks
Copy-Item .vscode/tasks.json .vscode/tasks.json.backup

# Restore default tasks
Copy-Item examples/configuration/tasks.json .vscode/tasks.json
```

### 7. Module Import Issues

**Symptoms:**
- "Module not found" errors
- Function not available errors
- Version conflicts

**Solutions:**

#### Force Module Reload
```powershell
# Remove and re-import module
Remove-Module DevContainerAccelerator -Force -ErrorAction SilentlyContinue
Import-Module .\DevContainerAccelerator\DevContainerAccelerator.psm1 -Force

# Verify functions are available
Get-Command -Module DevContainerAccelerator
```

#### Check Module Path
```powershell
# Verify module exists
Test-Path .\DevContainerAccelerator\DevContainerAccelerator.psm1

# Check module manifest
Test-ModuleManifest .\DevContainerAccelerator\DevContainerAccelerator.psd1
```

#### Install Dependencies
```powershell
# Install required modules
Install-Module -Name Az.Accounts -Force
Install-Module -Name Az.Resources -Force
Install-Module -Name Az.Storage -Force
```

## Performance Issues

### Slow Test Execution

**Solutions:**

#### Use Quick Mode
```powershell
# Run only essential tests
.\tests\Test-DevContainer.ps1 -Mode Quick

# Run specific test categories
.\tests\Test-DevContainer.ps1 -Tags "Syntax,Module"
```

#### Optimize Container Performance
```powershell
# Increase Docker memory allocation
# Docker Desktop → Settings → Resources → Advanced → Memory: 8GB

# Use SSD for Docker storage
# Docker Desktop → Settings → Resources → Advanced → Disk Image Location
```

#### Parallel Test Execution
```powershell
# Run tests in parallel (if supported)
.\tests\Test-DevContainer.ps1 -Mode Quick -Parallel
```

### Slow Module Loading

**Solutions:**

#### Profile Startup Time
```powershell
# Measure import time
Measure-Command { Import-Module .\DevContainerAccelerator -Force }
```

#### Optimize Module Loading
```powershell
# Disable unnecessary features during development
$env:DEVCONTAINER_SKIP_CHECKS = "true"
Import-Module .\DevContainerAccelerator -Force
```

## Debugging Techniques

### Enable Verbose Logging

```powershell
# Enable detailed logging for all operations
$VerbosePreference = "Continue"
$DebugPreference = "Continue"

# Run with verbose output
.\tests\Test-DevContainer.ps1 -Mode Full -Verbose -Debug
```

### Trace Script Execution

```powershell
# Enable PowerShell script tracing
Set-PSDebug -Trace 2

# Run script with tracing
.\Initialize-DevContainer.ps1 -TenantId "your-tenant-id" -SubscriptionId "your-subscription-id"

# Disable tracing
Set-PSDebug -Off
```

### Debug Pester Tests

```powershell
# Run specific test with debugging
Invoke-Pester -Path ".\tests\DevContainer.Tests.ps1" `
              -Tag "Syntax" `
              -Debug

# Debug individual test blocks
Invoke-Pester -Path ".\tests\DevContainer.Tests.ps1" `
              -TestName "Should validate PowerShell syntax" `
              -Debug
```

### Capture Error Details

```powershell
# Capture and analyze errors
try {
    .\Initialize-DevContainer.ps1 -TenantId "your-tenant-id" -SubscriptionId "your-subscription-id"
} catch {
    $error[0] | Format-List * -Force
    $error[0].Exception | Format-List * -Force
    $error[0].ScriptStackTrace
}
```

## Environment-Specific Issues

### Windows-Specific Issues

#### Line Ending Issues
```powershell
# Fix line endings for Git
git config core.autocrlf true

# Fix specific files
dos2unix script-name.sh
```

#### Path Length Limitations
```powershell
# Enable long paths in Windows
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "LongPathsEnabled" -Value 1

# Use shorter project names
```

### Container-Specific Issues

#### Permission Issues
```powershell
# Fix file permissions in container
sudo chown -R vscode:vscode /workspace
sudo chmod +x scripts/*.sh
```

#### Resource Limitations
```powershell
# Check container resources
docker stats

# Increase container limits in devcontainer.json
"runArgs": ["--memory=8g", "--cpus=4"]
```

## Getting Help

### Check Documentation

1. **README.md** - Main project documentation
2. **tests/README.md** - Testing framework documentation
3. **examples/** - Practical examples and use cases
4. **docs/** - Comprehensive documentation

### Enable Diagnostic Mode

```powershell
# Export diagnostic information
Export-DiagnosticInformation -Path "." -OutputFile "diagnostics.json"

# Run comprehensive validation
.\tests\Test-DevContainer.ps1 -Mode Full -ExportResults
```

### Collect Support Information

```powershell
# System information
$PSVersionTable | Out-String
Get-ComputerInfo | Select-Object WindowsProductName, WindowsVersion, TotalPhysicalMemory

# Docker information
docker version
docker info

# Module information
Get-Module -ListAvailable | Where-Object Name -like "*Pester*" | Format-Table
Get-Module -ListAvailable | Where-Object Name -like "*Az*" | Format-Table

# Azure CLI information
az version
```

### Reset to Clean State

If all else fails, reset to a clean state:

```powershell
# 1. Remove all modules
Get-Module DevContainerAccelerator | Remove-Module -Force
Get-Module Pester | Remove-Module -Force

# 2. Clean PowerShell cache
Remove-Item -Path "$env:LOCALAPPDATA\Microsoft\Windows\PowerShell\ModuleAnalysisCache" -Force -ErrorAction SilentlyContinue

# 3. Restart PowerShell session
exit

# 4. Reinstall dependencies
Install-Module -Name Pester -Force -SkipPublisherCheck
.\Install-DevContainerAccelerator.ps1

# 5. Validate setup
.\tests\Test-DevContainer.ps1 -Mode Quick
```

## Prevention Best Practices

### Regular Maintenance

```powershell
# Weekly: Update modules
Update-Module Pester
Update-Module Az

# Monthly: Clean module cache
Remove-Item -Path "$env:LOCALAPPDATA\Microsoft\Windows\PowerShell\ModuleAnalysisCache" -Force

# Quarterly: Validate full setup
.\tests\Test-DevContainer.ps1 -Mode Full
```

### Development Practices

1. **Use Version Control** - Commit working configurations
2. **Test Changes** - Run tests before committing
3. **Document Customizations** - Track configuration changes
4. **Backup Configurations** - Save working setups
5. **Monitor Performance** - Watch for degradation

### Team Coordination

1. **Standardize Versions** - Use consistent tool versions
2. **Share Configurations** - Use common settings
3. **Document Workflows** - Create team runbooks
4. **Regular Updates** - Keep dependencies current

## Still Having Issues?

If you're still experiencing problems:

1. **Check the GitHub Issues** - Search existing issues
2. **Create a New Issue** - Provide diagnostic information
3. **Use Legacy Mode** - Fall back to basic validation
4. **Seek Community Help** - Ask in project discussions

Remember to include:
- Operating system and version
- PowerShell version
- Docker version
- Error messages and stack traces
- Steps to reproduce the issue
- Diagnostic information from the troubleshooting commands above
