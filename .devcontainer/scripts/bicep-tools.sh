#!/usr/bin/env bash
#-------------------------------------------------------------------------------------------------------------
# Bicep Tools Installation Script
# Installs Azure Bicep CLI and related tools for Azure Infrastructure as Code
#-------------------------------------------------------------------------------------------------------------

BICEP_VERSION=${1:-"latest"}
INSTALL_AZURE_CLI=${2:-"true"}

set -e

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

# Determine architecture
architecture="$(uname -m)"
case ${architecture} in
    x86_64) architecture="x64";;
    aarch64 | armv8*) architecture="arm64";;
    *) echo "(!) Architecture ${architecture} unsupported"; exit 1 ;;
esac

echo "🔧 Installing Bicep tools for ${architecture} architecture..."

# Function to get latest version from GitHub releases
get_latest_version() {
    local repo=$1
    local version=$(curl -s "https://api.github.com/repos/${repo}/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/' | sed 's/^v//')
    echo "$version"
}

# Install Azure CLI (required for Bicep)
install_azure_cli() {
    if [ "${INSTALL_AZURE_CLI}" = "true" ] && ! command -v az &> /dev/null; then
        echo "📦 Installing Azure CLI..."
        
        # Get Microsoft signing key
        curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null
        
        # Add Azure CLI repository
        echo "deb [arch=$(dpkg --print-architecture)] https://packages.microsoft.com/repos/azure-cli/ $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/azure-cli.list
        
        # Update and install
        apt-get update
        apt-get install -y azure-cli
        
        echo "✅ Azure CLI installed successfully"
    fi
}

# Install Bicep CLI
install_bicep() {
    echo "📦 Installing Bicep CLI ${BICEP_VERSION}..."
    
    if [ "${BICEP_VERSION}" = "latest" ]; then
        BICEP_VERSION=$(get_latest_version "Azure/bicep")
    fi
    
    # Download and install Bicep CLI
    curl -Lo bicep "https://github.com/Azure/bicep/releases/download/v${BICEP_VERSION}/bicep-linux-${architecture}"
    chmod +x ./bicep
    mv ./bicep /usr/local/bin/bicep
    
    # Verify installation
    bicep --version
    echo "✅ Bicep CLI ${BICEP_VERSION} installed successfully"
}

# Install Azure Resource Manager Tools for VS Code (via npm)
install_arm_tools() {
    echo "📦 Installing ARM/Bicep language tools..."
    
    # Install Node.js if not present
    if ! command -v node &> /dev/null; then
        echo "Installing Node.js..."
        curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
        apt-get install -y nodejs
    fi
    
    # Install ARM/Bicep language server
    npm install -g @azure/arm-template-language-server
    
    echo "✅ ARM/Bicep language tools installed"
}

# Create Bicep configuration directory
setup_bicep_config() {
    echo "📝 Setting up Bicep configuration..."
    
    # Create bicep configuration file
    mkdir -p /tmp/bicep-config
    cat > /tmp/bicep-config/bicepconfig.json << 'EOF'
{
  "analyzers": {
    "core": {
      "enabled": true,
      "verbose": false,
      "rules": {
        "no-unused-params": {
          "level": "warning"
        },
        "no-unused-vars": {
          "level": "warning"
        },
        "prefer-interpolation": {
          "level": "warning"
        },
        "secure-parameter-default": {
          "level": "error"
        },
        "simplify-interpolation": {
          "level": "warning"
        }
      }
    }
  },
  "formatting": {
    "indentKind": "Space",
    "indentSize": 2,
    "insertFinalNewline": true
  }
}
EOF
    
    echo "✅ Bicep configuration created at /tmp/bicep-config/bicepconfig.json"
    echo "💡 Copy this to your project root as bicepconfig.json to use it"
}

# Install PSRule for Azure (PowerShell-based linting)
install_psrule() {
    echo "📦 Installing PSRule for Azure..."
    
    # Install PowerShell if not present
    if ! command -v pwsh &> /dev/null; then
        echo "Installing PowerShell..."
        wget -q https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb
        dpkg -i packages-microsoft-prod.deb
        apt-get update
        apt-get install -y powershell
        rm packages-microsoft-prod.deb
    fi
    
    # Install PSRule modules
    pwsh -Command "Install-Module -Name PSRule.Rules.Azure -Scope AllUsers -Force -SkipPublisherCheck"
    
    echo "✅ PSRule for Azure installed"
}

# Main installation
echo "🚀 Starting Bicep tools installation..."

# Install dependencies
install_azure_cli

# Install core Bicep tools
install_bicep
install_arm_tools

# Install additional tools
install_psrule

# Setup configuration
setup_bicep_config

echo ""
echo "🎉 All Bicep tools installed successfully!"
echo ""
echo "📋 Installed tools:"
echo "  • Azure CLI (required for Bicep)"
echo "  • Bicep CLI ${BICEP_VERSION}"
echo "  • ARM/Bicep Language Server"
echo "  • PSRule for Azure (linting and validation)"
echo ""
echo "🔧 Useful commands:"
echo "  • bicep build main.bicep           # Compile Bicep to ARM"
echo "  • bicep decompile template.json    # Convert ARM to Bicep"
echo "  • bicep lint main.bicep            # Lint Bicep files"
echo "  • bicep format main.bicep          # Format Bicep files"
echo "  • az deployment group validate     # Validate deployment"
echo "  • az deployment group create       # Deploy resources"
echo "  • pwsh -c 'Invoke-PSRule -Format File -InputPath .' # PSRule validation"
echo ""
