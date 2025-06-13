# Bicep Examples

This directory contains Azure Bicep templates and configuration examples for Azure resource deployment.

## 📋 Contents

### Template Files
- **main.bicep** - Main Bicep template with example Azure resources
- **main.bicepparam** - Parameters file for the main template
- **bicepconfig.json** - Bicep tool configuration and settings

## 🚀 Quick Start

### 1. Configure Parameters
```bash
# Edit the parameters file with your values
# Update main.bicepparam with your subscription and resource details
```

### 2. Build and Validate
```bash
# Build the template
bicep build main.bicep

# Validate the template
az deployment group validate \
  --resource-group myResourceGroup \
  --template-file main.bicep \
  --parameters main.bicepparam
```

### 3. Deploy Template
```bash
# Deploy to Azure
az deployment group create \
  --resource-group myResourceGroup \
  --template-file main.bicep \
  --parameters main.bicepparam \
  --name myDeployment
```

## 📁 File Descriptions

### main.bicep
Example template containing:
- Resource Group (optional)
- Virtual Network with subnets
- Storage Account with security configurations
- Key Vault with access policies
- Log Analytics Workspace
- Application Insights

### main.bicepparam
Parameters file providing:
- Environment-specific values
- Resource naming configurations
- Feature toggles
- Security settings

### bicepconfig.json
Bicep tool configuration including:
- Linting rules and severity levels
- Module path configurations
- Analyzer settings
- Output formatting preferences

## 🔧 Template Features

### Security Best Practices
- ✅ Storage account with encryption at rest
- ✅ Key Vault with RBAC access policies
- ✅ Network security groups
- ✅ Diagnostic settings for monitoring

### Modular Design
- ✅ Parameterized resource configurations
- ✅ Conditional resource deployment
- ✅ Consistent naming conventions
- ✅ Resource tagging strategy

### Azure Integration
- ✅ User-assigned managed identity support
- ✅ Azure Monitor integration
- ✅ Resource dependency management
- ✅ Output values for downstream consumption

## 🧪 Testing and Validation

### Pre-deployment Checks
```bash
# Lint the template
bicep lint main.bicep

# Build to ARM template
bicep build main.bicep

# Validate with what-if
az deployment group what-if \
  --resource-group myResourceGroup \
  --template-file main.bicep \
  --parameters main.bicepparam
```

### Post-deployment Verification
```bash
# Check deployment status
az deployment group show \
  --resource-group myResourceGroup \
  --name myDeployment

# List deployed resources
az resource list \
  --resource-group myResourceGroup \
  --output table
```

## 📊 Monitoring and Troubleshooting

### View Deployment History
```bash
# List deployments
az deployment group list \
  --resource-group myResourceGroup \
  --output table

# Get deployment logs
az deployment operation group list \
  --resource-group myResourceGroup \
  --name myDeployment
```

### Debug Template Issues
```bash
# Validate template syntax
bicep build main.bicep --stdout

# Check parameter file
az deployment group validate \
  --resource-group myResourceGroup \
  --template-file main.bicep \
  --parameters main.bicepparam \
  --debug
```

## 🔄 Configuration Management

### Environment-Specific Deployment
```bash
# Development environment
az deployment group create \
  --resource-group dev-rg \
  --template-file main.bicep \
  --parameters main.bicepparam \
  --parameters environment=dev

# Production environment
az deployment group create \
  --resource-group prod-rg \
  --template-file main.bicep \
  --parameters main.bicepparam \
  --parameters environment=prod
```

### CI/CD Integration
The templates are designed for pipeline deployment:
- Parameter files for different environments
- Validation steps included
- Output handling for downstream jobs
- Error handling and rollback support

## 🔧 DevContainer Integration

### Bicep Tools Available
The DevContainer includes:
- ✅ Azure CLI with Bicep extension
- ✅ VS Code Bicep extension
- ✅ Bicep linting and IntelliSense
- ✅ Template validation tools

### PowerShell Integration
```powershell
# Use with DevContainer Accelerator
Import-Module ../DevContainerAccelerator

# Deploy with PowerShell wrapper
Deploy-BicepTemplate -TemplatePath "main.bicep" -ParametersPath "main.bicepparam"
```

## 🔗 Related Examples

- [PowerShell Automation](../powershell/)
- [Configuration Files](../configuration/)
- [ARM Templates](../arm/) (for comparison)
- [Getting Started Guide](../getting-started/)

## 📚 Additional Resources

- [Azure Bicep Documentation](https://docs.microsoft.com/azure/azure-resource-manager/bicep/)
- [Bicep Best Practices](https://docs.microsoft.com/azure/azure-resource-manager/bicep/best-practices)
- [Azure Resource Manager Templates](https://docs.microsoft.com/azure/azure-resource-manager/templates/)
- [Azure CLI Bicep Commands](https://docs.microsoft.com/cli/azure/bicep)
