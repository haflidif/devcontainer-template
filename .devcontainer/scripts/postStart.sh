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

# Install/Verify Bicep tools based on environment variables
if [ "${INSTALL_BICEP}" = "true" ]; then
    echo "🔧 Verifying Bicep tools installation..."
    
    if command -v az &> /dev/null; then
        echo "✅ Azure CLI is available: $(az version --output tsv --query '"azure-cli"')"
    else
        echo "❌ Azure CLI not found - this should have been installed during container build"
    fi
    
    if command -v bicep &> /dev/null; then
        echo "✅ Bicep CLI is available: $(bicep --version)"
    else
        echo "📦 Installing Bicep CLI..."
        # Check if bicep-tools.sh script exists
        if [ -f ".devcontainer/scripts/bicep-tools.sh" ]; then
            echo "🚀 Running Bicep tools installation script..."
            sudo bash .devcontainer/scripts/bicep-tools.sh "${BICEP_VERSION}"
        else
            echo "⚠️  Bicep tools script not found, installing Bicep CLI only..."
            # Fallback: install just Bicep CLI
            ARCH="amd64"
            if [ "${BICEP_VERSION}" = "latest" ]; then
                BICEP_VERSION=$(curl -s https://api.github.com/repos/Azure/bicep/releases/latest | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')
            fi
            curl -Lo bicep "https://github.com/Azure/bicep/releases/download/v${BICEP_VERSION}/bicep-linux-${ARCH}"
            chmod +x ./bicep
            sudo mv ./bicep /usr/local/bin/bicep
        fi
        
        # Verify Bicep installation
        if command -v bicep &> /dev/null; then
            echo "✅ Bicep CLI is available: $(bicep --version)"
        else
            echo "❌ Bicep CLI installation failed"
        fi
    fi
fi

# Install/Verify Terraform tools based on environment variables
if [ ! -z "${TERRAFORM_VERSION}" ]; then
    echo "🔧 Checking Terraform tools installation..."
    
    # Check if Terraform is already installed
    if command -v terraform &> /dev/null; then
        echo "✅ Terraform is available: $(terraform version -json | jq -r '.terraform_version' 2>/dev/null || terraform version)"
    else
        echo "📦 Installing Terraform tools..."
        # Check if terraform-tools.sh script exists
        if [ -f ".devcontainer/scripts/terraform-tools.sh" ]; then
            echo "🚀 Running Terraform tools installation script..."
            sudo bash .devcontainer/scripts/terraform-tools.sh "${TERRAFORM_VERSION}" "${TFLINT_VERSION}" "${TERRAFORM_DOCS_VERSION}" "${TERRAGRUNT_VERSION}" "${CHECKOV_VERSION}"
        else
            echo "⚠️  Terraform tools script not found, installing Terraform only..."
            # Fallback: install just Terraform
            ARCH="amd64"
            if [ "${TERRAFORM_VERSION}" = "latest" ]; then
                TERRAFORM_VERSION=$(curl -s https://api.github.com/repos/hashicorp/terraform/releases/latest | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')
            fi
            wget -O /tmp/terraform.zip "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_${ARCH}.zip"
            cd /tmp && unzip terraform.zip
            sudo mv terraform /usr/local/bin/
            rm /tmp/terraform.zip
        fi
    fi
    
    # Verify tools after installation attempt
    if command -v terraform &> /dev/null; then
        echo "✅ Terraform is available: $(terraform version -json | jq -r '.terraform_version' 2>/dev/null || terraform version)"
    else
        echo "❌ Terraform installation failed"
    fi
    
    if command -v tflint &> /dev/null; then
        echo "✅ TFLint is available: $(tflint --version)"
    else
        echo "⚠️  TFLint not found"
    fi
    
    if command -v terraform-docs &> /dev/null; then
        echo "✅ terraform-docs is available: $(terraform-docs --version)"
    else
        echo "⚠️  terraform-docs not found"
    fi
    
    if command -v terragrunt &> /dev/null; then
        echo "✅ Terragrunt is available: $(terragrunt --version)"
    else
        echo "⚠️  Terragrunt not found"
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

# Configure Terraform backend and set up environment
if [ -f "main.tf" ] || find . -name "*.tf" -type f | head -1 > /dev/null 2>&1; then
    echo "🏗️  Terraform files detected"
    
    # Check if backend is configured and create backend configuration
    if [ ! -z "${TF_BACKEND_STORAGE_ACCOUNT}" ]; then
        echo "🔧 Backend configuration detected, setting up Terraform backend..."
        
        # Create backend configuration file
        cat > backend.tfvars << EOF
resource_group_name  = "${TF_BACKEND_RESOURCE_GROUP}"
storage_account_name = "${TF_BACKEND_STORAGE_ACCOUNT}"
container_name       = "${TF_BACKEND_CONTAINER}"
key                  = "terraform.tfstate"
EOF
        
        # Add environment variable to shell profiles (multiple shells support)
        echo "" >> ~/.bashrc
        echo "# Terraform backend configuration" >> ~/.bashrc
        echo 'export TF_CLI_ARGS_init="-backend-config=backend.tfvars"' >> ~/.bashrc
        
        # Also add to ~/.profile for broader shell support
        echo "" >> ~/.profile
        echo "# Terraform backend configuration" >> ~/.profile
        echo 'export TF_CLI_ARGS_init="-backend-config=backend.tfvars"' >> ~/.profile
        
        # Set for current session and any processes started by this script
        export TF_CLI_ARGS_init="-backend-config=backend.tfvars"
        
        echo "✅ Backend configuration file created: backend.tfvars"
        echo "✅ TF_CLI_ARGS_init environment variable added to shell profiles"
        echo "💡 Please restart your terminal or run 'source ~/.bashrc' to load the environment variable"
        echo "💡 Then 'terraform init' will automatically use the backend configuration"
    fi
fi

# Create useful aliases
echo "🔧 Setting up aliases..."

# Check if aliases already exist to avoid duplicates
if ! grep -q "# Terraform aliases" ~/.bashrc; then
    cat >> ~/.bashrc << 'EOF'

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

    echo "✅ Aliases added to ~/.bashrc"
else
    echo "✅ Aliases already configured in ~/.bashrc"
fi

echo "✨ DevContainer setup complete!"
echo ""
echo "🎯 Quick start commands:"
echo "  Terraform:"
echo "    • terraform init      - Initialize Terraform (with auto backend config)"
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
echo "🔧 Useful aliases (restart terminal or run 'source ~/.bashrc' to load):"
echo "  Terraform: tf, tfi, tfp, tfa, tfd, tfv, tff, tfdocs, tfscan, tfcost"
echo "  Bicep: bc, bcb, bcd, bcl, bcf, bcv"
echo "  Azure: azl, azs, azset, azdg, azds"
echo ""
echo "💡 To load environment variables and aliases in current session:"
echo "  source ~/.bashrc"
