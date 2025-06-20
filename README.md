# DevContainer Template

[![GitHub Pages](https://img.shields.io/badge/docs-GitHub%20Pages-blue.svg)](https://haflidif.github.io/devcontainer-template/)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![GitHub Issues](https://img.shields.io/github/issues/haflidif/devcontainer-template.svg)](https://github.com/haflidif/devcontainer-template/issues)
[![GitHub Stars](https://img.shields.io/github/stars/haflidif/devcontainer-template.svg)](https://github.com/haflidif/devcontainer-template/stargazers)
[![Hugo](https://img.shields.io/badge/Hugo-Extended-FF4088.svg)](https://gohugo.io/)
[![Geekdoc Theme](https://img.shields.io/badge/Theme-Geekdoc-green.svg)](https://geekdocs.de/)
[![Pester Tests](https://img.shields.io/badge/Pester-38%20Tests-brightgreen.svg)](./tests/)

A comprehensive DevContainer template for Azure development with integrated tooling, documentation, and automation scripts.

## 📖 Documentation

Visit our comprehensive documentation site: **[https://haflidif.github.io/devcontainer-template/](https://haflidif.github.io/devcontainer-template/)**

## 🚀 Quick Start

### 1. Clone and Initialize
```bash
# Clone the repository
git clone https://github.com/haflidif/devcontainer-template.git
cd devcontainer-template

# Initialize the DevContainer
./Initialize-DevContainer.ps1
```

### 2. Open in VS Code
```bash
# Open in VS Code with DevContainer
code .
# Then reopen in container when prompted
```

### 3. Explore Examples
- **📚 [Documentation](https://haflidif.github.io/devcontainer-template/)** - Complete guides and reference
- **🛠️ [Terraform Examples](./examples/terraform/)** - Infrastructure as Code templates
- **🔧 [Bicep Examples](./examples/bicep/)** - Azure Resource Manager templates  
- **💻 [PowerShell Scripts](./examples/powershell/)** - Automation and tooling
- **⚙️ [Configuration](./examples/configuration/)** - Setup and customization

## 🎯 Features

- **🐳 DevContainer Ready**: Pre-configured development environment
- **☁️ Azure Focused**: Optimized for Azure development workflows
- **🛠️ Multi-Tool Support**: Terraform, Bicep, ARM Templates, PowerShell
- **📖 Rich Documentation**: Hugo-powered documentation site
- **🔄 CI/CD Ready**: GitHub Actions workflows included
- **🧪 Testing Framework**: Automated validation and testing
- **⚡ Flexible Backends**: Seamless local and Azure Terraform state management
- **🤖 Smart Automation**: Zero-touch backend infrastructure provisioning

## 🆕 Latest Enhancements (June 2025)

### **Modernized Backend Support**
- **🔄 Flexible Backend Types**: Easy switching between `local` and `azure` backends
- **☁️ Automatic Azure Setup**: Zero-configuration Azure backend infrastructure creation
- **📁 Smart File Generation**: Proper `main.tf` and `backend.tfvars` configuration
- **🔐 Conditional Authentication**: Azure credentials only required when needed
- **⚡ Improved User Experience**: Single-command setup for any scenario

```powershell
# Local development - no Azure credentials needed
.\Initialize-DevContainer.ps1 -ProjectName "my-app" -BackendType local

# Azure production - automatic cloud infrastructure
.\Initialize-DevContainer.ps1 -ProjectName "my-app" -BackendType azure `
    -TenantId "your-tenant" -SubscriptionId "your-subscription"
```

## 📋 Project Documentation

Explore the complete evolution and features of this project:

### **📖 [Complete Documentation Site](https://haflidif.github.io/devcontainer-template/)**
- **[Getting Started](https://haflidif.github.io/devcontainer-template/docs/getting-started/)** - Quick setup with backend selection
- **[Backend Configuration](https://haflidif.github.io/devcontainer-template/docs/configuration/backend/)** - Flexible local/Azure backends  
- **[Project Journey](https://haflidif.github.io/devcontainer-template/docs/project-journey/)** - Evolution from concept to enterprise platform
- **[Latest Release (v2.0.0)](https://haflidif.github.io/devcontainer-template/docs/releases/v2-0-0/)** - Backend modernization features
- **[Changelog](https://haflidif.github.io/devcontainer-template/docs/changelog/)** - Complete version history

### **Key Documentation Highlights:**
- **Phase 1**: Foundation and basic DevContainer setup
- **Phase 2**: Modular architecture and testing framework  
- **Phase 3**: Hugo documentation modernization
- **Phase 4**: Backend modernization and flexible infrastructure support ⭐ *Latest*

## � Prerequisites

- **VS Code** with [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
- **Docker Desktop** installed and running
- **Azure Subscription** (for cloud deployments)
- **Git** for version control

## 🏗️ Project Structure

```
devcontainer-template/
├── .devcontainer/          # DevContainer configuration
├── .github/                # GitHub Actions workflows  
├── docs/                   # Hugo documentation site
├── examples/               # Usage examples and templates
│   ├── terraform/          # Terraform IaC examples
│   ├── bicep/             # Bicep template examples
│   ├── arm/               # ARM template examples
│   ├── powershell/        # PowerShell automation scripts
│   └── configuration/     # Configuration examples
├── modules/               # Reusable modules
├── tests/                 # Testing and validation
└── README.md             # This file
```

---

## 👥 Credits

**Created with ❤️ and in companionship with GitHub Copilot**

**Ideas & Architecture**: [Haflidi Fridthjofsson](https://github.com/haflidif)

*This project leverages AI-assisted development to accelerate Azure DevContainer template creation and management.*
