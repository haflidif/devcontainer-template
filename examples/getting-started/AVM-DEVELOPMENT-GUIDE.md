# Azure Verified Modules Development Guide

This devcontainer provides comprehensive support for developing Azure Verified Modules (AVM) for both Terraform and Bicep.

## AVM Terraform Development

### Required AVM Structure
```
terraform-azurerm-avm-res-<service>-<resource>/
├── .devcontainer/          # This devcontainer template
├── .github/                # CI/CD workflows
├── .vscode/                # VS Code settings
├── examples/               # Usage examples
├── modules/                # Submodules (if any)
├── tests/                  # Test files
├── main.tf                 # Main module
├── variables.tf            # Input variables
├── outputs.tf              # Module outputs
├── main.telemetry.tf       # AVM telemetry
├── terraform.tf            # Provider requirements
├── .terraform-docs.yml     # Documentation config
├── Makefile                # Build automation
└── README.md               # Auto-generated docs
```

### AVM Terraform Requirements Checklist
- [x] Terraform ≥1.9 (devcontainer: 1.10+)
- [x] AzureRM provider ≥3.116.0
- [x] AzAPI provider ≥1.13
- [x] ModTM telemetry module ~0.3
- [x] Terraform-docs for README generation
- [x] Pre-commit hooks for validation
- [x] Security scanning (TFSec, Checkov)
- [x] TFlint for code quality

### AVM Terraform Development Workflow
```bash
# 1. Initialize and validate
terraform init
terraform validate
terraform fmt --recursive

# 2. Generate documentation
terraform-docs markdown table --output-file README.md .

# 3. Run security scans
tfsec .
checkov --framework terraform .

# 4. Test with examples
cd examples/complete
terraform init
terraform plan

# 5. Run full validation pipeline
# Use VS Code task: "terraform full workflow"
```

## AVM Bicep Development

### Required AVM Structure
```
avm/res/<service>/<resource>/
├── tests/e2e/              # End-to-end tests
├── main.bicep              # Main module
├── main.json               # Compiled ARM template
├── version.json            # Module version
└── README.md               # Auto-generated docs
```

### AVM Bicep Requirements Checklist
- [x] Bicep CLI (latest)
- [x] PSRule for Azure validation
- [x] Azure CLI for deployments
- [x] PowerShell for PSRule
- [x] Telemetry support (enableTelemetry parameter)
- [x] Standard AVM patterns (RBAC, locks, etc.)

### AVM Bicep Development Workflow
```bash
# 1. Format and lint
bicep format main.bicep
bicep lint main.bicep

# 2. Build to ARM template
bicep build main.bicep

# 3. Validate with PSRule
pwsh -c "Invoke-PSRule -Format File -InputPath . -Module PSRule.Rules.Azure"

# 4. Test deployment
az deployment group validate \
  --resource-group test-rg \
  --template-file main.bicep \
  --parameters @test.bicepparam

# 5. Run full validation pipeline
# Use VS Code task: "bicep full workflow"
```

## AVM Common Patterns

### Telemetry Implementation
Both Terraform and Bicep AVM modules must include telemetry:

**Terraform:**
```hcl
# main.telemetry.tf
resource "modtm_telemetry" "telemetry" {
  count = var.enable_telemetry ? 1 : 0
  # ... telemetry configuration
}
```

**Bicep:**
```bicep
@description('Enable/Disable usage telemetry for module.')
param enableTelemetry bool = true

// Telemetry deployment
var telemetryId = '00000000-0000-0000-0000-000000000000'
resource telemetry 'Microsoft.Resources/deployments@2021-04-01' = if (enableTelemetry) {
  name: telemetryId
  properties: {
    mode: 'Incremental'
    template: {
      '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
      contentVersion: '1.0.0.0'
      resources: []
    }
  }
}
```

### Role Assignments Pattern
Both modules should support standardized role assignments:

**Terraform:**
```hcl
variable "role_assignments" {
  type = map(object({
    role_definition_id_or_name = string
    principal_id              = string
    description              = optional(string, null)
    # ... other properties
  }))
  default = {}
}
```

**Bicep:**
```bicep
@description('Array of role assignments to create.')
param roleAssignments array = []
```

### Resource Locks Pattern
**Terraform:**
```hcl
variable "lock" {
  type = object({
    kind = string
    name = optional(string, null)
  })
  default = null
}
```

**Bicep:**
```bicep
@description('The lock settings of the service.')
param lock object = {}
```

## VS Code Tasks for AVM Development

### Terraform AVM Tasks
- `terraform full workflow` - Complete validation pipeline
- `terraform-docs generate` - Generate module documentation
- `terraform security scan` - Run all security tools
- `tflint` - Code quality analysis

### Bicep AVM Tasks
- `bicep full workflow` - Complete validation pipeline
- `psrule analyze` - Azure best practices validation
- `azure deployment validate` - Test deployment
- `bicep build all` - Compile all Bicep files

## CI/CD Integration

The devcontainer pre-commit configuration includes all necessary hooks for AVM compliance:

```yaml
# .pre-commit-config.yaml (included in examples/)
repos:
  - repo: https://github.com/antonbabenko/pre-commit-terraform
    hooks:
      - id: terraform_fmt
      - id: terraform_validate
      - id: terraform_docs
      - id: terraform_tflint
      - id: terraform_tfsec
      - id: terraform_checkov

  - repo: local
    hooks:
      - id: bicep-build
      - id: bicep-lint
      - id: bicep-format
      - id: psrule-azure
```

## Getting Started with AVM Development

1. **Clone an existing AVM template** or create new structure
2. **Copy devcontainer configuration** from this template
3. **Configure environment variables** in `devcontainer.env`
4. **Install pre-commit hooks**: `pre-commit install`
5. **Start developing** using VS Code tasks and validation tools

This devcontainer provides everything needed for professional AVM development with automated quality assurance and compliance validation.
