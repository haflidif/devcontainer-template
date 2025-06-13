# Example .tflint.hcl configuration file
# Copy this to your project root to enable TFLint with cloud provider rules

plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

# Enable AWS rules (uncomment if using AWS)
# plugin "aws" {
#   enabled = true
#   version = "0.24.1"
#   source  = "github.com/terraform-linters/tflint-ruleset-aws"
# }

# Enable Azure rules (uncomment if using Azure)
# plugin "azurerm" {
#   enabled = true
#   version = "0.25.1"
#   source  = "github.com/terraform-linters/tflint-ruleset-azurerm"
# }

# Enable Google Cloud rules (uncomment if using GCP)
# plugin "google" {
#   enabled = true
#   version = "0.26.0"
#   source  = "github.com/terraform-linters/tflint-ruleset-google"
# }

# Terraform best practices rules
rule "terraform_deprecated_interpolation" {
  enabled = true
}

rule "terraform_unused_declarations" {
  enabled = true
}

rule "terraform_comment_syntax" {
  enabled = true
}

rule "terraform_documented_outputs" {
  enabled = true
}

rule "terraform_documented_variables" {
  enabled = true
}

rule "terraform_typed_variables" {
  enabled = true
}

rule "terraform_module_pinned_source" {
  enabled = true
}

rule "terraform_naming_convention" {
  enabled = true
  format  = "snake_case"
}

rule "terraform_standard_module_structure" {
  enabled = true
}
