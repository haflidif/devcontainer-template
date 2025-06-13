#!/usr/bin/env bash

# Generic DevContainer Post-Start Script
# This script runs after the container starts

echo "🚀 Starting DevContainer post-start setup..."

# Check if environment file exists
if [ ! -f ".devcontainer/devcontainer.env" ]; then
    echo "⚠️  DevContainer environment file not found!"
    echo "📋 Copying example file..."
    cp .devcontainer/devcontainer.env.example .devcontainer/devcontainer.env
    echo "✅ Please edit .devcontainer/devcontainer.env with your specific values and rebuild the container"
    exit 0
fi

echo "✅ Environment file found"

# Install Bicep tools
if [ "${INSTALL_BICEP}" = "true" ]; then
    echo "🔧 Installing Bicep tools..."
    
    # Run the Bicep tools installation script
    if [ -f ".devcontainer/scripts/bicep-tools.sh" ]; then
        sudo .devcontainer/scripts/bicep-tools.sh "${BICEP_VERSION}"
    else
        echo "⚠️  Bicep tools installation script not found. Installing Bicep manually..."
        
        # Install Azure CLI if not present
        if ! command -v az &> /dev/null; then
            echo "📦 Installing Azure CLI..."
            curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
        fi
        
        # Install Bicep CLI
        if ! command -v bicep &> /dev/null; then
            echo "📦 Installing Bicep CLI..."
            az bicep install
        fi
    fi
fi
# Install Terraform tools
if [ ! -z "${TERRAFORM_VERSION}" ]; then
    echo "🔧 Installing Terraform tools..."
    
    # Run the Terraform tools installation script
    if [ -f ".devcontainer/scripts/terraform-tools.sh" ]; then
        sudo .devcontainer/scripts/terraform-tools.sh "${TERRAFORM_VERSION}" "${TFLINT_VERSION}" "${TERRAFORM_DOCS_VERSION}" "${TERRAGRUNT_VERSION}" "${CHECKOV_VERSION}"
    else
        echo "⚠️  Terraform tools installation script not found. Installing Terraform manually..."
        
        # Install Terraform
        if ! command -v terraform &> /dev/null; then
            echo "📦 Installing Terraform ${TERRAFORM_VERSION}..."
            wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
            echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
            sudo apt update && sudo apt install terraform
        fi
        
        # Install TFLint
        if ! command -v tflint &> /dev/null && [ ! -z "${TFLINT_VERSION}" ]; then
            echo "📦 Installing TFLint ${TFLINT_VERSION}..."
            curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash
        fi
    fi
fi

# Set up Git configuration if not already set
if [ -z "$(git config --global user.name)" ]; then
    echo "⚙️  Setting up Git configuration..."
    read -p "Enter your Git username: " git_username
    read -p "Enter your Git email: " git_email
    git config --global user.name "$git_username"
    git config --global user.email "$git_email"
fi

# Initialize Terraform if terraform files exist
if [ -f "main.tf" ] || [ -f "*.tf" ]; then
    echo "🏗️  Terraform files detected"
    
    # Check if backend is configured
    if [ ! -z "${TF_BACKEND_STORAGE_ACCOUNT}" ]; then
        echo "🔧 Backend configuration detected"
        echo "💡 You can run 'terraform init' to initialize the backend"
    fi
fi

# Create useful aliases
echo "🔧 Setting up aliases..."
cat >> ~/.bashrc << EOF

# Terraform aliases
alias tf='terraform'
alias tfi='terraform init'
alias tfp='terraform plan'
alias tfa='terraform apply'
alias tfd='terraform destroy'
alias tfv='terraform validate'
alias tff='terraform fmt'
alias tfs='terraform show'
alias tfo='terraform output'

# Terraform documentation
alias tfdocs='terraform-docs markdown table --output-file README.md .'

# Security scanning
alias tfscan='tfsec .'
alias checkov='checkov -d . --framework terraform'
alias terrascan='terrascan scan -t terraform -d .'

# Cost estimation
alias tfcost='infracost breakdown --path .'

# Linting
alias tflint='tflint --init && tflint'

# Bicep aliases (if Bicep is installed)
if command -v bicep &> /dev/null; then
    alias bc='bicep'
    alias bcb='bicep build'
    alias bcd='bicep decompile'
    alias bcl='bicep lint'
    alias bcf='bicep format'
    alias bcv='bicep version'
fi

# Azure CLI aliases (if Azure CLI is installed)
if command -v az &> /dev/null; then
    alias azl='az login'
    alias azs='az account show'
    alias azset='az account set --subscription'
    alias azdg='az deployment group'
    alias azds='az deployment sub'
fi

# AWS CLI aliases (if AWS CLI is installed)
if command -v aws &> /dev/null; then
    alias awsl='aws sts get-caller-identity'
fi

EOF

echo "✨ DevContainer setup complete!"
echo ""
echo "🎯 Quick start commands:"
echo "  Terraform:"
echo "    • terraform init      - Initialize Terraform"
echo "    • terraform plan      - Plan your infrastructure"
echo "    • terraform apply     - Apply changes"
echo "    • terraform validate  - Validate configuration"
echo "    • terraform fmt       - Format code"
echo "    • terraform-docs .    - Generate documentation"
echo "    • tflint             - Lint Terraform code"
echo "    • tfsec .            - Security scan"
echo "    • infracost breakdown - Cost estimation"
echo ""
echo "  Bicep:"
echo "    • bicep build main.bicep           - Compile Bicep to ARM"
echo "    • bicep decompile template.json    - Convert ARM to Bicep"
echo "    • bicep lint main.bicep            - Lint Bicep files"
echo "    • bicep format main.bicep          - Format Bicep files"
echo "    • az deployment group validate     - Validate deployment"
echo "    • az deployment group create       - Deploy resources"
echo ""
echo "📚 Your environment variables are loaded from .devcontainer/devcontainer.env"
echo "🔧 Useful aliases:"
echo "  Terraform: tf, tfi, tfp, tfa, tfd, tfv, tff, tfdocs, tfscan, tfcost"
echo "  Bicep: bc, bcb, bcd, bcl, bcf, bcv"
echo "  Azure: azl, azs, azset, azdg, azds"
