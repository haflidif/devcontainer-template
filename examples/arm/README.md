# ARM Template Examples

This directory contains Azure Resource Manager (ARM) template examples for Azure infrastructure deployment.

## 📋 Contents

### Template Files
- **arm-template.json** - Example ARM template with common Azure resources

## 🚀 Quick Start

### 1. Validate Template
```bash
# Validate template syntax
az deployment group validate \
  --resource-group myResourceGroup \
  --template-file arm-template.json \
  --parameters @parameters.json
```

### 2. Deploy Template
```bash
# Deploy to Azure
az deployment group create \
  --resource-group myResourceGroup \
  --template-file arm-template.json \
  --parameters @parameters.json \
  --name myDeployment
```

### 3. Monitor Deployment
```bash
# Check deployment status
az deployment group show \
  --resource-group myResourceGroup \
  --name myDeployment \
  --query properties.provisioningState
```

## 📁 Template Description

### arm-template.json
Comprehensive ARM template including:

#### Resource Types
- **Resource Group** (optional, can be deployment target)
- **Virtual Network** with multiple subnets
- **Network Security Groups** with security rules
- **Storage Account** with blob services
- **Key Vault** with access policies
- **Log Analytics Workspace** for monitoring
- **Application Insights** for application monitoring

#### Template Features
- ✅ **Parameterized Configuration** - Flexible resource settings
- ✅ **Variable Calculations** - Dynamic value generation
- ✅ **Resource Dependencies** - Proper deployment ordering
- ✅ **Output Values** - Resource references for integration
- ✅ **Conditional Deployment** - Feature toggles
- ✅ **Resource Tagging** - Consistent metadata application

#### Security Best Practices
- ✅ **Storage Encryption** - Encryption at rest enabled
- ✅ **Key Vault Integration** - Secure secret management
- ✅ **Network Security** - NSG rules and network isolation
- ✅ **Access Control** - RBAC and managed identities
- ✅ **Audit Logging** - Diagnostic settings configured

## 🔧 Template Parameters

### Required Parameters
```json
{
  "projectName": {
    "type": "string",
    "description": "Name of the project (used in resource naming)"
  },
  "environment": {
    "type": "string",
    "allowedValues": ["dev", "test", "staging", "prod"],
    "description": "Environment designation"
  },
  "location": {
    "type": "string",
    "defaultValue": "[resourceGroup().location]",
    "description": "Azure region for resources"
  }
}
```

### Optional Parameters
```json
{
  "enableMonitoring": {
    "type": "bool",
    "defaultValue": true,
    "description": "Deploy monitoring resources"
  },
  "storageAccountType": {
    "type": "string",
    "defaultValue": "Standard_LRS",
    "allowedValues": ["Standard_LRS", "Standard_GRS", "Premium_LRS"],
    "description": "Storage account replication type"
  },
  "keyVaultSku": {
    "type": "string",
    "defaultValue": "standard",
    "allowedValues": ["standard", "premium"],
    "description": "Key Vault pricing tier"
  }
}
```

## 🧪 Testing and Validation

### Pre-deployment Testing
```bash
# Test template syntax
az deployment group validate \
  --resource-group test-rg \
  --template-file arm-template.json \
  --parameters projectName=testproject environment=dev

# Preview changes with what-if
az deployment group what-if \
  --resource-group test-rg \
  --template-file arm-template.json \
  --parameters projectName=testproject environment=dev
```

### Template Analysis
```bash
# Use ARM Template Toolkit (ARM-TTK)
Import-Module /path/to/arm-ttk/arm-ttk.psd1
Test-AzTemplate -TemplatePath arm-template.json

# Use PSRule for Azure governance
pwsh -c "Invoke-PSRule -Format File -InputPath arm-template.json -Module PSRule.Rules.Azure"
```

## 📊 Deployment Patterns

### Single Resource Group Deployment
```bash
# Create resource group and deploy
az group create --name myproject-dev-rg --location eastus
az deployment group create \
  --resource-group myproject-dev-rg \
  --template-file arm-template.json \
  --parameters projectName=myproject environment=dev
```

### Subscription-Level Deployment
```bash
# Deploy at subscription scope (creates resource group)
az deployment sub create \
  --location eastus \
  --template-file arm-template.json \
  --parameters projectName=myproject environment=dev location=eastus
```

### Multi-Environment Deployment
```bash
# Development
az deployment group create \
  --resource-group myproject-dev-rg \
  --template-file arm-template.json \
  --parameters @dev-parameters.json

# Production
az deployment group create \
  --resource-group myproject-prod-rg \
  --template-file arm-template.json \
  --parameters @prod-parameters.json
```

## 🔄 Parameter File Examples

### Development Environment (dev-parameters.json)
```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "projectName": { "value": "myproject" },
    "environment": { "value": "dev" },
    "enableMonitoring": { "value": true },
    "storageAccountType": { "value": "Standard_LRS" },
    "keyVaultSku": { "value": "standard" }
  }
}
```

### Production Environment (prod-parameters.json)
```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "projectName": { "value": "myproject" },
    "environment": { "value": "prod" },
    "enableMonitoring": { "value": true },
    "storageAccountType": { "value": "Standard_GRS" },
    "keyVaultSku": { "value": "premium" }
  }
}
```

## 🚀 CI/CD Integration

### Azure DevOps Pipeline
```yaml
steps:
- task: AzureResourceManagerTemplateDeployment@3
  inputs:
    deploymentScope: 'Resource Group'
    azureResourceManagerConnection: 'AzureServiceConnection'
    subscriptionId: '$(subscriptionId)'
    action: 'Create Or Update Resource Group'
    resourceGroupName: '$(resourceGroupName)'
    location: '$(location)'
    templateLocation: 'Linked artifact'
    csmFile: 'arm-template.json'
    csmParametersFile: '$(environment)-parameters.json'
    deploymentMode: 'Incremental'
```

### GitHub Actions
```yaml
- name: Deploy ARM Template
  uses: azure/arm-deploy@v1
  with:
    subscriptionId: ${{ secrets.AZURE_SUBSCRIPTION }}
    resourceGroupName: ${{ env.RESOURCE_GROUP }}
    template: arm-template.json
    parameters: |
      projectName=${{ env.PROJECT_NAME }}
      environment=${{ env.ENVIRONMENT }}
```

## 🔒 Security Considerations

### Access Control
- Template uses managed identities where possible
- Key Vault access policies restrict permissions
- Storage account access is controlled via RBAC
- Network security groups limit traffic

### Secrets Management
- Sensitive values stored in Key Vault
- Connection strings retrieved at runtime
- No hardcoded credentials in template
- Secure parameter handling in pipelines

## 🔗 Related Examples

- [Bicep Examples](../bicep/) - Modern ARM template alternative
- [PowerShell Examples](../powershell/) - Deployment automation
- [Configuration Files](../configuration/) - Validation and governance
- [Terraform Examples](../terraform/) - Multi-cloud alternative

## 📚 Additional Resources

- [ARM Template Documentation](https://docs.microsoft.com/azure/azure-resource-manager/templates/)
- [ARM Template Best Practices](https://docs.microsoft.com/azure/azure-resource-manager/templates/best-practices)
- [ARM Template Functions](https://docs.microsoft.com/azure/azure-resource-manager/templates/template-functions)
- [Azure Resource Manager Overview](https://docs.microsoft.com/azure/azure-resource-manager/management/overview)
