#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Example usage of the DevContainer Accelerator module.

.DESCRIPTION
    This script demonstrates various ways to use the DevContainer Accelerator
    for setting up Infrastructure as Code projects.
#>

# Import the module from relative path
$ModulePath = Join-Path $PSScriptRoot "..\DevContainerAccelerator\DevContainerAccelerator.psm1"
Import-Module $ModulePath -Force

Write-Host "🚀 DevContainer Accelerator Examples" -ForegroundColor Magenta
Write-Host "═══════════════════════════════════════" -ForegroundColor Magenta

# Example 1: Check prerequisites
Write-Host "`n📋 Example 1: Check Prerequisites" -ForegroundColor Cyan
Write-Host "Test-DevContainerPrerequisites" -ForegroundColor Yellow
Test-DevContainerPrerequisites

# Example 2: Create a new Terraform project
Write-Host "`n📋 Example 2: Create New Terraform Project" -ForegroundColor Cyan
$exampleCommand = @"
New-IaCProject -ProjectName "example-terraform-project" ``
               -TenantId "12345678-1234-1234-1234-123456789012" ``
               -SubscriptionId "87654321-4321-4321-4321-210987654321" ``
               -ProjectType "terraform" ``
               -Environment "dev" ``
               -Location "eastus" ``
               -InitializeGit ``
               -IncludeExamples
"@

Write-Host $exampleCommand -ForegroundColor Yellow
Write-Host "(This is a demo - not actually creating the project)" -ForegroundColor Gray

# Example 3: Initialize DevContainer in existing project
Write-Host "`n📋 Example 3: Add DevContainer to Existing Project" -ForegroundColor Cyan
$exampleCommand2 = @"
Initialize-DevContainer -TenantId "12345678-1234-1234-1234-123456789012" ``
                       -SubscriptionId "87654321-4321-4321-4321-210987654321" ``
                       -ProjectName "my-existing-project" ``
                       -Environment "prod" ``
                       -Location "westeurope" ``
                       -ProjectType "both" ``
                       -IncludeExamples
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

# Show all available commands
Write-Host "`n📋 Available Commands:" -ForegroundColor Cyan
$commands = Get-Command -Module DevContainerAccelerator
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

Write-Host "`n💡 Pro Tips:" -ForegroundColor Yellow
Write-Host "• Use tab completion for parameter names and values" -ForegroundColor Gray
Write-Host "• Run Test-DevContainerPrerequisites before starting" -ForegroundColor Gray
Write-Host "• The module validates Azure GUIDs automatically" -ForegroundColor Gray
Write-Host "• Generated storage account names are automatically cleaned (alphanumeric only)" -ForegroundColor Gray
Write-Host "• Use -WhatIf parameter (where available) to see what would happen" -ForegroundColor Gray

Write-Host "`n🎉 Ready to accelerate your Infrastructure as Code development!" -ForegroundColor Green
