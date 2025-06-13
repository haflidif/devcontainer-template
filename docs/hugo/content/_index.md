---
title: "DevContainer Template for Infrastructure as Code"
linkTitle: "Home"
type: "docs"
cascade:
  - type: "docs"
    _target:
      path: "/docs/**"
---

# DevContainer Template for Infrastructure as Code

Welcome to the comprehensive DevContainer template documentation for Terraform and Bicep development!

{{< blocks/cover title="DevContainer Template for Infrastructure as Code" image_anchor="top" height="full" color="primary" >}}
<div class="mx-auto">
	<a class="btn btn-lg btn-primary mr-3 mb-4" href="/docs/getting-started/">
		Get Started <i class="fas fa-arrow-alt-circle-right ml-2"></i>
	</a>
	<a class="btn btn-lg btn-secondary mr-3 mb-4" href="https://github.com/haflidif/devcontainer-template">
		GitHub <i class="fab fa-github ml-2 "></i>
	</a>
	<p class="lead mt-5">🚀 Quick Start | ✅ 38 Tests | 🔄 CI/CD Ready | 🛡️ Secure</p>
</div>
{{< /blocks/cover >}}

{{< blocks/section color="dark" >}}
{{% blocks/feature icon="fab fa-docker" title="Pre-configured DevContainer" %}}
Complete development environment with Terraform, Bicep, and all essential IaC tools.
{{% /blocks/feature %}}

{{% blocks/feature icon="fas fa-test-tube" title="Modern Testing Framework" %}}
Pester 5.0+ integration with 38 comprehensive tests and multiple execution modes.
{{% /blocks/feature %}}

{{% blocks/feature icon="fas fa-rocket" title="PowerShell Automation" %}}
Enhanced automation with cross-subscription backend support and guided setup.
{{% /blocks/feature %}}

{{< /blocks/section >}}

{{< blocks/section color="primary" >}}
<div class="col">
<h2 class="text-center">What's Included</h2>

### Core Infrastructure Tools
- **Terraform** - Infrastructure as Code
- **Bicep** - Azure native Infrastructure as Code  
- **TFLint** - Terraform linter with cloud provider rules
- **terraform-docs** - Documentation generator

### Security & Compliance
- **Checkov** - Static analysis for infrastructure security
- **tfsec** - Security scanner for Terraform
- **PSRule for Azure** - Azure resource validation

### Enhanced Features
- **🧪 Modern Testing**: Pester 5.0+ with 38 tests
- **⚡ PowerShell Automation**: Cross-subscription backend support
- **🎯 Developer Experience**: VS Code tasks and watch mode
- **📚 Documentation**: Hugo-based docs with GitHub Pages

</div>
{{< /blocks/section >}}

{{< blocks/section >}}
<div class="col-12">
<h2 class="text-center">Quick Start</h2>

Get up and running in minutes with our automated setup:

```powershell
# Clone and initialize
git clone https://github.com/haflidif/devcontainer-template.git
cd devcontainer-template

# Run initialization with your Azure details
.\Initialize-DevContainer.ps1 -TenantId "your-tenant-id" `
                             -SubscriptionId "your-subscription-id" `
                             -ProjectName "my-project"

# Validate everything works
.\tests\Test-DevContainer.ps1

# Open in VS Code
code .
```

<a class="btn btn-lg btn-primary mr-3 mb-4" href="/docs/getting-started/">
	Full Setup Guide <i class="fas fa-arrow-alt-circle-right ml-2"></i>
</a>

</div>
{{< /blocks/section >}}
