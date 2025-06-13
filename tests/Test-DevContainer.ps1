#!/usr/bin/env pwsh

<#
.SYNOPSIS
    Quick test runner for DevContainer template validation

.DESCRIPTION
    Simplified test runner that provides common test execution scenarios
    for the DevContainer template validation.

.PARAMETER Quick
    Run only syntax and basic structure tests (fast execution)

.PARAMETER Full
    Run all tests including integration tests (comprehensive)

.PARAMETER CI
    Run tests in CI mode with XML output and appropriate verbosity

.PARAMETER Watch
    Run tests in watch mode (requires Pester 5.0+)

.EXAMPLE
    .\tests\Test-DevContainer.ps1
    Run quick validation tests

.EXAMPLE
    .\tests\Test-DevContainer.ps1 -Full
    Run comprehensive validation

.EXAMPLE
    .\tests\Test-DevContainer.ps1 -CI
    Run tests for CI/CD pipeline
#>

[CmdletBinding()]
param(
    [Parameter(HelpMessage = "Run quick tests (syntax and basic structure)")]
    [switch]$Quick,
    
    [Parameter(HelpMessage = "Run full comprehensive tests")]
    [switch]$Full,
    
    [Parameter(HelpMessage = "Run in CI mode with XML output")]
    [switch]$CI,
    
    [Parameter(HelpMessage = "Run tests in watch mode (experimental)")]
    [switch]$Watch
)

# Set default behavior
if (-not $Quick -and -not $Full -and -not $CI -and -not $Watch) {
    $Quick = $true
}

# Get script directory
$TestDir = $PSScriptRoot
if (-not $TestDir) {
    $TestDir = Split-Path $MyInvocation.MyCommand.Path -Parent
}

Write-Host "🧪 DevContainer Template Test Runner" -ForegroundColor Magenta
Write-Host "═══════════════════════════════════════" -ForegroundColor Magenta

# Check if Pester is available
try {
    Import-Module Pester -MinimumVersion 5.0 -ErrorAction Stop
    $PesterAvailable = $true
    $PesterVersion = (Get-Module Pester).Version
    Write-Host "✅ Pester $PesterVersion detected" -ForegroundColor Green
} catch {
    $PesterAvailable = $false
    Write-Warning "❌ Pester 5.0+ not available. Using legacy validation."
    Write-Host "💡 Install Pester for enhanced testing: Install-Module Pester -Force" -ForegroundColor Yellow
}

if ($PesterAvailable) {
    $TestPath = Join-Path $TestDir "DevContainer.Tests.ps1"
      if ($Quick) {
        Write-Host "🏃‍♂️ Running Quick Tests (Syntax + Module + Structure)" -ForegroundColor Cyan
        $result = Invoke-Pester -Path $TestPath -Tag @("Syntax", "Module", "Structure") -Output Normal -PassThru
        
        if ($result) {
            Write-Host "`n📊 Quick Test Summary:" -ForegroundColor Yellow
            Write-Host "  Total: $($result.TotalCount)" -ForegroundColor White
            Write-Host "  Passed: $($result.PassedCount)" -ForegroundColor Green
            Write-Host "  Failed: $($result.FailedCount)" -ForegroundColor Red
            Write-Host "  Skipped: $($result.SkippedCount)" -ForegroundColor Yellow
        }
    }    elseif ($Full) {
        Write-Host "🔍 Running Full Test Suite" -ForegroundColor Cyan
        $result = Invoke-Pester -Path $TestPath -Output Detailed -PassThru
        
        if ($result) {
            Write-Host "`n📊 Full Test Summary:" -ForegroundColor Yellow
            Write-Host "  Total: $($result.TotalCount)" -ForegroundColor White
            Write-Host "  Passed: $($result.PassedCount)" -ForegroundColor Green
            Write-Host "  Failed: $($result.FailedCount)" -ForegroundColor Red
            Write-Host "  Skipped: $($result.SkippedCount)" -ForegroundColor Yellow
            Write-Host "  NotRun: $($result.NotRunCount)" -ForegroundColor Gray
        }
    }elseif ($CI) {
        Write-Host "🤖 Running CI Tests with XML Output" -ForegroundColor Cyan
        $config = New-PesterConfiguration
        $config.Run.Path = $TestPath
        $config.Output.Verbosity = "Normal"
        $config.TestResult.Enabled = $true
        $config.TestResult.OutputPath = Join-Path $TestDir "TestResults.xml"
        $config.TestResult.OutputFormat = "NUnitXml"
        $config.Run.PassThru = $true  # This ensures we get a result object back
        
        $result = Invoke-Pester -Configuration $config
        
        Write-Host "`n📊 CI Test Summary:" -ForegroundColor Yellow
        
        # Check if result object exists and has properties
        if ($result) {
            # In Pester 5.x, the main properties are directly on the result object
            Write-Host "  Total: $($result.TotalCount)" -ForegroundColor White
            Write-Host "  Passed: $($result.PassedCount)" -ForegroundColor Green
            Write-Host "  Failed: $($result.FailedCount)" -ForegroundColor Red
            Write-Host "  Skipped: $($result.SkippedCount)" -ForegroundColor Yellow
            Write-Host "  NotRun: $($result.NotRunCount)" -ForegroundColor Gray
            
            if ($result.FailedCount -gt 0) { 
                Write-Host "  Exit Code: 1 (Tests Failed)" -ForegroundColor Red
            } else {
                Write-Host "  Exit Code: 0 (All Tests Passed)" -ForegroundColor Green
            }
        } else {
            Write-Host "  No result object returned from Invoke-Pester" -ForegroundColor Red
        }
        
        Write-Host "  Output: $(Join-Path $TestDir 'TestResults.xml')" -ForegroundColor Gray
        
        # Exit based on failure count
        if ($result -and $result.FailedCount -gt 0) { 
            exit 1 
        }
    }
    elseif ($Watch) {
        Write-Host "👀 Starting Watch Mode (Press Ctrl+C to stop)" -ForegroundColor Cyan
        Write-Host "   Watching for changes in PowerShell files..." -ForegroundColor Gray
        
        # Simple watch implementation
        $lastRun = Get-Date
        while ($true) {
            $files = Get-ChildItem (Split-Path $TestDir -Parent) -Recurse -Include "*.ps1", "*.psm1", "*.psd1" |
                Where-Object { $_.LastWriteTime -gt $lastRun }
            
            if ($files) {
                Write-Host "`n🔄 Changes detected, running tests..." -ForegroundColor Yellow
                Invoke-Pester -Path $TestPath -Tag @("Syntax", "Module") -Output Minimal
                $lastRun = Get-Date
                Write-Host "   Watching for changes..." -ForegroundColor Gray
            }
            
            Start-Sleep -Seconds 2
        }
    }
} else {
    # Fall back to legacy validation
    Write-Host "📜 Running Legacy Validation" -ForegroundColor Cyan
    $validationScript = Join-Path $TestDir "Validate-DevContainer.ps1"
    
    if ($Quick) {
        & $validationScript -SyntaxOnly
    } elseif ($Full) {
        & $validationScript -Full
    } elseif ($CI) {
        & $validationScript -Full -Quiet
    } else {
        & $validationScript
    }
}

Write-Host "`n✨ Test run completed!" -ForegroundColor Green
