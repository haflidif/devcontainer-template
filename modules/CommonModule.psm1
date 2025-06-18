#Requires -Version 5.1

<#
.SYNOPSIS
    Common utilities and helper functions for DevContainer Accelerator.

.DESCRIPTION
    This module provides shared utility functions used across the DevContainer Accelerator.
    Includes color output, validation, and common helper functions.
#>

function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = 'White'
    )
    if ($Host.UI.SupportsVirtualTerminal -or $env:TERM) {
        Write-Host $Message -ForegroundColor $Color
    } else {
        Write-Output $Message
    }
}

function Test-IsGuid {
    param([string]$InputString)
    $guidRegex = '^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$'
    return $InputString -match $guidRegex
}

function Test-Prerequisites {
    Write-ColorOutput "🔍 Checking prerequisites..." "Cyan"
    
    $issues = @()
    
    # Check Docker CLI
    try {
        $null = Get-Command docker -ErrorAction Stop
        Write-ColorOutput "✅ Docker CLI found" "Green"
    }
    catch {
        $issues += "Docker CLI not found. Please install Docker Desktop."
        Write-ColorOutput "❌ Docker CLI not found" "Red"
    }
    
    # Check VS Code CLI
    try {
        $null = Get-Command code -ErrorAction Stop
        Write-ColorOutput "✅ VS Code CLI found" "Green"
    }
    catch {
        $issues += "VS Code CLI not found. Please install VS Code and ensure 'code' command is in PATH."
        Write-ColorOutput "❌ VS Code CLI not found" "Red"
    }
    
    if ($issues.Count -gt 0) {
        Write-ColorOutput "`n❌ Prerequisites check failed:" "Red"
        $issues | ForEach-Object { Write-ColorOutput "   • $_" "Red" }
        return $false
    }
    
    return $true
}

function Show-NextSteps {
    param(
        [string]$ProjectPath,
        [string]$ProjectType,
        [hashtable]$BackendInfo = $null
    )
    
    Write-ColorOutput "`n🎉 DevContainer setup completed successfully!" "Green"
    Write-ColorOutput "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "Green"
    
    Write-ColorOutput "`n📁 Project Location: $ProjectPath" "Cyan"
    Write-ColorOutput "🔧 Project Type: $ProjectType" "Cyan"
    
    if ($BackendInfo) {
        Write-ColorOutput "`n🗄️  Terraform Backend:" "Yellow"
        Write-ColorOutput "   Storage Account: $($BackendInfo.StorageAccount)" "Gray"
        Write-ColorOutput "   Resource Group: $($BackendInfo.ResourceGroup)" "Gray"
        Write-ColorOutput "   Container: $($BackendInfo.Container)" "Gray"
    }
    
    Write-ColorOutput "`n🚀 Next Steps:" "Yellow"
    Write-ColorOutput "1. Open the project in VS Code:" "White"
    Write-ColorOutput "   code `"$ProjectPath`"" "Gray"
    Write-ColorOutput "`n2. When prompted, choose 'Reopen in Container'" "White"
    Write-ColorOutput "`n3. Wait for the DevContainer to build (first time may take a few minutes)" "White"
    Write-ColorOutput "`n4. Start developing your Infrastructure as Code!" "White"
    
    if ($ProjectType -in @('terraform', 'both')) {
        Write-ColorOutput "`n🔧 Terraform Commands:" "Yellow"
        Write-ColorOutput "   terraform init     # Initialize Terraform" "Gray"
        Write-ColorOutput "   terraform plan     # Preview changes" "Gray"
        Write-ColorOutput "   terraform apply    # Apply changes" "Gray"
    }
    
    if ($ProjectType -in @('bicep', 'both')) {
        Write-ColorOutput "`n🔧 Bicep Commands:" "Yellow"
        Write-ColorOutput "   az bicep build -f main.bicep                    # Compile Bicep to ARM" "Gray"
        Write-ColorOutput "   az deployment group create --template-file ...  # Deploy to Azure" "Gray"
    }
    
    Write-ColorOutput "`n📚 Documentation: https://containers.dev/" "Blue"
    Write-ColorOutput "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "Green"
}

Export-ModuleMember -Function Write-ColorOutput, Test-IsGuid, Test-Prerequisites, Show-NextSteps
