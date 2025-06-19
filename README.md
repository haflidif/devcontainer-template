# Getting Started Examples

This directory contains essential guides and documentation to help new users get started with the DevContainer Template.

## 📋 Contents

### AVM-DEVELOPMENT-GUIDE.md
Comprehensive guide for Azure Verified Modules (AVM) development covering:
- Development environment setup
- Best practices and guidelines
- Module structure and standards
- Testing and validation procedures

## 🚀 Quick Start Guide

### 1. Initial Setup
```bash
# Clone the repository
git clone <your-repo-url>
cd devcontainer-template

# Initialize the DevContainer
./Initialize-DevContainer.ps1
```

### 2. Choose Your Technology Stack
- **Terraform**: See [../terraform/](../terraform/) for examples
- **Bicep**: See [../bicep/](../bicep/) for templates
- **ARM Templates**: See [../arm/](../arm/) for JSON templates

### 3. Configure Your Environment
1. Copy `.devcontainer/devcontainer.env.example` to `.devcontainer/devcontainer.env`
2. Update the environment variables for your Azure subscription
3. Start the DevContainer in VS Code

### 4. Explore PowerShell Automation
- Review [../powershell/](../powershell/) examples
- Learn backend management with the DevContainer Template modules

## 🔧 Prerequisites

- **VS Code** with Dev Containers extension
- **Docker Desktop** running
- **Azure Subscription** (for cloud deployments)
- **PowerShell 5.1+** (for automation scripts)

## 📚 Learning Path

1. **Start Here**: Read `AVM-DEVELOPMENT-GUIDE.md`
2. **Configuration**: Review [../configuration/](../configuration/) settings
3. **Automation**: Explore [../powershell/](../powershell/) scripts
4. **Implementation**: Choose from [../terraform/](../terraform/), [../bicep/](../bicep/), or [../arm/](../arm/)

## 🆘 Need Help?

- Check [../docs/](../docs/) for detailed documentation
- Run [../tests/Validate-DevContainer.ps1](../tests/Validate-DevContainer.ps1) to verify your setup
- Review the main [README.md](../../README.md) for troubleshooting

## 🔗 Next Steps

Once you've completed the setup:
- Explore technology-specific examples
- Set up CI/CD pipelines with configuration templates
- Customize the DevContainer for your project needs

---

## 👥 Credits

**Created with ❤️ and in companionship with GitHub Copilot**

**Ideas & Architecture**: [Haflidi Fridthjofsson](https://github.com/haflidif)

*This project leverages AI-assisted development to accelerate Azure DevContainer template creation and management.*
