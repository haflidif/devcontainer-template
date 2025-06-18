# DevContainer Template

> **A modern, comprehensive development container template for Infrastructure as Code projects**

[![Documentation](https://img.shields.io/badge/docs-Hugo%20Site-blue?style=flat-square)](https://haflidif.github.io/devcontainer-template/)
[![Tests](https://img.shields.io/badge/tests-38%20passing-success?style=flat-square)](#testing)
[![License](https://img.shields.io/badge/license-GPL--3.0-green?style=flat-square)](LICENSE)
[![PowerShell](https://img.shields.io/badge/PowerShell-7.0+-blue?style=flat-square)](#)
[![Refactored](https://img.shields.io/badge/status-Modular%20✅-brightgreen?style=flat-square)](#modular-architecture)

## ✨ Features

- **🐳 Multi-Language Support**: Terraform, Bicep, PowerShell, and more
- **🧪 Modern Testing**: Pester-based validation with 38 comprehensive tests
- **📚 Beautiful Documentation**: Hugo-powered site with automatic deployment
- **🔧 Rich Tooling**: Pre-configured with essential IaC development tools
- **⚡ Quick Setup**: One-command initialization and configuration
- **🔒 Security-First**: Built-in security scanning and validation
- **🚀 CI/CD Ready**: GitHub Actions workflows for automation
- **🏗️ Modular Architecture**: Clean, maintainable, and extensible codebase

## 🚀 Quick Start

```powershell
# Clone and setup
git clone https://github.com/haflidif/devcontainer-template.git
cd devcontainer-template

# Initialize with your details (MODULAR VERSION)
.\Initialize-DevContainer.ps1 -TenantId "your-tenant-id" `
                              -SubscriptionId "your-subscription-id" `
                              -ProjectName "my-project"

# Test safely first (recommended)
.\Initialize-DevContainer.ps1 -TenantId "your-tenant-id" `
                              -SubscriptionId "your-subscription-id" `
                              -ProjectName "my-project" `
                              -WhatIf

# Validate everything works
.\tests\Validate-DevContainer.ps1

# Open in VS Code (choose "Reopen in Container")
code .
```

## 🏗️ Modular Architecture

**✅ Refactored for Reliability & Maintainability**

The DevContainer Accelerator uses a modular architecture:

- **`Initialize-DevContainer.ps1`** - Production-ready script with hybrid architecture
- **`modules/`** - Specialized PowerShell modules for specific functionality
- **Fallback Systems** - Works reliably even when modules fail to load
- **Enhanced Error Handling** - Comprehensive error management throughout
- **WhatIf Support** - Safe testing mode to preview changes

[📖 Read the complete refactoring documentation](docs/MODULAR_REFACTORING.md)

## 📖 Documentation

**📚 [Complete Documentation Site](https://haflidif.github.io/devcontainer-template/)**

Our comprehensive documentation covers:

- **[Getting Started Guide](https://haflidif.github.io/devcontainer-template/docs/getting-started/)** - Step-by-step setup and configuration
- **[Examples](https://haflidif.github.io/devcontainer-template/docs/examples/)** - Real-world usage patterns and templates
- **[PowerShell Module](https://haflidif.github.io/devcontainer-template/docs/api/)** - Modular PowerShell architecture function reference
- **[Testing Framework](https://haflidif.github.io/devcontainer-template/docs/testing/)** - Comprehensive validation and testing guide
- **[Configuration](https://haflidif.github.io/devcontainer-template/docs/configuration/)** - Advanced setup and customization
- **[Troubleshooting](https://haflidif.github.io/devcontainer-template/docs/troubleshooting/)** - Common issues and solutions

## 🛠️ What's Included

### Core Tools
- **Terraform** + TFLint + terraform-docs + Terragrunt
- **Azure Bicep** + Azure CLI + PowerShell
- **Security**: Checkov, TFSec, PSRule
- **Development**: Python, Docker, pre-commit, Git

### PowerShell Automation
- **DevContainer Accelerator Module** with 12+ automation functions
- **Backend Management** with cross-subscription support
- **Interactive Setup** with guided configuration
- **Advanced Validation** with comprehensive testing

## 🧪 Testing

Run comprehensive validation with our modern Pester-based testing framework:

```powershell
# Quick syntax validation
.\tests\Validate-DevContainer.ps1 -SyntaxOnly

# Full validation suite (38 tests)
.\tests\Validate-DevContainer.ps1 -Full

# Watch mode for development
.\tests\Validate-DevContainer.ps1 -Watch
```

## 🤝 Contributing

We welcome contributions! Please see our [documentation site](https://haflidif.github.io/devcontainer-template/) for:

- **[Contributing Guide](https://haflidif.github.io/devcontainer-template/docs/contributing/)** - How to contribute to the project
- **[Development Setup](https://haflidif.github.io/devcontainer-template/docs/development/)** - Setting up your development environment
- **[Module Reference](https://haflidif.github.io/devcontainer-template/docs/api/)** - Modular PowerShell architecture function reference

## 📄 License

This project is licensed under the [GPL-3.0 License](LICENSE).

## 🔗 Links

- **[📚 Documentation](https://haflidif.github.io/devcontainer-template/)** - Complete documentation site
- **[🚀 Examples](https://haflidif.github.io/devcontainer-template/docs/examples/)** - Usage examples and templates
- **[🐛 Issues](https://github.com/haflidif/devcontainer-template/issues)** - Report bugs or request features
- **[💬 Discussions](https://github.com/haflidif/devcontainer-template/discussions)** - Community discussions

---

**⭐ If this project helps you, please consider giving it a star on GitHub!**
