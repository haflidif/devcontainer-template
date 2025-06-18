#Requires -Version 5.1
#Requires -Module Pester

<#
.SYNOPSIS
    Comprehensive test runner for DevContainer Template

.DESCRIPTION
    Runs all unit and integration tests for the DevContainer Template modules
    and provides detailed reporting for Infrastructure as Code development environments.
#>

[CmdletBinding()]
param(
    [ValidateSet('Unit', 'Integration', 'All')]
    [string]$TestType = 'All',
    
    [string]$OutputPath = (Join-Path $PSScriptRoot "TestResults"),
    
    [switch]$ShowCoverage,
    
    [switch]$PassThru
)

# Ensure Pester module is available
if (-not (Get-Module -ListAvailable -Name Pester)) {
    Write-Host "❌ Pester module not found. Installing..." -ForegroundColor Red
    Install-Module -Name Pester -Force -SkipPublisherCheck
}

# Import Pester
Import-Module Pester -Force

# Create output directory
if (-not (Test-Path $OutputPath)) {
    New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
}

Write-Host "🧪 DevContainer Template Test Runner" -ForegroundColor Blue
Write-Host "═══════════════════════════════════════════" -ForegroundColor Blue

# Configure test paths
$TestsRoot = $PSScriptRoot
$UnitTestPath = Join-Path $TestsRoot "unit"
$IntegrationTestPath = Join-Path $TestsRoot "integration"

# Build test configuration
$TestPaths = @()

switch ($TestType) {
    'Unit' { 
        $TestPaths += $UnitTestPath
        Write-Host "🔬 Running Unit Tests only" -ForegroundColor Cyan
    }
    'Integration' { 
        $TestPaths += $IntegrationTestPath
        Write-Host "🔗 Running Integration Tests only" -ForegroundColor Cyan
    }
    'All' { 
        $TestPaths += $UnitTestPath, $IntegrationTestPath
        Write-Host "🎯 Running All Tests" -ForegroundColor Cyan
    }
}

# Pester configuration
$PesterConfig = @{
    Run = @{
        Path = $TestPaths
        PassThru = $true
    }
    Output = @{
        Verbosity = 'Detailed'
    }
    TestResult = @{
        Enabled = $true
        OutputPath = Join-Path $OutputPath "TestResults.xml"
        OutputFormat = 'NUnitXml'
    }
}

if ($ShowCoverage) {
    $PesterConfig.CodeCoverage = @{
        Enabled = $true
        Path = @(
            (Join-Path $PSScriptRoot "..\modules\*.psm1"),
            (Join-Path $PSScriptRoot "..\Initialize-DevContainer-New.ps1")
        )
        OutputPath = Join-Path $OutputPath "Coverage.xml"
        OutputFormat = 'JaCoCo'
    }
}

try {
    # Run tests
    Write-Host "`n🚀 Starting test execution..." -ForegroundColor Green
    $StartTime = Get-Date
    
    $TestResults = Invoke-Pester -Configuration $PesterConfig
    
    $EndTime = Get-Date
    $Duration = $EndTime - $StartTime
    
    # Display results summary
    Write-Host "`n📊 Test Results Summary" -ForegroundColor Blue
    Write-Host "═══════════════════════" -ForegroundColor Blue
    Write-Host "⏱️  Duration: $($Duration.TotalSeconds.ToString('F2')) seconds" -ForegroundColor Gray
    Write-Host "📈 Total Tests: $($TestResults.TotalCount)" -ForegroundColor White
    Write-Host "✅ Passed: $($TestResults.PassedCount)" -ForegroundColor Green
    Write-Host "❌ Failed: $($TestResults.FailedCount)" -ForegroundColor Red
    Write-Host "⏭️  Skipped: $($TestResults.SkippedCount)" -ForegroundColor Yellow
    
    if ($TestResults.FailedCount -eq 0) {
        Write-Host "`n🎉 All tests passed!" -ForegroundColor Green
        $ExitCode = 0
    } else {
        Write-Host "`n💥 Some tests failed!" -ForegroundColor Red
        $ExitCode = 1
        
        # Show failed tests
        Write-Host "`n❌ Failed Tests:" -ForegroundColor Red
        foreach ($failedTest in $TestResults.Failed) {
            Write-Host "   • $($failedTest.Name)" -ForegroundColor Red
            if ($failedTest.ErrorRecord) {
                Write-Host "     $($failedTest.ErrorRecord.Exception.Message)" -ForegroundColor DarkRed
            }
        }
    }
    
    if ($ShowCoverage -and $TestResults.CodeCoverage) {
        Write-Host "`n📋 Code Coverage:" -ForegroundColor Blue
        Write-Host "   Coverage: $($TestResults.CodeCoverage.CoveragePercent.ToString('F2'))%" -ForegroundColor White
        Write-Host "   Covered Lines: $($TestResults.CodeCoverage.CoveredCommands.Count)" -ForegroundColor Green
        Write-Host "   Total Lines: $($TestResults.CodeCoverage.AnalyzedCommands.Count)" -ForegroundColor Gray
    }
    
    Write-Host "`n📁 Test results saved to: $OutputPath" -ForegroundColor Cyan
    
    if ($PassThru) {
        return $TestResults
    }
    
    exit $ExitCode
}
catch {
    Write-Host "`n❌ Test execution failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host $_.ScriptStackTrace -ForegroundColor DarkRed
    exit 2
}
