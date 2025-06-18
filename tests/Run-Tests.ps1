#Requires -Version 5.1
#Requires -Modules Pester

<#
.SYNOPSIS
    Test runner for DevContainer Accelerator modules and scripts.

.DESCRIPTION
    Runs comprehensive Pester tests for all modules and integration scenarios.
    Provides detailed test results and coverage information.

.PARAMETER TestType
    Type of tests to run: 'Unit', 'Integration', or 'All'. Default is 'All'.

.PARAMETER GenerateReport
    Generate detailed HTML test report.

.PARAMETER ShowCoverage
    Show code coverage information.

.EXAMPLE
    .\Run-Tests.ps1

.EXAMPLE
    .\Run-Tests.ps1 -TestType Unit -GenerateReport
#>

[CmdletBinding()]
param(
    [ValidateSet('Unit', 'Integration', 'All')]
    [string]$TestType = 'All',
    [switch]$GenerateReport,
    [switch]$ShowCoverage
)

# Ensure Pester is available
if (-not (Get-Module -ListAvailable -Name Pester)) {
    Write-Host "❌ Pester module not found. Installing..." -ForegroundColor Red
    Install-Module -Name Pester -Force -SkipPublisherCheck
}

# Import Pester
Import-Module Pester -Force

# Test paths
$TestsPath = $PSScriptRoot
$UnitTestsPath = Join-Path $TestsPath "unit"
$IntegrationTestsPath = Join-Path $TestsPath "integration"
$ModulesPath = Join-Path (Split-Path $TestsPath) "modules"
$ReportsPath = Join-Path $TestsPath "reports"

# Ensure reports directory exists
if ($GenerateReport -and -not (Test-Path $ReportsPath)) {
    New-Item -ItemType Directory -Path $ReportsPath -Force | Out-Null
}

Write-Host "🧪 DevContainer Accelerator Test Suite" -ForegroundColor Blue
Write-Host "═══════════════════════════════════════" -ForegroundColor Blue

# Configure Pester
$PesterConfiguration = New-PesterConfiguration

# Set test paths based on test type
switch ($TestType) {
    'Unit' { 
        $PesterConfiguration.Run.Path = $UnitTestsPath
        Write-Host "🔬 Running Unit Tests..." -ForegroundColor Cyan
    }
    'Integration' { 
        $PesterConfiguration.Run.Path = $IntegrationTestsPath
        Write-Host "🔗 Running Integration Tests..." -ForegroundColor Cyan
    }
    'All' { 
        $PesterConfiguration.Run.Path = @($UnitTestsPath, $IntegrationTestsPath)
        Write-Host "🔬🔗 Running All Tests..." -ForegroundColor Cyan
    }
}

# Configure output
$PesterConfiguration.Output.Verbosity = 'Detailed'
$PesterConfiguration.Run.Exit = $false

# Configure code coverage if requested
if ($ShowCoverage) {
    $PesterConfiguration.CodeCoverage.Enabled = $true
    $PesterConfiguration.CodeCoverage.Path = @(
        (Join-Path $ModulesPath "*.psm1"),
        (Join-Path (Split-Path $TestsPath) "Initialize-DevContainer-New.ps1")
    )
    $PesterConfiguration.CodeCoverage.OutputFormat = 'JaCoCo'
    if ($GenerateReport) {
        $PesterConfiguration.CodeCoverage.OutputPath = Join-Path $ReportsPath "coverage.xml"
    }
}

# Configure test result output
if ($GenerateReport) {
    $PesterConfiguration.TestResult.Enabled = $true
    $PesterConfiguration.TestResult.OutputFormat = 'NUnitXml'
    $PesterConfiguration.TestResult.OutputPath = Join-Path $ReportsPath "test-results.xml"
}

# Run tests
try {
    $TestResults = Invoke-Pester -Configuration $PesterConfiguration
    
    # Display results summary
    Write-Host "`n📊 Test Results Summary:" -ForegroundColor Blue
    Write-Host "═══════════════════════" -ForegroundColor Blue
    Write-Host "✅ Passed: $($TestResults.PassedCount)" -ForegroundColor Green
    Write-Host "❌ Failed: $($TestResults.FailedCount)" -ForegroundColor Red
    Write-Host "⏭️  Skipped: $($TestResults.SkippedCount)" -ForegroundColor Yellow
    Write-Host "⏱️  Duration: $($TestResults.Duration.TotalSeconds) seconds" -ForegroundColor Gray
    
    # Show coverage if enabled
    if ($ShowCoverage -and $TestResults.CodeCoverage) {
        $CoveragePercent = [math]::Round(($TestResults.CodeCoverage.CommandsExecuted / $TestResults.CodeCoverage.CommandsAnalyzed) * 100, 2)
        Write-Host "📈 Code Coverage: $CoveragePercent%" -ForegroundColor Cyan
        Write-Host "   Commands Analyzed: $($TestResults.CodeCoverage.CommandsAnalyzed)" -ForegroundColor Gray
        Write-Host "   Commands Executed: $($TestResults.CodeCoverage.CommandsExecuted)" -ForegroundColor Gray
        Write-Host "   Commands Missed: $($TestResults.CodeCoverage.CommandsMissed)" -ForegroundColor Gray
    }
    
    # Report generation info
    if ($GenerateReport) {
        Write-Host "`n📄 Reports generated in: $ReportsPath" -ForegroundColor Blue
        if (Test-Path (Join-Path $ReportsPath "test-results.xml")) {
            Write-Host "   • Test Results: test-results.xml" -ForegroundColor Gray
        }
        if ($ShowCoverage -and (Test-Path (Join-Path $ReportsPath "coverage.xml"))) {
            Write-Host "   • Coverage Report: coverage.xml" -ForegroundColor Gray
        }
    }
    
    # Exit with appropriate code
    if ($TestResults.FailedCount -gt 0) {
        Write-Host "`n❌ Some tests failed. Please review the results above." -ForegroundColor Red
        exit 1
    } else {
        Write-Host "`n✅ All tests passed!" -ForegroundColor Green
        exit 0
    }
}
catch {
    Write-Host "`n❌ Test execution failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host $_.ScriptStackTrace -ForegroundColor Red
    exit 1
}
