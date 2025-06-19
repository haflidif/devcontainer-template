---
title: "Troubleshooting"
linkTitle: "Troubleshooting"
weight: 7
description: >
  Common issues and solutions for the DevContainer template setup and usage.
---

# Troubleshooting

This guide covers common issues you might encounter when using the DevContainer template and their solutions.

## Installation Issues

### PowerShell Execution Policy Error

**Problem:** Getting execution policy errors when running PowerShell scripts.

```
.\Initialize-DevContainer.ps1 : File cannot be loaded because running scripts is disabled on this system.
```

**Solution:**
```powershell
# Check current execution policy
Get-ExecutionPolicy

# Set execution policy for current user
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Or bypass for a single command
powershell -ExecutionPolicy Bypass -File ".\Initialize-DevContainer.ps1"
```

---

### Docker Desktop Not Running

**Problem:** Docker-related errors during DevContainer setup.

```
Cannot connect to the Docker daemon. Is the docker daemon running?
```

**Solution:**
1. Start Docker Desktop
2. Verify Docker is running:
   ```powershell
   docker version
   docker info
   ```
3. If using WSL2, ensure it's properly configured:
   ```bash
   wsl --status
   wsl --update
   ```

---

### Missing Dependencies

**Problem:** Required tools not found during prerequisite check.

```
Missing required tools: git, az, terraform
```

**Solution:**
Install missing tools:

```powershell
# Install Git
winget install Git.Git

# Install Azure CLI
winget install Microsoft.AzureCLI

# Install Terraform
winget install Hashicorp.Terraform

# Install PowerShell 7 (if needed)
winget install Microsoft.PowerShell

# Verify installations
git --version
az --version
terraform --version
pwsh --version
```

## Azure Authentication Issues

### Azure CLI Not Logged In

**Problem:** Azure operations fail with authentication errors.

```
Please run 'az login' to setup account.
```

**Solution:**
```powershell
# Login to Azure CLI
az login

# Login with specific tenant
az login --tenant your-tenant-id

# Verify login
az account show

# Set specific subscription
az account set --subscription your-subscription-id
```

---

### Service Principal Authentication

**Problem:** Automated authentication fails in CI/CD pipelines.

**Solution:**
```powershell
# Create service principal
az ad sp create-for-rbac --name "DevContainer-SP" --role contributor --scopes /subscriptions/your-subscription-id

# Login with service principal
az login --service-principal -u CLIENT_ID -p CLIENT_SECRET --tenant TENANT_ID

# Set environment variables for automation
$env:AZURE_CLIENT_ID = "your-client-id"
$env:AZURE_CLIENT_SECRET = "your-client-secret"
$env:AZURE_TENANT_ID = "your-tenant-id"
$env:AZURE_SUBSCRIPTION_ID = "your-subscription-id"
```

---

### Subscription Access Issues

**Problem:** Cannot access specified Azure subscription.

```
The subscription 'subscription-id' doesn't exist or you don't have access.
```

**Solution:**
1. Verify subscription ID:
   ```powershell
   az account list --output table
   ```
2. Check permissions:
   ```powershell
   az role assignment list --assignee your-user@domain.com --subscription your-subscription-id
   ```
3. Request access from subscription administrator if needed.

## DevContainer Issues

### VS Code DevContainer Extension Not Working

**Problem:** DevContainer doesn't open properly in VS Code.

**Solution:**
1. Install/update DevContainer extension:
   - Open VS Code
   - Install "Dev Containers" extension by Microsoft
2. Verify Docker integration:
   - Check VS Code settings for Docker
   - Restart VS Code after Docker Desktop starts
3. Check DevContainer configuration:
   ```powershell
   # Validate devcontainer.json syntax
   Get-Content .devcontainer/devcontainer.json | ConvertFrom-Json
   ```

---

### Container Build Failures

**Problem:** DevContainer fails to build or starts but tools are missing.

**Solution:**
1. Check DevContainer logs:
   - In VS Code: Command Palette → "Dev Containers: Show Log"
2. Rebuild container:
   - Command Palette → "Dev Containers: Rebuild Container"
3. Clear Docker cache:
   ```powershell
   docker system prune -a
   ```
4. Check feature versions in devcontainer.json:
   ```json
   {
     "features": {
       "ghcr.io/devcontainers/features/azure-cli:1": {
         "version": "latest"
       }
     }
   }
   ```

---

### Permission Issues in Container

**Problem:** File permission errors inside the DevContainer.

**Solution:**
1. Check file ownership:
   ```bash
   ls -la
   ```
2. Fix ownership if needed:
   ```bash
   sudo chown -R vscode:vscode /workspace
   ```
3. Add to devcontainer.json:
   ```json
   {
     "remoteUser": "vscode",
     "updateRemoteUserUID": true
   }
   ```

## Testing Issues

### Pester Module Conflicts

**Problem:** Pester version conflicts causing test failures.

```
The specified module 'Pester' with version '5.3.0' was not loaded because no valid module file was found.
```

**Solution:**
```powershell
# Remove all Pester versions
Get-Module Pester -ListAvailable | Remove-Module -Force

# Install latest Pester
Install-Module -Name Pester -Force -SkipPublisherCheck

# Import Pester explicitly
Import-Module Pester -Force

# Verify version
Get-Module Pester
```

---

### Test Discovery Issues

**Problem:** Tests not being discovered or running.

**Solution:**
1. Check test file naming:
   - Files should end with `.Tests.ps1`
2. Verify Describe blocks:
   ```powershell
   Describe "Test Suite Name" {
       It "Should do something" {
           # Test code
       }
   }
   ```
3. Run tests with verbose output:
   ```powershell
   Invoke-Pester -Path .\tests\ -Verbose
   ```

---

### Security Scanning Failures

**Problem:** TFSec, Checkov, or PSRule failures.

**Solution:**
1. Install missing tools:
   ```powershell
   # Install TFSec
   choco install tfsec
   
   # Install Checkov
   pip install checkov
   
   # Install PSRule
   Install-Module PSRule.Rules.Azure -Force
   ```
2. Configure exclusions:
   ```yaml
   # .tfsec.yml
   exclude:
     - azure-storage-default-action-deny
   ```
3. Update security rules:
   ```powershell
   Update-Module PSRule.Rules.Azure
   ```

## Terraform Issues

### Terraform Backend Initialization

**Problem:** Backend initialization failures.

```
Error: Failed to get existing workspaces: storage: service returned error: StatusCode=404
```

**Solution:**
1. Create storage account and container:
   ```powershell
   # Create storage account
   az storage account create --name mystorageaccount --resource-group myresourcegroup --location eastus --sku Standard_LRS
   
   # Create container
   az storage container create --name tfstate --account-name mystorageaccount
   ```
2. Configure backend properly:
   ```hcl
   terraform {
     backend "azurerm" {
       resource_group_name  = "myresourcegroup"
       storage_account_name = "mystorageaccount"
       container_name       = "tfstate"
       key                  = "terraform.tfstate"
     }
   }
   ```
3. Initialize with backend config:
   ```powershell
   terraform init -reconfigure
   ```

---

### Provider Authentication

**Problem:** Terraform provider authentication issues.

```
Error: building AzureRM Client: obtain subscription() from Azure CLI: parsing json result from the Azure CLI
```

**Solution:**
1. Re-authenticate Azure CLI:
   ```powershell
   az logout
   az login
   az account set --subscription your-subscription-id
   ```
2. Clear Terraform cache:
   ```powershell
   Remove-Item .terraform -Recurse -Force
   terraform init
   ```

---

### State Lock Issues

**Problem:** Terraform state locked.

```
Error: Error locking state: Error acquiring the state lock
```

**Solution:**
1. Check for running operations
2. Force unlock (use carefully):
   ```powershell
   terraform force-unlock LOCK_ID
   ```
3. Or wait for lock timeout

## Bicep Issues

### Bicep CLI Installation

**Problem:** Bicep commands not found.

```
'bicep' is not recognized as an internal or external command
```

**Solution:**
```powershell
# Install Bicep via Azure CLI
az bicep install

# Update Bicep
az bicep upgrade

# Verify installation
az bicep version

# Install manually if needed
winget install Microsoft.Bicep
```

---

### Template Compilation Errors

**Problem:** Bicep template compilation failures.

**Solution:**
1. Check syntax:
   ```powershell
   az bicep build --file main.bicep
   ```
2. Validate against schema:
   ```powershell
   az deployment group validate --resource-group myresourcegroup --template-file main.bicep
   ```
3. Fix common issues:
   - Missing parameter types
   - Invalid resource references
   - Circular dependencies

## Network and Connectivity Issues

### Proxy Configuration

**Problem:** Network operations fail due to corporate proxy.

**Solution:**
1. Configure proxy for tools:
   ```powershell
   # PowerShell proxy
   $proxy = [System.Net.WebRequest]::DefaultWebProxy
   $proxy.Credentials = [System.Net.CredentialCache]::DefaultCredentials
   
   # Git proxy
   git config --global http.proxy http://proxy.company.com:8080
   
   # Azure CLI proxy
   az config set core.proxy_server=http://proxy.company.com:8080
   
   # Docker proxy
   # Add to Docker Desktop settings or ~/.docker/config.json
   ```

---

### DNS Resolution Issues

**Problem:** Cannot resolve hostnames inside DevContainer.

**Solution:**
1. Add DNS configuration to devcontainer.json:
   ```json
   {
     "runArgs": [
       "--dns=8.8.8.8",
       "--dns=8.8.4.4"
     ]
   }
   ```
2. Or add to Docker Desktop settings

## Performance Issues

### Slow Container Startup

**Problem:** DevContainer takes a long time to start.

**Solution:**
1. Reduce features in devcontainer.json
2. Use specific versions instead of "latest":
   ```json
   {
     "features": {
       "ghcr.io/devcontainers/features/terraform:1": {
         "version": "1.5.0"
       }
     }
   }
   ```
3. Enable BuildKit for Docker:
   ```powershell
   $env:DOCKER_BUILDKIT = 1
   ```

---

### Large File Handling

**Problem:** Git operations slow due to large files.

**Solution:**
1. Use Git LFS for large files:
   ```powershell
   git lfs install
   git lfs track "*.zip"
   git add .gitattributes
   ```
2. Add exclusions to .gitignore:
   ```
   *.log
   *.tmp
   .terraform/
   node_modules/
   ```

## CI/CD Pipeline Issues

### GitHub Actions Failures

**Problem:** GitHub Actions workflow failing.

**Solution:**
1. Check workflow syntax:
   ```yaml
   name: Test
   on: [push]
   jobs:
     test:
       runs-on: ubuntu-latest
       steps:
         - uses: actions/checkout@v4
   ```
2. Verify secrets are configured:
   - `AZURE_TENANT_ID`
   - `AZURE_SUBSCRIPTION_ID`
   - `AZURE_CLIENT_ID`
   - `AZURE_CLIENT_SECRET`
3. Add debugging:
   ```yaml
   - name: Debug
     run: |
       echo "Runner: ${{ runner.os }}"
       echo "Event: ${{ github.event_name }}"
   ```

---

### Azure DevOps Pipeline Issues

**Problem:** Azure DevOps pipeline authentication failures.

**Solution:**
1. Configure service connection
2. Grant proper permissions
3. Use correct task versions:
   ```yaml
   - task: AzureCLI@2
     inputs:
       azureSubscription: 'service-connection-name'
       scriptType: 'pscore'
   ```

## Getting Additional Help

### Enable Detailed Logging

```powershell
# Enable verbose logging
$VerbosePreference = "Continue"

# Enable debug logging
$DebugPreference = "Continue"

# Run with detailed output
.\Initialize-DevContainer.ps1 -Verbose -Debug
```

### Diagnostic Information

```powershell
# Collect diagnostic information
function Get-DiagnosticInfo {
    @{
        PowerShellVersion = $PSVersionTable.PSVersion
        OperatingSystem = $PSVersionTable.OS
        DockerVersion = (docker --version)
        AzureCLIVersion = (az --version | Select-Object -First 1)
        GitVersion = (git --version)
        TerraformVersion = (terraform --version | Select-Object -First 1)
    }
}

Get-DiagnosticInfo | ConvertTo-Json
```

### Common Diagnostic Commands

```powershell
# Test all prerequisites
.\tests\Test-DevContainer.ps1 -Mode Quick

# Validate Azure connectivity
Test-AzureConnection

# Check Docker status
docker info

# Verify module imports
Get-Module CommonModule, AzureModule, DevContainerModule

# Check environment variables
Get-ChildItem Env: | Where-Object Name -like "*AZURE*"
```

### Community Support

- **GitHub Issues**: [Report bugs and request features](https://github.com/haflidif/devcontainer-template/issues)
- **Discussions**: [Community discussions and Q&A](https://github.com/haflidif/devcontainer-template/discussions)
- **Documentation**: [Complete documentation](https://haflidif.github.io/devcontainer-template/)

## Error Reporting

When reporting issues, please include:

1. **Environment information**:
   ```powershell
   Get-DiagnosticInfo | ConvertTo-Json
   ```

2. **Error message** (full text)

3. **Steps to reproduce**

4. **Expected vs actual behavior**

5. **Configuration files** (sanitized)

This helps maintainers diagnose and resolve issues quickly.

## Next Steps

- Review [Configuration](../configuration/) for customization options
- Check [Examples](../examples/) for working implementations  
- See [API Reference](../api/) for detailed function documentation
