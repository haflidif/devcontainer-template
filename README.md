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
