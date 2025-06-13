#!/usr/bin/env bash
#-------------------------------------------------------------------------------------------------------------
# Terraform Tools Installation Script
# Installs Terraform, TFLint, terraform-docs, and other useful Terraform tools
#-------------------------------------------------------------------------------------------------------------

TERRAFORM_VERSION=${1:-"latest"}
TFLINT_VERSION=${2:-"latest"}
TERRAFORM_DOCS_VERSION=${3:-"latest"}
TERRAGRUNT_VERSION=${4:-"latest"}
CHECKOV_VERSION=${5:-"latest"}

set -e

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

# Determine architecture
architecture="$(uname -m)"
case ${architecture} in
    x86_64) architecture="amd64";;
    aarch64 | armv8*) architecture="arm64";;
    aarch32 | armv7* | armvhf*) architecture="arm";;
    i?86) architecture="386";;
    *) echo "(!) Architecture ${architecture} unsupported"; exit 1 ;;
esac

echo "🔧 Installing Terraform tools for ${architecture} architecture..."

# Function to get latest version from GitHub releases
get_latest_version() {
    local repo=$1
    local version=$(curl -s "https://api.github.com/repos/${repo}/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/' | sed 's/^v//')
    echo "$version"
}

# Install Terraform
install_terraform() {
    echo "📦 Installing Terraform ${TERRAFORM_VERSION}..."
    
    if [ "${TERRAFORM_VERSION}" = "latest" ]; then
        TERRAFORM_VERSION=$(get_latest_version "hashicorp/terraform")
    fi
    
    # Download and install Terraform
    wget -O terraform.zip "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_${architecture}.zip"
    unzip terraform.zip
    mv terraform /usr/local/bin/
    rm terraform.zip
    
    # Verify installation
    terraform version
    echo "✅ Terraform ${TERRAFORM_VERSION} installed successfully"
}

# Install TFLint
install_tflint() {
    if [ "${TFLINT_VERSION}" != "none" ] && [ ! -z "${TFLINT_VERSION}" ]; then
        echo "📦 Installing TFLint ${TFLINT_VERSION}..."
        
        if [ "${TFLINT_VERSION}" = "latest" ]; then
            TFLINT_VERSION=$(get_latest_version "terraform-linters/tflint")
        fi
        
        # Download and install TFLint
        wget -O tflint.zip "https://github.com/terraform-linters/tflint/releases/download/v${TFLINT_VERSION}/tflint_linux_${architecture}.zip"
        unzip tflint.zip
        mv tflint /usr/local/bin/
        rm tflint.zip
        
        # Verify installation
        tflint --version
        echo "✅ TFLint ${TFLINT_VERSION} installed successfully"
    fi
}

# Install terraform-docs
install_terraform_docs() {
    if [ "${TERRAFORM_DOCS_VERSION}" != "none" ] && [ ! -z "${TERRAFORM_DOCS_VERSION}" ]; then
        echo "📦 Installing terraform-docs ${TERRAFORM_DOCS_VERSION}..."
        
        if [ "${TERRAFORM_DOCS_VERSION}" = "latest" ]; then
            TERRAFORM_DOCS_VERSION=$(get_latest_version "terraform-docs/terraform-docs")
        fi
        
        # Download and install terraform-docs
        wget -O terraform-docs.tar.gz "https://github.com/terraform-docs/terraform-docs/releases/download/v${TERRAFORM_DOCS_VERSION}/terraform-docs-v${TERRAFORM_DOCS_VERSION}-linux-${architecture}.tar.gz"
        tar -xzf terraform-docs.tar.gz
        mv terraform-docs /usr/local/bin/
        rm terraform-docs.tar.gz
        
        # Verify installation
        terraform-docs --version
        echo "✅ terraform-docs ${TERRAFORM_DOCS_VERSION} installed successfully"
    fi
}

# Install Terragrunt
install_terragrunt() {
    if [ "${TERRAGRUNT_VERSION}" != "none" ] && [ ! -z "${TERRAGRUNT_VERSION}" ]; then
        echo "📦 Installing Terragrunt ${TERRAGRUNT_VERSION}..."
        
        if [ "${TERRAGRUNT_VERSION}" = "latest" ]; then
            TERRAGRUNT_VERSION=$(get_latest_version "gruntwork-io/terragrunt")
        fi
        
        # Download and install Terragrunt
        wget -O terragrunt "https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/terragrunt_linux_${architecture}"
        chmod +x terragrunt
        mv terragrunt /usr/local/bin/
        
        # Verify installation
        terragrunt --version
        echo "✅ Terragrunt ${TERRAGRUNT_VERSION} installed successfully"
    fi
}

# Install Infracost
install_infracost() {
    echo "📦 Installing Infracost..."
    
    # Download and install Infracost
    curl -fsSL https://raw.githubusercontent.com/infracost/infracost/master/scripts/install.sh | sh
    
    # Move to system path
    mv /root/.local/bin/infracost /usr/local/bin/ 2>/dev/null || mv ~/.local/bin/infracost /usr/local/bin/ || true
    
    # Verify installation
    if command -v infracost &> /dev/null; then
        infracost --version
        echo "✅ Infracost installed successfully"
    else
        echo "⚠️  Infracost installation may have failed"
    fi
}

# Install Terrascan
install_terrascan() {
    echo "📦 Installing Terrascan..."
    
    TERRASCAN_VERSION=$(get_latest_version "tenable/terrascan")
    
    # Download and install Terrascan
    wget -O terrascan.tar.gz "https://github.com/tenable/terrascan/releases/download/v${TERRASCAN_VERSION}/terrascan_${TERRASCAN_VERSION}_Linux_x86_64.tar.gz"
    tar -xzf terrascan.tar.gz terrascan
    mv terrascan /usr/local/bin/
    rm terrascan.tar.gz
    
    # Verify installation
    terrascan version
    echo "✅ Terrascan ${TERRASCAN_VERSION} installed successfully"
}

# Install tfsec
install_tfsec() {
    echo "📦 Installing tfsec..."
    
    TFSEC_VERSION=$(get_latest_version "aquasecurity/tfsec")
    
    # Download and install tfsec
    wget -O tfsec "https://github.com/aquasecurity/tfsec/releases/download/v${TFSEC_VERSION}/tfsec-linux-${architecture}"
    chmod +x tfsec
    mv tfsec /usr/local/bin/
    
    # Verify installation
    tfsec --version
    echo "✅ tfsec ${TFSEC_VERSION} installed successfully"
}

# Install TFSwitcher (for managing multiple Terraform versions)
install_tfswitch() {
    echo "📦 Installing TFSwitcher..."
    
    curl -L https://raw.githubusercontent.com/warrensbox/terraform-switcher/release/install.sh | bash
    
    # Verify installation
    if command -v tfswitch &> /dev/null; then
        tfswitch --version
        echo "✅ TFSwitcher installed successfully"
    else
        echo "⚠️  TFSwitcher installation may have failed"
    fi
}

# Create TFLint configuration
create_tflint_config() {
    if command -v tflint &> /dev/null; then
        echo "📝 Creating TFLint configuration..."
        
        cat > /tmp/.tflint.hcl << 'EOF'
plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

plugin "aws" {
  enabled = true
  version = "0.24.1"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

plugin "azurerm" {
  enabled = true
  version = "0.25.1"
  source  = "github.com/terraform-linters/tflint-ruleset-azurerm"
}

plugin "google" {
  enabled = true
  version = "0.26.0"
  source  = "github.com/terraform-linters/tflint-ruleset-google"
}

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
EOF
        
        echo "✅ TFLint configuration created at /tmp/.tflint.hcl"
        echo "💡 Copy this to your project root as .tflint.hcl to use it"
    fi
}

# Main installation
echo "🚀 Starting Terraform tools installation..."

# Install core tools
install_terraform
install_tflint
install_terraform_docs
install_terragrunt

# Install security and cost tools
install_infracost
install_terrascan
install_tfsec

# Install utility tools
install_tfswitch

# Create configurations
create_tflint_config

echo ""
echo "🎉 All Terraform tools installed successfully!"
echo ""
echo "📋 Installed tools:"
echo "  • Terraform ${TERRAFORM_VERSION}"
echo "  • TFLint ${TFLINT_VERSION}"
echo "  • terraform-docs ${TERRAFORM_DOCS_VERSION}"
echo "  • Terragrunt ${TERRAGRUNT_VERSION}"
echo "  • Infracost (cost estimation)"
echo "  • Terrascan (security scanning)"
echo "  • tfsec (security scanning)"
echo "  • TFSwitcher (version management)"
echo ""
echo "🔧 Useful commands:"
echo "  • terraform-docs markdown . > README.md"
echo "  • tflint --init  # Initialize TFLint plugins"
echo "  • tfsec .        # Run security scan"
echo "  • infracost breakdown --path ."
echo "  • tfswitch       # Switch Terraform versions"
echo ""
