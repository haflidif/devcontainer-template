#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Example usage of the DevContainer Template modular PowerShell architecture.

.DESCRIPTION
    This script demonstrates various ways to use the modular DevContainer Template
    for setting up Infrastructure as Code projects.
#>

# Import the modules from relative path
$ModulesPath = Join-Path $PSScriptRoot "..\..\modules"
Import-Module (Join-Path $ModulesPath "CommonModule.psm1") -Force
Import-Module (Join-Path $ModulesPath "AzureModule.psm1") -Force  
Import-Module (Join-Path $ModulesPath "DevContainerModule.psm1") -Force
Import-Module (Join-Path $ModulesPath "ProjectModule.psm1") -Force

Write-Host "🚀 DevContainer Template Examples (Modular Architecture)" -ForegroundColor Magenta
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Magenta

# Example 1: Check prerequisites
Write-Host "`n📋 Example 1: Check Prerequisites" -ForegroundColor Cyan
Write-Host "Test-Prerequisites" -ForegroundColor Yellow
Test-Prerequisites

# Example 2: Create Azure backend
Write-Host "`n📋 Example 2: Create Azure Terraform Backend" -ForegroundColor Cyan
$exampleCommand = @"
New-AzureTerraformBackend -StorageAccountName "myprojecttfstate" ``
                         -ResourceGroupName "terraform-rg" ``
                         -ContainerName "tfstate" ``
                         -Location "eastus" ``
                         -SubscriptionId "your-subscription-id"
"@

Write-Host $exampleCommand -ForegroundColor Yellow
Write-Host "(This is a demo - not actually creating the backend)" -ForegroundColor Gray

# Example 3: Initialize DevContainer in existing project
Write-Host "`n📋 Example 3: Initialize DevContainer Configuration" -ForegroundColor Cyan
$exampleCommand2 = @"
Initialize-ProjectDirectory -ProjectPath "." ``
                           -ProjectType "terraform"
Copy-DevContainerFiles -SourcePath "..\..\templates" ``
                       -TargetPath "."
"@

Write-Host $exampleCommand2 -ForegroundColor Yellow

# Example 4: Show help
Write-Host "`n📋 Example 4: Get Detailed Help" -ForegroundColor Cyan
Write-Host "Get-Help Initialize-DevContainer -Full" -ForegroundColor Yellow

# Example 5: Interactive prompts
Write-Host "`n📋 Example 5: Interactive Setup" -ForegroundColor Cyan
Write-Host "The module will prompt for required parameters if not provided:" -ForegroundColor Gray

$interactiveExample = @"
# This will prompt for TenantId, SubscriptionId, and ProjectName
Initialize-DevContainer

# You can also use aliases for shorter commands
init-devcontainer -TenantId "..." -SubscriptionId "..." -ProjectName "my-project"
new-iac -ProjectName "new-project" -TenantId "..." -SubscriptionId "..."
"@

Write-Host $interactiveExample -ForegroundColor Yellow

# Show all available commands from loaded modules
Write-Host "`n📋 Available Commands:" -ForegroundColor Cyan
$moduleNames = @("CommonModule", "AzureModule", "DevContainerModule", "InteractiveModule", "ProjectModule")
foreach ($moduleName in $moduleNames) {
    $commands = Get-Command -Module $moduleName -ErrorAction SilentlyContinue
    if ($commands) {
        Write-Host "`n${moduleName}:" -ForegroundColor Yellow
        foreach ($cmd in $commands) {
            Write-Host "• $($cmd.Name)" -ForegroundColor Green
            
            # Only show syntax for functions, not aliases
            if ($cmd.CommandType -eq 'Function') {
                try {
                    $syntax = (Get-Command $cmd.Name).ParameterSets[0].ToString()
                    Write-Host "  $syntax" -ForegroundColor Gray
                } catch {
                    Write-Host "  (syntax not available)" -ForegroundColor DarkGray
                }
            } elseif ($cmd.CommandType -eq 'Alias') {
                $aliasInfo = Get-Alias $cmd.Name
                Write-Host "  -> $($aliasInfo.ResolvedCommandName)" -ForegroundColor Gray
            }
        }
    }
}

Write-Host "`n💡 Pro Tips:" -ForegroundColor Yellow
Write-Host "• Use tab completion for parameter names and values" -ForegroundColor Gray
Write-Host "• Run Test-DevContainerPrerequisites before starting" -ForegroundColor Gray
Write-Host "• The module validates Azure GUIDs automatically" -ForegroundColor Gray
Write-Host "• Generated storage account names are automatically cleaned (alphanumeric only)" -ForegroundColor Gray
Write-Host "• Use -WhatIf parameter (where available) to see what would happen" -ForegroundColor Gray

Write-Host "`n🎉 Ready to accelerate your Infrastructure as Code development!" -ForegroundColor Green
