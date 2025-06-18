#Requires -Version 5.1

<#
.SYNOPSIS
    Interactive user input functions for DevContainer Accelerator.

.DESCRIPTION
    This module provides interactive user input and configuration functions.
#>

Import-Module -Name (Join-Path $PSScriptRoot "CommonModule.psm1") -Force
Import-Module -Name (Join-Path $PSScriptRoot "AzureModule.psm1") -Force

function Get-InteractiveInput {
    param(
        [string]$Prompt,
        [string]$DefaultValue = ""
    )
      $displayPrompt = if ($DefaultValue) { "$Prompt [$DefaultValue]" } else { $Prompt }
    $userInput = Read-Host "$displayPrompt"
    
    if ([string]::IsNullOrWhiteSpace($userInput) -and $DefaultValue) {
        return $DefaultValue
    }
    
    return $userInput
}

function Get-BackendConfiguration {
    param(
        [string]$ProjectName,
        [string]$SubscriptionId,
        [string]$Location
    )
    
    Write-ColorOutput "`n🏗️  Terraform Backend Configuration" "Cyan"
    Write-ColorOutput "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "Cyan"
    Write-ColorOutput "Configure Azure Storage for Terraform remote state management." "White"
    
    # Default values based on project
    $defaultRG = "$ProjectName-tfstate-rg"
    
    # Generate proper storage account name with constraints
    $storageAccountInfo = New-AzureStorageAccountName -ProjectName $ProjectName -Environment "dev" -Purpose "tfstate"
    $defaultSA = $storageAccountInfo.StorageAccountName
    Write-ColorOutput "💡 Suggested storage account name: $defaultSA (Display: $($storageAccountInfo.DisplayName))" "Yellow"
    
    $defaultContainer = 'tfstate'
    
    # Get user input with defaults
    $backendSubId = Get-InteractiveInput "Backend Subscription ID" $SubscriptionId
    $backendRG = Get-InteractiveInput "Resource Group for backend" $defaultRG
    $backendSA = Get-InteractiveInput "Storage Account name" $defaultSA
    $backendContainer = Get-InteractiveInput "Container name" $defaultContainer
    
    Write-ColorOutput "`n🔍 What would you like to do with the backend?" "Yellow"
    Write-ColorOutput "1. Validate existing backend (default)" "White"
    Write-ColorOutput "2. Create backend if it doesn't exist" "White"
    Write-ColorOutput "3. Skip backend setup (configure manually later)" "White"
    
    $choice = Get-InteractiveInput "Enter choice (1-3)" "1"
    
    $action = switch ($choice) {
        "2" { "create" }
        "3" { "skip" }
        default { "validate" }
    }
    
    return @{
        SubscriptionId = $backendSubId
        ResourceGroup = $backendRG
        StorageAccount = $backendSA
        Container = $backendContainer
        Action = $action
    }
}

Export-ModuleMember -Function Get-InteractiveInput, Get-BackendConfiguration
