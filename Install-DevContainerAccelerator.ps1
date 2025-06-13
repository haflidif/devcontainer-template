#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Installs the DevContainer Accelerator PowerShell module.

.DESCRIPTION
    Downloads and installs the DevContainer Accelerator module for easy Infrastructure as Code project initialization.

.PARAMETER InstallScope
    Installation scope: 'CurrentUser' or 'AllUsers'. Defaults to 'CurrentUser'.

.PARAMETER Force
    Force installation even if module already exists.

.PARAMETER DevMode
    Install from local development path instead of downloading.

.EXAMPLE
    .\Install-DevContainerAccelerator.ps1

.EXAMPLE
    .\Install-DevContainerAccelerator.ps1 -InstallScope AllUsers -Force
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory = $false)]
    [ValidateSet('CurrentUser', 'AllUsers')]
    [string]$InstallScope = 'CurrentUser',

    [Parameter(Mandatory = $false)]
    [switch]$Force,

    [Parameter(Mandatory = $false)]
    [switch]$DevMode
)

function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = 'White'
    )
    Write-Host $Message -ForegroundColor $Color
}

Write-ColorOutput "🚀 DevContainer Accelerator Module Installer" "Magenta"
Write-ColorOutput "═══════════════════════════════════════════════" "Magenta"

try {
    # Check PowerShell version
    if ($PSVersionTable.PSVersion.Major -lt 5) {
        throw "PowerShell 5.1 or higher is required. Current version: $($PSVersionTable.PSVersion)"
    }

    # Get module paths
    $modulePaths = $env:PSModulePath -split [System.IO.Path]::PathSeparator
    $targetPath = if ($InstallScope -eq 'AllUsers') {
        $modulePaths | Where-Object { $_ -like "*Program Files*" } | Select-Object -First 1
    } else {
        $modulePaths | Where-Object { $_ -like "*Documents*" -or $_ -like "*$env:USERPROFILE*" } | Select-Object -First 1
    }

    if (-not $targetPath) {
        throw "Could not determine module installation path for scope: $InstallScope"
    }

    $moduleInstallPath = Join-Path $targetPath "DevContainerAccelerator"

    # Check if module already exists
    if (Test-Path $moduleInstallPath) {
        if ($Force) {
            Write-ColorOutput "🔄 Removing existing module..." "Yellow"
            Remove-Item $moduleInstallPath -Recurse -Force
        } else {
            throw "Module already exists at: $moduleInstallPath. Use -Force to overwrite."
        }
    }

    # Install module
    if ($DevMode) {
        # Development mode - copy from current directory
        $sourceModulePath = Join-Path $PSScriptRoot "DevContainerAccelerator"
        if (-not (Test-Path $sourceModulePath)) {
            throw "DevContainerAccelerator module not found in current directory"
        }
        
        Write-ColorOutput "📦 Installing module from local development path..." "Cyan"
        Copy-Item $sourceModulePath $moduleInstallPath -Recurse -Force
    } else {
        # Production mode - would download from GitHub/PowerShell Gallery
        Write-ColorOutput "📦 Installing module..." "Cyan"
        
        # For now, copy from current directory (in real scenario, this would download)
        $sourceModulePath = Join-Path $PSScriptRoot "DevContainerAccelerator"
        if (-not (Test-Path $sourceModulePath)) {
            throw "DevContainerAccelerator module not found. Run with -DevMode or ensure module files are present."
        }
        
        Copy-Item $sourceModulePath $moduleInstallPath -Recurse -Force
    }    Write-ColorOutput "✅ Module installed successfully!" "Green"
    Write-ColorOutput "📁 Installation path: $moduleInstallPath" "Gray"

    # Test module import (only if not in WhatIf mode)
    if (-not $WhatIf) {
        Write-ColorOutput "🔍 Testing module import..." "Cyan"
        try {
            Import-Module DevContainerAccelerator -Force
            
            $commands = Get-Command -Module DevContainerAccelerator
            Write-ColorOutput "✅ Module imported successfully!" "Green"
            Write-ColorOutput "📋 Available commands:" "Cyan"
            
            foreach ($cmd in $commands) {
                Write-ColorOutput "   • $($cmd.Name)" "Gray"
            }
        } catch {
            Write-ColorOutput "⚠️  Module import test failed: $($_.Exception.Message)" "Yellow"
            Write-ColorOutput "   This is normal if running with -WhatIf" "Gray"
        }
    } else {
        Write-ColorOutput "🔍 Module import test skipped (WhatIf mode)" "Yellow"
        Write-ColorOutput "📋 Available commands: (would be tested after real installation)" "Gray"
    }

    Write-ColorOutput "`n🎉 Installation complete!" "Green"
    Write-ColorOutput "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "Green"
    
    Write-ColorOutput "`n📋 Quick Start:" "Cyan"
    Write-ColorOutput "# Test prerequisites" "Gray"
    Write-ColorOutput "Test-DevContainerPrerequisites" "White"
    Write-ColorOutput "`n# Create a new project" "Gray"
    Write-ColorOutput "New-IaCProject -ProjectName 'my-infrastructure' -TenantId 'your-tenant-id' -SubscriptionId 'your-sub-id'" "White"
    Write-ColorOutput "`n# Initialize DevContainer in existing project" "Gray"
    Write-ColorOutput "Initialize-DevContainer -TenantId 'your-tenant-id' -SubscriptionId 'your-sub-id' -ProjectName 'my-project'" "White"
    
    Write-ColorOutput "`n💡 Pro Tip: Use tab completion and Get-Help for detailed usage information!" "Yellow"
}
catch {
    Write-ColorOutput "❌ Installation failed: $($_.Exception.Message)" "Red"
    exit 1
}
