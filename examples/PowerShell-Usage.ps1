#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Quick examples of using the DevContainer Template with modular PowerShell.

.DESCRIPTION
    This file provides quick reference examples for the modular DevContainer Template.
    For detailed examples, see examples/powershell/ directory.
#>

Write-Host "🚀 DevContainer Template - Quick Examples" -ForegroundColor Magenta
Write-Host "════════════════════════════════════════════════" -ForegroundColor Magenta

Write-Host "`n📋 Basic Usage:" -ForegroundColor Cyan
Write-Host ".\Initialize-DevContainer.ps1 -TenantId 'your-tenant-id' -SubscriptionId 'your-subscription-id' -ProjectName 'my-project'" -ForegroundColor Yellow

Write-Host "`n📋 With Backend Creation:" -ForegroundColor Cyan  
Write-Host ".\Initialize-DevContainer.ps1 -TenantId 'your-tenant-id' -SubscriptionId 'your-subscription-id' -ProjectName 'my-project' -CreateBackend" -ForegroundColor Yellow

Write-Host "`n📋 Test Your Setup:" -ForegroundColor Cyan
Write-Host ".\tests\Test-DevContainer.ps1 -Mode Quick" -ForegroundColor Yellow

Write-Host "`n📋 Validate Configuration:" -ForegroundColor Cyan
Write-Host ".\Validate-DevContainer.ps1" -ForegroundColor Yellow

Write-Host "`n📚 For detailed examples, see: examples\powershell\" -ForegroundColor Blue
