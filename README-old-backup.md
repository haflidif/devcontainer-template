# Generic Infrastructure as Code DevContainer Template

This is a customizable DevContainer template for Terraform and Bicep development that you can adapt for any Infrastructure as Code project.

> **🚀 Quick Start**: `.\Initialize-DevContainer.ps1` → `.\tests\Test-DevContainer.ps1` → `code .`  
> **✅ 38 Tests**: Comprehensive validation with Pester framework  
> **🔄 CI/CD Ready**: Structured output and automated testing  
> **🛡️ Secure**: Multi-cloud auth, backend management, security scanning

## 🆕 What's New

### **🧪 Modern Testing Framework**
- **Pester 5.0+ integration** with 38 comprehensive tests
- **Multiple execution modes**: Quick, Full, CI, and Watch
- **Tag-based test selection** for faster development cycles
- **Automatic fallback** to legacy validation when Pester unavailable
- **CI/CD ready** with structured XML output and exit codes

### **⚡ Enhanced PowerShell Automation**
- **Cross-subscription backend support** for centralized state management
- **Interactive guided setup** with validation and smart defaults
- **Advanced backend management** with automated creation and testing
- **DevContainer Accelerator module** with 12+ automation functions

### **🎯 Improved Developer Experience**
- **VS Code task integration** for testing and validation workflows
- **Watch mode testing** for continuous feedback during development
- **Enhanced error reporting** with detailed diagnostics and troubleshooting
- **Comprehensive documentation** with migration guides and examples

### **📚 Modern Documentation Platform**
- **Hugo-powered documentation site** with professional Docsy theme
- **GitHub Pages deployment** with automated publishing
- **Comprehensive API reference** for all PowerShell functions
- **Interactive examples** and step-by-step guides
- **Mobile-responsive design** with search functionality

## �️ Included Tools

The devcontainer comes pre-configured with a comprehensive set of Infrastructure as Code development tools:

### **Core Infrastructure Tools**
- **Terraform** - Infrastructure as Code
- **Bicep** - Azure native Infrastructure as Code
- **TFLint** - Terraform linter with cloud provider rules
- **terraform-docs** - Documentation generator
- **Terragrunt** - Terraform wrapper for DRY configurations
- **TFSwitcher** - Easy Terraform version management

### **Security & Compliance**
- **Checkov** - Static analysis for infrastructure security
- **tfsec** - Security scanner for Terraform
- **Terrascan** - Policy as Code security scanner
- **PSRule for Azure** - Azure resource validation

### **Cost & Planning**
- **Infracost** - Cost estimation for infrastructure changes

### **Development Tools**
- **Python** with development packages
- **pre-commit** - Git hook framework
- **Azure CLI** - Azure command line tools
- **PowerShell** - Cross-platform shell
- **Docker CLI** for containerized workflows

## 🚀 Quick Start

## 🚀 Quick Start

### **🎯 Fastest Setup (Recommended)**

For the quickest setup with automated validation and testing:

```powershell
# 1. Clone and initialize with PowerShell automation
git clone https://github.com/haflidif/devcontainer-template.git
cd devcontainer-template

# 2. Run the initialization script with your Azure details
.\Initialize-DevContainer.ps1 -TenantId "your-tenant-id" `
                             -SubscriptionId "your-subscription-id" `
                             -ProjectName "my-project" `
                             -ProjectType "terraform" `
                             -Environment "dev" `
                             -Location "eastus" `
                             -CreateBackend `
                             -IncludeExamples

# 3. Validate everything is working
.\tests\Test-DevContainer.ps1

# 4. Open in VS Code
code .
# Choose "Reopen in Container" when prompted
```

### **🔧 Advanced Setup with PowerShell Module**

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

# Or add to existing project
Initialize-DevContainer -TenantId "your-tenant-id" `
                       -SubscriptionId "your-subscription-id" `
                       -ProjectName "my-existing-project"
```

### Method 1: Initialize a New Project (Basic)
```bash
# Clone this template
git clone https://github.com/haflidif/devcontainer-template.git
cd devcontainer-template

# Initialize the DevContainer environment
./Initialize-DevContainer.ps1

# Install PowerShell module (optional)
./Install-DevContainerAccelerator.ps1
```

### Method 2: Add to Existing Project

If you prefer, you can clone this repository and copy the files:

```bash
# Clone the template repository
git clone https://github.com/haflidif/devcontainer-template.git temp-devcontainer

# Navigate to your project
cd /your-terraform-project

# Create .devcontainer directory
mkdir .devcontainer

# Copy the devcontainer files
cp temp-devcontainer/devcontainer.json .devcontainer/
cp temp-devcontainer/Dockerfile .devcontainer/
cp temp-devcontainer/devcontainer.env.example .devcontainer/
cp -r temp-devcontainer/scripts .devcontainer/

# Optional: Copy examples for reference
cp -r temp-devcontainer/examples .

# Clean up
rm -rf temp-devcontainer
```

2. **Customize the environment:**
   ```bash
   # Copy and edit environment variables
   cp .devcontainer/devcontainer.env.example .devcontainer/devcontainer.env
   
   # Edit with your specific values (Azure tenant, subscription, etc.)
   code .devcontainer/devcontainer.env
   ```

3. **Open in VS Code:**
   ```bash
   # Open your project in VS Code
   code .
   
   # VS Code will detect the .devcontainer and prompt to reopen in container
   # Click "Reopen in Container" when prompted
   ```

4. **First-time setup (inside container):**
   ```bash
   # Authenticate with Azure (for local development)
   az login
   
   # Initialize Terraform (if you have .tf files)
   terraform init
   ```

### **For Windows/PowerShell Users**

```powershell
# Navigate to your existing project
cd C:\your-terraform-project

# Create .devcontainer directory
New-Item -ItemType Directory -Name ".devcontainer" -Force

# Copy devcontainer files (adjust source path to where you downloaded/cloned this template)
Copy-Item "C:\path\to\devcontainer-template\devcontainer.json" ".devcontainer\"
Copy-Item "C:\path\to\devcontainer-template\Dockerfile" ".devcontainer\"
Copy-Item "C:\path\to\devcontainer-template\devcontainer.env.example" ".devcontainer\"
Copy-Item "C:\path\to\devcontainer-template\scripts" ".devcontainer\" -Recurse

# Copy and customize environment
Copy-Item ".devcontainer\devcontainer.env.example" ".devcontainer\devcontainer.env"

# Open in VS Code
code .
```

## 🎯 Available VS Code Tasks

The template includes pre-configured tasks accessible via `Ctrl+Shift+P` → "Tasks: Run Task":

### **Testing & Validation**
- **test devcontainer quick** - Fast validation (syntax, module, structure)
- **test devcontainer full** - Comprehensive test suite with all checks
- **test devcontainer pester** - Direct Pester execution with detailed output
- **test devcontainer syntax only** - PowerShell syntax validation only
- **test devcontainer watch** - Watch mode for continuous testing during development

### **Terraform Tasks**
- **terraform init** - Initialize Terraform
- **terraform plan** - Plan infrastructure changes
- **terraform apply** - Apply changes
- **terraform validate** - Validate configuration
- **terraform format** - Format code
- **terraform destroy** - Destroy infrastructure
- **tflint** - Lint Terraform code
- **terraform-docs generate** - Generate documentation
- **checkov scan** - Security scanning with Checkov
- **tfsec scan** - Security scanning with tfsec
- **infracost breakdown** - Cost estimation
- **terraform full workflow** - Complete validation pipeline
- **terraform security scan** - All security tools
- **terraform documentation** - Format + docs generation

### **Bicep Tasks**
- **bicep build** - Compile current Bicep file
- **bicep build all** - Compile all Bicep files in project
- **bicep lint** - Lint current Bicep file
- **bicep format** - Format current Bicep file
- **bicep decompile** - Convert ARM template to Bicep
- **azure deployment validate** - Validate Azure deployment
- **azure deployment create** - Deploy to Azure
- **psrule analyze** - Azure best practices validation
- **bicep full workflow** - Complete Bicep validation pipeline

## 🧪 Testing & Validation Framework

The template includes a modern **Pester-based testing framework** for comprehensive DevContainer validation with multiple execution modes and CI/CD integration.

### **🚀 Quick Testing**

```powershell
# Quick validation (recommended for development)
.\tests\Test-DevContainer.ps1

# Full comprehensive testing
.\tests\Test-DevContainer.ps1 -Full

# CI/CD mode with XML output
.\tests\Test-DevContainer.ps1 -CI

# Watch mode (auto-run tests on file changes)
.\tests\Test-DevContainer.ps1 -Watch
```

### **🏷️ Test Categories**

The framework includes **38 comprehensive tests** organized with tags for selective execution:

- **`Syntax`** (4 tests) - PowerShell syntax validation for all core scripts
- **`Module`** (7 tests) - Module functionality and export validation
- **`Structure`** (19 tests) - File and directory structure verification
- **`Configuration`** (3 tests) - DevContainer and script configuration validation
- **`Integration`** (5 tests) - End-to-end consistency and cross-file validation

### **⚡ Advanced Testing Options**

```powershell
# Run specific test categories using Pester directly
Invoke-Pester -Path .\tests\DevContainer.Tests.ps1 -Tag "Syntax"
Invoke-Pester -Path .\tests\DevContainer.Tests.ps1 -Tag "Module", "Structure"

# Generate test results for CI/CD pipelines
Invoke-Pester -Path .\tests\DevContainer.Tests.ps1 -Output Detailed -TestResult "TestResults.xml"

# Use VS Code tasks for integrated testing
# Ctrl+Shift+P → "Tasks: Run Task" → "test devcontainer quick"
```

### **🔄 Backward Compatibility**

The testing framework automatically detects Pester availability and falls back to legacy validation when needed:

```powershell
# Works with or without Pester installed
.\tests\Validate-DevContainer.ps1

# Legacy parameter support maintained
.\tests\Validate-DevContainer.ps1 -SyntaxOnly
.\tests\Validate-DevContainer.ps1 -ModuleOnly -Quiet
```

### **📊 Test Results**

Current validation status: **✅ 36 tests passing, 2 skipped**

Example output:
```
📊 CI Test Summary:
  Total: 38
  Passed: 36
  Failed: 0
  Skipped: 2
  NotRun: 0
  Exit Code: 0 (All Tests Passed)
  Output: C:\git\repos\devcontainer-template\tests\TestResults.xml
```

### **🤖 CI/CD Integration**

Perfect for automated pipelines with structured output and exit codes:

```yaml
# GitHub Actions example
- name: Validate DevContainer
  shell: pwsh
  run: .\tests\Test-DevContainer.ps1 -CI
  
- name: Upload Test Results
  uses: actions/upload-artifact@v3
  with:
    name: test-results
    path: tests/TestResults.xml
```

## 🛠️ Command Line Tools & Aliases

All tools are available via command line with helpful aliases:

```bash
# Terraform basics
tf, tfi, tfp, tfa, tfd, tfv, tff, tfs, tfo

# Bicep basics (if installed)
bc, bcb, bcd, bcl, bcf, bcv

# Documentation and security
tfdocs     # Generate documentation
tfscan     # Run tfsec security scan
checkov    # Run Checkov scan
terrascan  # Run Terrascan scan
tfcost     # Run infracost

# Version management
tfswitch   # Switch Terraform versions

# Azure CLI shortcuts
azl, azs, azset, azdg, azds
```

```
.devcontainer/
├── devcontainer.json          # Main devcontainer configuration
├── Dockerfile                 # Container image definition
├── devcontainer.env.example   # Environment variables template
└── scripts/
    ├── initialize             # Pre-build initialization script
    └── postStart.sh          # Post-container-start setup
```

## ⚙️ Customization Guide

### 1. **Cloud Provider Selection**

Edit the `Dockerfile` to install only the CLI tools you need:

```dockerfile
# Customize these based on your cloud provider
ARG INSTALL_AZURE_CLI="true"   # Set to "false" if not using Azure
ARG INSTALL_AWS_CLI="false"    # Set to "true" if using AWS
ARG INSTALL_GCLOUD_CLI="false" # Set to "true" if using GCP
```

### 2. **Environment Variables**

In `devcontainer.env`, configure only the variables relevant to your project:

**For Azure projects:**
```bash
ARM_TENANT_ID=your-tenant-id
ARM_CLIENT_ID=your-client-id
ARM_SUBSCRIPTION_ID=your-subscription-id
TF_VAR_LOCATION=eastus
```

**For AWS projects:**
```bash
AWS_ACCESS_KEY_ID=your-access-key
AWS_SECRET_ACCESS_KEY=your-secret-key
AWS_DEFAULT_REGION=us-east-1
TF_VAR_REGION=us-east-1
```

**For GCP projects:**
```bash
GOOGLE_CREDENTIALS=path-to-service-account.json
GOOGLE_PROJECT=your-project-id
GOOGLE_REGION=us-central1
TF_VAR_PROJECT=your-project-id
```

### 3. **VS Code Extensions**

Modify the `extensions` array in `devcontainer.json` based on your needs:

```json
"extensions": [
    "hashicorp.terraform",              // Always needed for Terraform
    "ms-vscode.azurecli",              // Remove if not using Azure
    "amazonwebservices.aws-toolkit-vscode", // Add for AWS
    "googlecloudtools.cloudcode",       // Add for GCP
    "ms-python.python",                // Keep if using Python scripts
    "github.copilot",                  // Optional: AI assistance
    "terraform-linters.tflint-vscode"  // Recommended: Terraform linting
]
```

### 4. **Terraform Backend Configuration**

Configure your backend in `devcontainer.env`. The template supports automated backend creation and validation:

**Azure Storage Backend (Recommended):**
```bash
# Backend infrastructure settings
TF_BACKEND_RESOURCE_GROUP=terraform-state-rg
TF_BACKEND_STORAGE_ACCOUNT=mystorageaccount
TF_BACKEND_CONTAINER=tfstate
TF_BACKEND_KEY=myproject.terraform.tfstate
TF_BACKEND_LOCATION=eastus
TF_BACKEND_SUBSCRIPTION_ID=your-backend-subscription-id

# Optional: Different subscription for backend
# Useful for centralized state management or security isolation
```

**Backend Management Options:**

1. **Automated Creation** - Use PowerShell scripts to create backend infrastructure:
   ```powershell
   # Creates storage account, resource group, and container if they don't exist
   Initialize-DevContainer -CreateBackend -CreateBackendResourceGroup
   ```

2. **Cross-Subscription Backend** - Store state in a different subscription:
   ```powershell
   # Backend in different subscription from project resources
   Initialize-DevContainer -BackendSubscriptionId "backend-subscription-id" -CreateBackend
   ```

3. **Validation** - Check existing backend before proceeding:
   ```powershell
   # Validates backend exists and is accessible
   Initialize-DevContainer -ValidateBackend
   ```

4. **Manual Configuration** - Manually specify all backend details:
   ```powershell
   Initialize-DevContainer -BackendResourceGroup "custom-rg" `
                          -BackendStorageAccount "customstorage" `
                          -BackendContainer "customcontainer"
   ```

**Alternative Backend Types:**

**S3 Backend (AWS):**
```bash
TF_VAR_BACKEND_BUCKET=my-terraform-state-bucket
TF_VAR_BACKEND_KEY=myproject/terraform.tfstate
TF_VAR_BACKEND_REGION=us-east-1
```

**GCS Backend (Google Cloud):**
```bash
TF_VAR_BACKEND_BUCKET=my-terraform-state-bucket
TF_VAR_BACKEND_PREFIX=myproject
```

### 5. **Project-Specific Variables**

Add your project's Terraform variables with the `TF_VAR_` prefix:

```bash
TF_VAR_ENVIRONMENT=dev
TF_VAR_PROJECT_NAME=myproject
TF_VAR_RESOURCE_PREFIX=myorg
TF_VAR_TAGS='{"Environment":"dev","Project":"myproject"}'
```

## 🛠️ Usage in Different Project Types

### **Multi-Environment Projects**
Create separate environment files:
```bash
.devcontainer/
├── devcontainer.env.dev
├── devcontainer.env.staging
└── devcontainer.env.prod
```

### **Microservices/Multi-Module Projects**
Customize the container name and mount paths:
```json
{
    "name": "myproject-infrastructure",
    "workspaceFolder": "/workspaces/infrastructure"
}
```

### **Team Projects**
Include team-specific settings in `devcontainer.json`:
```json
{
    "remoteEnv": {
        "TF_VAR_TEAM_NAME": "${containerEnv:TF_VAR_TEAM_NAME}",
        "TF_VAR_COST_CENTER": "${containerEnv:TF_VAR_COST_CENTER}"
    }
}
```

## 🏗️ Working with Azure Bicep

The devcontainer includes full support for Azure Bicep, Microsoft's domain-specific language (DSL) for deploying Azure resources.

### **Getting Started with Bicep**

1. **Create a new Bicep file** (see `examples/main.bicep`)
2. **Use parameters file** for configurations (see `examples/main.bicepparam`)
3. **Configure Bicep settings** with `bicepconfig.json`

### **Example Workflow**

```bash
# Format and lint your Bicep file
bicep format main.bicep
bicep lint main.bicep

# Build to ARM template
bicep build main.bicep

# Validate deployment
az deployment group validate \
  --resource-group my-rg \
  --template-file main.bicep \
  --parameters @main.bicepparam

# Deploy to Azure
az deployment group create \
  --resource-group my-rg \
  --template-file main.bicep \
  --parameters @main.bicepparam \
  --name my-deployment
```

### **Converting ARM to Bicep**

Convert existing ARM templates to Bicep format:

```bash
# Decompile ARM template to Bicep
bicep decompile arm-template.json

# This creates arm-template.bicep with equivalent Bicep syntax
```

### **Bicep Best Practices**

The devcontainer includes PSRule for Azure to validate your Bicep against Azure best practices:

```bash
# Run PSRule validation
pwsh -c "Invoke-PSRule -Format File -InputPath . -Module PSRule.Rules.Azure"

# Or use the VS Code task: "psrule analyze"
```

### **Available Examples by Category**

The template includes organized examples in the `examples/` directory:

#### 🚀 [Getting Started](./examples/getting-started/)
- **AVM-DEVELOPMENT-GUIDE.md** - Comprehensive Azure Verified Modules development guide
- **README.md** - Quick start guide for new users

#### 🏗️ [Terraform](./examples/terraform/)
- **main.tf** - Complete Terraform configuration with Azure resources
- **variables.tf** - Input variables with validation and descriptions
- **outputs.tf** - Output values for resource references
- **terraform.tfvars.example** - Example variable values template
- **.tflint.hcl** - Terraform linting configuration

#### 🔧 [Bicep](./examples/bicep/)
- **main.bicep** - Azure Bicep template with best practices
- **main.bicepparam** - Parameters file for the main template
- **bicepconfig.json** - Bicep tool configuration and linting rules

#### 📦 [ARM Templates](./examples/arm/)
- **arm-template.json** - Azure Resource Manager template example

#### 💻 [PowerShell](./examples/powershell/)
- **Backend-Management-Examples.ps1** - Advanced backend management scenarios
- **PowerShell-Usage.ps1** - DevContainer Accelerator module usage examples

#### ⚙️ [Configuration](./examples/configuration/)
- **ps-rule.yaml** - Azure PowerShell Rule configuration for governance
- **.pre-commit-config.yaml** - Pre-commit hooks for code quality and security

## 🏗️ Azure Verified Modules (AVM) Development

This devcontainer is optimized for developing Azure Verified Modules for both Terraform and Bicep.

### **AVM Terraform Requirements**
- ✅ Terraform ≥1.9 (devcontainer includes 1.10+)
- ✅ AzureRM provider ≥3.116.0 support
- ✅ Terraform-docs for automatic README generation
- ✅ Pre-commit hooks for validation
- ✅ Security scanning with TFSec and Checkov

### **AVM Bicep Requirements**
- ✅ Bicep CLI with latest features
- ✅ PSRule for Azure best practices validation
- ✅ Azure CLI integration for deployments
- ✅ PowerShell for advanced scripting

### **AVM Development Workflow**

1. **Initialize AVM Module**
   ```bash
   # For Terraform AVM
   terraform init
   terraform validate
   terraform fmt
   
   # For Bicep AVM
   bicep build main.bicep
   bicep lint main.bicep
   ```

2. **Run AVM Tests**
   ```bash
   # Run comprehensive validation
   task_name="terraform full workflow"  # or "bicep full workflow"
   ```

3. **Generate Documentation**
   ```bash
   # Terraform modules
   terraform-docs markdown table --output-file README.md .
   
   # Bicep modules documentation is auto-generated
   ```

4. **Security and Best Practices**
   ```bash
   # Run PSRule for Azure best practices
   pwsh -c "Invoke-PSRule -Format File -InputPath . -Module PSRule.Rules.Azure"
   
   # Run security scans
   checkov --framework terraform .
   tfsec .
   ```

### **AVM Compliance Features**

- **Telemetry Support**: Built-in support for AVM telemetry requirements
- **Modular Design**: Structure supports AVM module patterns
- **Testing Framework**: Integrated tools for unit and integration testing
- **Documentation**: Automated README generation following AVM standards
- **Version Management**: Proper semantic versioning and release workflows

## 🔧 Advanced Customization

### **Adding Custom Tools**
Extend the `Dockerfile` to install additional tools:
```dockerfile
# Install kubectl for Kubernetes management
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
    && install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Install Helm
RUN curl https://get.helm.sh/helm-v3.12.0-linux-amd64.tar.gz | tar -xzO linux-amd64/helm > /usr/local/bin/helm \
    && chmod +x /usr/local/bin/helm
```

### **Custom Validation Scripts**
Add validation scripts to the `postStart.sh`:
```bash
# Validate Terraform configuration
if [ -f "main.tf" ]; then
    echo "🔍 Validating Terraform configuration..."
    terraform validate && echo "✅ Terraform validation passed"
fi

# Check for security issues
if command -v checkov &> /dev/null; then
    echo "🔒 Running security scan..."
    checkov -f main.tf --quiet
fi
```

## ✅ Quality Assurance & Standards

This DevContainer template maintains high quality standards through comprehensive testing and validation:

### **🧪 Automated Testing**
- **38 comprehensive tests** covering syntax, functionality, structure, and integration
- **Multiple test execution modes** for different development workflows
- **CI/CD ready** with structured output and exit codes
- **Backward compatibility** with automatic Pester detection and fallback

### **🔒 Security & Compliance**
- **Multiple security scanners** (Checkov, tfsec, Terrascan)
- **Azure best practices validation** with PSRule
- **Secrets management** with environment variable templates
- **Security-hardened backend configuration** with versioning and soft delete

### **📚 Documentation Standards**
- **Comprehensive examples** for all supported scenarios
- **Step-by-step guides** for common workflows
- **Automated documentation generation** with terraform-docs
- **Migration guides** and troubleshooting documentation

### **🔄 Continuous Improvement**
- **Regular validation** of all components and examples
- **Version management** for all included tools
- **Community feedback integration** and issue resolution
- **Breaking change documentation** and migration paths

## 📖 Documentation

The DevContainer Template includes comprehensive documentation through multiple channels:

### **📚 Hugo Documentation Site**

A modern, searchable documentation website built with Hugo and the Docsy theme:

```powershell
# Setup and start the documentation site locally
.\docs\Setup-Hugo.ps1 -Install -Serve

# Open http://localhost:1313 in your browser
```

**Features:**
- **🎨 Professional Design** - Clean, responsive interface optimized for technical documentation
- **🔍 Full-Text Search** - Find information quickly across all documentation
- **📱 Mobile Responsive** - Perfect reading experience on any device
- **🚀 Fast Loading** - Optimized static site generation
- **🔄 Auto-Deploy** - Automatically published to GitHub Pages on updates

**Content Sections:**
- **[Getting Started](/docs/getting-started/)** - Step-by-step setup guides
- **[Configuration](/docs/configuration/)** - Customization and configuration options
- **[Testing Framework](/docs/testing/)** - Comprehensive testing documentation
- **[Examples](/docs/examples/)** - Practical use cases and implementations
- **[PowerShell Module](/docs/powershell/)** - Complete API reference and automation guides
- **[Troubleshooting](/docs/troubleshooting/)** - Common issues and solutions

### **📋 Quick Reference Documentation**

Essential documentation files included in the repository:

| File | Description |
|------|-------------|
| **[README.md](./README.md)** | Main project overview and quick start |
| **[tests/README.md](./tests/README.md)** | Testing framework usage and examples |
| **[examples/README.md](./examples/README.md)** | Practical examples and use cases |
| **[docs/hugo/README.md](./docs/hugo/README.md)** | Hugo site development and deployment |

### **🚀 GitHub Pages Deployment**

The documentation site is automatically deployed to GitHub Pages:

1. **Automatic Deployment** - Updates on every push to `main` branch
2. **Custom Domain Support** - Configure your own domain if desired
3. **HTTPS Enabled** - Secure access by default
4. **CDN Powered** - Fast global content delivery

**Access the live documentation at:** `https://haflidif.github.io/devcontainer-template`

### **🛠️ Local Development**

Contribute to documentation or preview changes locally:

```powershell
# Quick setup for documentation development
cd docs
.\Setup-Hugo.ps1 -Install    # Install Hugo and dependencies
.\Setup-Hugo.ps1 -Serve      # Start development server

# Advanced development commands
.\Setup-Hugo.ps1 -Clean      # Clean build artifacts
.\Setup-Hugo.ps1 -Update     # Update dependencies
.\Setup-Hugo.ps1 -Build      # Build for production
```

**Development Features:**
- **Live Reload** - See changes instantly as you edit
- **Draft Support** - Preview unpublished content
- **Multi-language Ready** - Support for internationalization
- **Theme Customization** - Easy styling and layout modifications

## 📝 Best Practices

1. **🧪 Regular Testing**: Use `.\tests\Test-DevContainer.ps1` frequently during development
2. **🏷️ Selective Testing**: Use Pester tags for faster feedback (`-Tag "Syntax"` for quick checks)
3. **🔄 Watch Mode**: Enable `.\tests\Test-DevContainer.ps1 -Watch` for continuous validation
4. **📦 Version Pinning**: Always specify tool versions in your environment variables
5. **🔐 Secrets Management**: Never commit actual secrets; use the `.env.example` pattern
6. **👥 Team Standards**: Document your team's specific customizations in the README
7. **🛡️ Security First**: Use managed identities or service principals instead of access keys when possible
8. **📏 Resource Naming**: Use consistent naming conventions via environment variables
9. **🤖 CI/CD Integration**: Use `.\tests\Test-DevContainer.ps1 -CI` for automated pipelines
10. **📊 Monitor Quality**: Review test results and maintain high pass rates

## 🚀 Getting Started with Your Project

1. Copy this template to your Terraform project
2. Customize the configuration based on your cloud provider and requirements
3. Set up your environment variables
4. Run validation tests: `.\tests\Test-DevContainer.ps1`
5. Open in VS Code and start developing!

The devcontainer will automatically:
- Install the correct versions of Terraform and related tools
- Configure your development environment with security scanning
- Set up useful aliases and shortcuts
- Validate your Terraform configuration with comprehensive testing
- Provide automated backend management and cross-subscription support

**Ready to build infrastructure? Start with confidence!** 🚀🌍

Run `.\tests\Test-DevContainer.ps1 -Watch` for continuous validation during development.

## 🔐 Azure Authentication

This devcontainer supports multiple Azure authentication methods to work seamlessly both locally and in CI/CD environments.

### **Authentication Methods (in order of precedence)**

1. **Service Principal with Client Secret** (CI/CD)
2. **Azure CLI Authentication** (Local development)
3. **Managed Identity** (Azure-hosted environments)

### **Local Development Authentication**

For local development, the **recommended approach** is Azure CLI authentication:

```bash
# Login to Azure (opens browser for interactive auth)
az login

# Select your subscription
az account set --subscription "your-subscription-id"

# Verify authentication
az account show
```

**Configuration for local development:**
```bash
# In devcontainer.env - no client secret needed
ARM_TENANT_ID=your-tenant-id
ARM_CLIENT_ID=your-user-or-spn-client-id  # Optional: only if you want specific identity
ARM_SUBSCRIPTION_ID=your-subscription-id
# ARM_CLIENT_SECRET=  # Leave empty for Azure CLI auth
```

### **CI/CD Authentication**

For automated deployments, use Service Principal authentication:

```bash
# In devcontainer.env or CI/CD environment
ARM_TENANT_ID=your-tenant-id
ARM_CLIENT_ID=your-service-principal-client-id
ARM_CLIENT_SECRET=your-service-principal-secret
ARM_SUBSCRIPTION_ID=your-subscription-id
```

### **Azure-hosted Authentication**

When running on Azure services (Azure DevOps agents, Azure Container Instances, etc.), Managed Identity is automatically used:

```bash
# In devcontainer.env - minimal config needed
ARM_TENANT_ID=your-tenant-id
ARM_SUBSCRIPTION_ID=your-subscription-id
# ARM_CLIENT_ID=  # Optional: for user-assigned managed identity
```

### **Authentication Verification**

Test your authentication setup:

```bash
# Test Azure CLI authentication
az account show

# Test Terraform authentication
terraform init
terraform plan

# Test with Azure provider
terraform console
# Type: data.azurerm_client_config.current
```

### **Troubleshooting Authentication**

Common issues and solutions:

**"Failed to authenticate" errors:**
```bash
# Clear Azure CLI cache and re-login
az account clear
az login

# Verify subscription access
az account list
```

**"Invalid client secret" in CI/CD:**
- Verify `ARM_CLIENT_SECRET` is correctly set
- Check service principal permissions
- Ensure service principal hasn't expired

**"Managed Identity not found":**
- Verify managed identity is assigned to the Azure resource
- Check if user-assigned identity needs `ARM_CLIENT_ID`

## 🔧 Troubleshooting Common Issues

### **Testing Framework Issues**

**"Pester module not found":**
```powershell
# Install Pester 5.0+ for enhanced testing experience
Install-Module Pester -Force -Scope CurrentUser -MinimumVersion 5.0

# Or run tests in legacy mode (automatically detected)
.\tests\Validate-DevContainer.ps1
```

**"Permission denied" when running tests:**
```powershell
# Set execution policy for current user
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Or run with bypass
PowerShell -ExecutionPolicy Bypass -File .\tests\Test-DevContainer.ps1
```

**Tests failing unexpectedly:**
```powershell
# Run with detailed output to see specific failures
.\tests\Test-DevContainer.ps1 -Full

# Run specific test categories to isolate issues
Invoke-Pester -Path .\tests\DevContainer.Tests.ps1 -Tag "Syntax" -Output Detailed

# Check for file permission issues
Get-ChildItem .\tests\ | ForEach-Object { $_.FullName + " - " + $_.IsReadOnly }
```

### **DevContainer Issues**

**"Container fails to build":**
```bash
# Check Docker is running and has sufficient resources
docker system info

# Clear Docker cache and rebuild
docker system prune -a
```

**"Extensions not loading":**
```bash
# Check VS Code version compatibility
code --version

# Reset VS Code extension host
# Command Palette → "Developer: Reload Window"
```

## 🔧 PowerShell Automation

Choose between a standalone script for quick setup or a full PowerShell module for advanced features:

### **Standalone Script (Quick Setup)**

For immediate use without installation, use the standalone script:

```powershell
# Basic setup with prompts
.\Initialize-DevContainer.ps1 -TenantId "your-tenant-id" `
                             -SubscriptionId "your-subscription-id" `
                             -ProjectName "my-project"

# Full configuration with backend creation
.\Initialize-DevContainer.ps1 -TenantId "your-tenant-id" `
                             -SubscriptionId "your-subscription-id" `
                             -ProjectName "my-project" `
                             -ProjectType "terraform" `
                             -Environment "dev" `
                             -Location "eastus" `
                             -CreateBackend `
                             -CreateBackendResourceGroup `
                             -IncludeExamples

# Interactive mode with guided prompts
.\Initialize-DevContainer.ps1 -Interactive

# Cross-subscription backend
.\Initialize-DevContainer.ps1 -TenantId "your-tenant-id" `
                             -SubscriptionId "project-subscription" `
                             -ProjectName "my-project" `
                             -BackendSubscriptionId "backend-subscription" `
                             -CreateBackend

# Validate existing backend
.\Initialize-DevContainer.ps1 -TenantId "your-tenant-id" `
                             -SubscriptionId "your-subscription-id" `
                             -ProjectName "my-project" `
                             -ValidateBackend
```

#### **Standalone Script Features**

- ✅ **Interactive Mode** - Guided prompts for all configuration options
- ✅ **Backend Management** - Create, validate, or check existing Terraform backends
- ✅ **Cross-Subscription Support** - Backend in different subscription from project
- ✅ **Azure Storage Integration** - Automatic storage account and container creation
- ✅ **Security Configuration** - Enables blob versioning and soft delete
- ✅ **Smart Defaults** - Generates appropriate names from project information
- ✅ **Comprehensive Validation** - Tests Azure authentication and permissions

## 💻 DevContainer Accelerator PowerShell Module

The template includes a powerful PowerShell automation module with 12+ functions for streamlined Infrastructure as Code workflows.

### 🚀 Key Features

#### Backend Management
- **New-TerraformBackend** - Automated Terraform backend creation and configuration
- **Initialize-TerraformBackend** - Backend initialization and validation
- **Test-TerraformBackend** - Backend connectivity and health checks

#### Azure Integration
- **Test-AzureAuthentication** - Verify Azure CLI and PowerShell authentication
- **Get-AzureContext** - Retrieve current Azure subscription context
- **Set-AzureServicePrincipal** - Configure service principal authentication

#### Utility Functions
- **Test-IsGuid** - GUID validation for Azure resource IDs
- **Write-ColorOutput** - Enhanced console output with colors
- **Get-RandomString** - Secure random string generation
- **ConvertTo-SecureString** - Secure string conversion utilities

#### Workflow Automation
- **Deploy-BicepTemplate** - Automated Bicep template deployment
- **Invoke-AzureBestPracticesValidation** - PSRule integration for governance

### 📋 Quick Usage Examples

```powershell
# Import the module
Import-Module ./DevContainerAccelerator

# Create a Terraform backend
New-TerraformBackend -StorageAccountName "mytfstate" -ResourceGroupName "tfstate-rg"

# Validate Azure authentication
Test-AzureAuthentication

# Check if a string is a valid GUID
Test-IsGuid -InputString "123e4567-e89b-12d3-a456-426614174000"

# Colorized output
Write-ColorOutput -Message "Success!" -Color "Green"
```

For comprehensive examples, see [PowerShell Examples](./examples/powershell/).

### **CI/CD Automation**

The PowerShell module is designed to work seamlessly in CI/CD environments, providing commands for:

- **Automated backend creation and validation**
- **Terraform initialization and plan execution**
- **Azure deployment and validation**
- **Security scanning and compliance checks**

## ⚡ PowerShell Accelerator Module

For the fastest setup experience, use our PowerShell accelerator module that automates the entire DevContainer initialization process:

### **One-Line Installation**

```powershell
# Install the DevContainer Accelerator module
.\Install-DevContainerAccelerator.ps1

# Or for all users (requires admin)
.\Install-DevContainerAccelerator.ps1 -InstallScope AllUsers
```

### **Quick Project Creation**

```powershell
# Create a brand new Infrastructure as Code project
New-IaCProject -ProjectName "my-infrastructure" `
               -TenantId "12345678-1234-1234-1234-123456789012" `
               -SubscriptionId "87654321-4321-4321-4321-210987654321" `
               -ProjectType "terraform" `
               -Environment "dev" `
               -Location "eastus" `
               -InitializeGit `
               -IncludeExamples
```

### **Initialize DevContainer in Existing Project**

```powershell
# Add DevContainer to existing project
Initialize-DevContainer -TenantId "your-tenant-id" `
                       -SubscriptionId "your-subscription-id" `
                       -ProjectName "my-existing-project" `
                       -ProjectType "both" `
                       -IncludeExamples
```

### **Available Commands**

- **`Test-DevContainerPrerequisites`** - Check if Docker, VS Code, etc. are installed
- **`New-IaCProject`** - Create a new project with DevContainer setup
- **`Initialize-DevContainer`** - Add DevContainer to existing project
- **`Update-DevContainerTemplate`** - Update DevContainer files to latest version
- **`New-TerraformBackend`** - Create or validate Terraform backend infrastructure
- **`Get-AzureSubscriptions`** - List all available Azure subscriptions
- **`Invoke-GuidedBackendSetup`** - Interactive wizard for backend configuration
- **`Test-BackendConnectivity`** - Comprehensive backend connectivity testing

### **Advanced Backend Management**

The module provides sophisticated Terraform backend management supporting both current and alternative subscriptions:

```powershell
# Create backend in current subscription
New-TerraformBackend -StorageAccountName "mytfstate" `
                    -ResourceGroupName "terraform-rg" `
                    -ContainerName "tfstate" `
                    -Location "eastus" `
                    -CreateResourceGroup

# Create backend in different subscription
New-TerraformBackend -StorageAccountName "mytfstate" `
                    -ResourceGroupName "terraform-rg" `
                    -ContainerName "tfstate" `
                    -Location "eastus" `
                    -SubscriptionId "different-subscription-id" `
                    -CreateResourceGroup

# Validate existing backend
New-TerraformBackend -StorageAccountName "mytfstate" `
                    -ResourceGroupName "terraform-rg" `
                    -ContainerName "tfstate" `
                    -ValidateOnly

# Interactive guided setup
Invoke-GuidedBackendSetup -ProjectName "my-project" -Location "eastus"

# Test backend connectivity and permissions
Test-BackendConnectivity -StorageAccountName "mytfstate" `
                        -ResourceGroupName "terraform-rg" `
                        -ContainerName "tfstate"
```

### **Cross-Subscription Backend Support**

The accelerator fully supports scenarios where your Terraform backend is in a different subscription from your project resources:

```powershell
# Initialize DevContainer with cross-subscription backend
Initialize-DevContainer -ProjectName "webapp" `
                       -TenantId "your-tenant-id" `
                       -SubscriptionId "project-subscription-id" `
                       -BackendSubscriptionId "backend-subscription-id" `
                       -CreateBackend `
                       -CreateBackendResourceGroup

# List available subscriptions to choose from
Get-AzureSubscriptions
```

### **Backend Management Features**

- ✅ **Automatic Discovery** - Checks if backend already exists before creating
- ✅ **Cross-Subscription** - Supports backend in different subscription than project
- ✅ **Security Hardened** - Enables blob versioning, soft delete, HTTPS-only
- ✅ **Permission Testing** - Validates read/write access to storage
- ✅ **Smart Naming** - Generates Azure-compliant names from project names
- ✅ **Interactive Wizards** - Guided setup for complex scenarios
- ✅ **Comprehensive Validation** - Tests authentication, access, and permissions

### **Interactive Setup**

The module validates all inputs and provides helpful error messages:

```powershell
# Check prerequisites first
Test-DevContainerPrerequisites

# Get help for any command
Get-Help Initialize-DevContainer -Full

# Use aliases for quick access
init-devcontainer -TenantId "..." -SubscriptionId "..." -ProjectName "..."
new-iac -ProjectName "my-project" -TenantId "..." -SubscriptionId "..."
```

### **What the Accelerator Does**

1. ✅ **Validates** Azure GUIDs and prerequisites
2. ✅ **Creates** `.devcontainer` directory and copies all necessary files
3. ✅ **Generates** customized `devcontainer.env` with your Azure settings
4. ✅ **Configures** Terraform backend with smart naming conventions
5. ✅ **Adds** example files for your chosen project type (Terraform/Bicep)
6. ✅ **Initializes** Git repository with proper `.gitignore` (optional)
7. ✅ **Provides** clear next steps and usage instructions

### **Smart Defaults**

The accelerator uses intelligent defaults:
- **Storage Account Name**: Generated from project name (alphanumeric only)
- **Backend Configuration**: Follows Azure naming conventions
- **Resource Groups**: Named with consistent patterns (`projectname-tfstate-rg`)
- **State Files**: Named with environment suffix (`project.env.terraform.tfstate`)

## 📁 Repository Structure

```
devcontainer-template/
├── .devcontainer/              # DevContainer configuration
│   ├── devcontainer.json       # VS Code DevContainer settings
│   ├── Dockerfile              # Container image definition
│   ├── devcontainer.env.example # Environment variables template
│   └── scripts/                # Setup and utility scripts
│       ├── common-debian.sh    # Common Debian package setup
│       ├── terraform-tools.sh  # Terraform toolchain installation
│       ├── bicep-tools.sh      # Bicep toolchain installation
│       ├── initialize          # Pre-build initialization script
│       └── postStart.sh        # Post-container-start setup
├── DevContainerAccelerator/    # PowerShell automation module
│   ├── DevContainerAccelerator.psd1  # Module manifest
│   └── DevContainerAccelerator.psm1  # Module implementation (12+ functions)
├── docs/                       # Comprehensive documentation
│   ├── VALIDATION_SUMMARY.md   # Validation and testing results
│   ├── ISSUES_FIXED_SUMMARY.md # Summary of fixes and improvements
│   ├── RESTRUCTURING_SUMMARY.md # Project reorganization details
│   ├── FINAL_VERIFICATION_REPORT.md # Final validation report
│   └── FINAL_STRUCTURE_VERIFICATION.md # Structure compliance verification
├── examples/                   # Organized examples by category
│   ├── getting-started/        # Quick start guides and documentation
│   │   ├── AVM-DEVELOPMENT-GUIDE.md # Azure Verified Modules guide
│   │   └── README.md           # Getting started instructions
│   ├── terraform/              # Terraform configuration examples
│   │   ├── main.tf             # Main Terraform configuration
│   │   ├── variables.tf        # Variable definitions
│   │   ├── outputs.tf          # Output definitions
│   │   ├── terraform.tfvars.example # Example variables
│   │   ├── .tflint.hcl         # TFLint configuration
│   │   └── README.md           # Terraform examples documentation
│   ├── bicep/                  # Azure Bicep templates
│   │   ├── main.bicep          # Main Bicep template
│   │   ├── main.bicepparam     # Parameters file
│   │   ├── bicepconfig.json    # Bicep configuration
│   │   └── README.md           # Bicep examples documentation
│   ├── arm/                    # Azure Resource Manager templates
│   │   ├── arm-template.json   # ARM template example
│   │   └── README.md           # ARM template documentation
│   ├── powershell/             # PowerShell automation examples
│   │   ├── Backend-Management-Examples.ps1 # Backend management scenarios
│   │   ├── PowerShell-Usage.ps1 # Module usage examples
│   │   └── README.md           # PowerShell examples documentation
│   ├── configuration/          # Tool configurations
│   │   ├── ps-rule.yaml        # PSRule for Azure configuration
│   │   ├── .pre-commit-config.yaml # Pre-commit hooks
│   │   └── README.md           # Configuration documentation
│   └── README.md               # Examples directory overview
├── tests/                      # Modern testing framework
│   ├── DevContainer.Tests.ps1  # Pester-based test suite (38 tests)
│   ├── Test-DevContainer.ps1   # Quick test runner with multiple modes
│   ├── Validate-DevContainer.ps1 # Enhanced wrapper with Pester integration
│   ├── MIGRATION_SUMMARY.md    # Testing framework migration details
│   └── README.md               # Comprehensive testing documentation
├── docs/                       # Documentation and Hugo site
│   ├── hugo/                   # Hugo static site generator
│   │   ├── content/            # Documentation content (Markdown)
│   │   ├── hugo.toml           # Hugo configuration
│   │   ├── go.mod              # Hugo modules (Docsy theme)
│   │   ├── package.json        # Node.js dependencies
│   │   └── README.md           # Hugo setup documentation
│   ├── Setup-Hugo.ps1          # Hugo development setup script
│   └── *.md                    # Additional documentation files
├── .github/workflows/          # GitHub Actions workflows
│   └── hugo.yml                # Hugo site deployment to GitHub Pages
├── Initialize-DevContainer.ps1 # Main initialization script
├── Install-DevContainerAccelerator.ps1 # Module installer
└── README.md                   # This file
```
