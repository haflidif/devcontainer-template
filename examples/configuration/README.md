# Configuration Examples

This directory contains configuration files for various tools and services used in the DevContainer environment.

## 📋 Contents

### Configuration Files
- **ps-rule.yaml** - Azure PowerShell Rule (PSRule) configuration for Azure best practices validation
- **.pre-commit-config.yaml** - Pre-commit hooks configuration for code quality and security

## 🚀 Quick Start

### 1. PSRule Configuration
```bash
# Run PSRule analysis on Bicep/ARM templates
pwsh -c "Invoke-PSRule -Format File -InputPath . -Module PSRule.Rules.Azure"

# Generate baseline
pwsh -c "Export-PSRuleBaseline -Format File -InputPath . -Module PSRule.Rules.Azure"
```

### 2. Pre-commit Hooks
```bash
# Install pre-commit
pip install pre-commit

# Install hooks
pre-commit install

# Run hooks manually
pre-commit run --all-files
```

## 📁 File Descriptions

### ps-rule.yaml
PowerShell Rule configuration for Azure governance:

#### Features
- ✅ Azure Well-Architected Framework validation
- ✅ Security best practices enforcement
- ✅ Cost optimization checks
- ✅ Performance and reliability validations

#### Rule Categories
- **Security**: NSG rules, encryption, access controls
- **Reliability**: Availability zones, backup configurations
- **Performance**: Resource sizing, caching strategies
- **Cost**: Resource optimization, monitoring setup
- **Operations**: Tagging, naming conventions, diagnostics

#### Supported Resources
- Virtual Networks and Subnets
- Storage Accounts
- Virtual Machines
- App Services
- Key Vaults
- Databases (SQL, Cosmos DB)
- And many more Azure services

### .pre-commit-config.yaml
Pre-commit hooks for code quality and security:

#### Included Hooks
- **General Code Quality**
  - Trailing whitespace removal
  - End-of-file fixing
  - JSON/YAML validation
  - Large file prevention

- **Terraform-Specific**
  - `terraform fmt` - Code formatting
  - `terraform validate` - Configuration validation
  - `tflint` - Linting and security checks
  - `checkov` - Security and compliance scanning

- **Security Scanning**
  - Secret detection
  - Credential scanning
  - Sensitive data prevention

- **Documentation**
  - Markdown linting
  - Link validation
  - Spelling checks

## 🔧 Usage Examples

### PSRule Analysis

#### Basic Analysis
```powershell
# Analyze all templates in current directory
Invoke-PSRule -Format File -InputPath . -Module PSRule.Rules.Azure

# Analyze specific file
Invoke-PSRule -Format File -InputPath main.bicep -Module PSRule.Rules.Azure

# Output to JSON
Invoke-PSRule -Format File -InputPath . -Module PSRule.Rules.Azure -OutputFormat Json
```

#### Advanced Analysis
```powershell
# Use custom configuration
Invoke-PSRule -Format File -InputPath . -Module PSRule.Rules.Azure -Option ps-rule.yaml

# Generate HTML report
Invoke-PSRule -Format File -InputPath . -Module PSRule.Rules.Azure -OutputFormat Html -OutputPath report.html

# Filter by severity
Invoke-PSRule -Format File -InputPath . -Module PSRule.Rules.Azure | Where-Object Outcome -eq "Fail"
```

### Pre-commit Integration

#### Setup in New Repository
```bash
# Copy configuration
cp .pre-commit-config.yaml /path/to/new/repo/

# Install in new repository
cd /path/to/new/repo
pre-commit install

# Test configuration
pre-commit run --all-files
```

#### CI/CD Integration
```bash
# In CI pipeline
pip install pre-commit
pre-commit run --all-files
```

## 🧪 Testing and Validation

### PSRule Testing
```powershell
# Test configuration file
Test-PSRuleOption -Path ps-rule.yaml

# Validate rules
Get-PSRule -Module PSRule.Rules.Azure | Select-Object RuleName, Synopsis

# Check rule documentation
Get-PSRuleHelp -Name "Azure.VM.UseManagedDisks" -Module PSRule.Rules.Azure
```

### Pre-commit Testing
```bash
# Test specific hook
pre-commit run terraform-fmt --all-files

# Test with verbose output
pre-commit run --all-files --verbose

# Update hook versions
pre-commit autoupdate
```

## 🔄 Customization

### PSRule Customization

#### Custom Rules Directory
```yaml
# ps-rule.yaml
rule:
  includeLocal: true
  include:
    - 'Custom.*'
```

#### Baseline Configuration
```yaml
# ps-rule.yaml
baseline:
  group:
    security:
      rule:
        - 'Azure.Storage.SecureTransfer'
        - 'Azure.KeyVault.AccessPolicy'
```

### Pre-commit Customization

#### Additional Hooks
```yaml
# .pre-commit-config.yaml
repos:
  - repo: local
    hooks:
      - id: custom-script
        name: Custom validation
        entry: ./scripts/custom-validation.sh
        language: script
        files: '\.tf$'
```

#### Hook Configuration
```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/antonbabenko/pre-commit-terraform
    rev: v1.77.0
    hooks:
      - id: terraform_fmt
        args:
          - --args=-recursive
          - --args=-diff
```

## 🔗 Integration with DevContainer

### VSCode Tasks
The configuration files integrate with VSCode tasks:
- PSRule analysis via `psrule analyze` task
- Pre-commit via `pre-commit run` task
- Automated validation in development workflow

### PowerShell Module Integration
```powershell
# Use with DevContainer Template modules
Import-Module ../modules/CommonModule.psm1
Import-Module ../modules/AzureModule.psm1

# Run PSRule analysis through module
Invoke-AzureBestPracticesValidation -Path . -OutputFormat Json

# Integrate with backend creation
New-TerraformBackend -StorageAccountName "mytfstate" -ValidateWithPSRule
```

## 📊 Reporting and Monitoring

### PSRule Reporting
```powershell
# Generate summary report
Invoke-PSRule -Format File -InputPath . -Module PSRule.Rules.Azure | 
  Group-Object Outcome | 
  Select-Object Name, Count

# Export to CSV
Invoke-PSRule -Format File -InputPath . -Module PSRule.Rules.Azure | 
  Export-Csv -Path "psrule-results.csv" -NoTypeInformation
```

### Pre-commit Monitoring
```bash
# Check hook status
pre-commit --version

# View hook configuration
pre-commit sample-config

# Manual hook execution with timing
time pre-commit run --all-files
```

## 🔗 Related Examples

- [Terraform Examples](../terraform/) - Infrastructure templates
- [Bicep Examples](../bicep/) - Azure templates
- [PowerShell Examples](../powershell/) - Automation scripts
- [Getting Started Guide](../getting-started/) - Setup instructions

## 📚 Additional Resources

- [PSRule Documentation](https://microsoft.github.io/PSRule/)
- [PSRule for Azure](https://azure.github.io/PSRule.Rules.Azure/)
- [Pre-commit Documentation](https://pre-commit.com/)
- [Azure Well-Architected Framework](https://docs.microsoft.com/azure/architecture/framework/)
