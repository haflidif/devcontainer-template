# DevContainer Template Validation Script
# This script performs comprehensive validation of the DevContainer template using Pester

#Requires -Modules Pester

[CmdletBinding()]
param(
    [Parameter(HelpMessage = "Run syntax validation only")]
    [switch]$SyntaxOnly,
    
    [Parameter(HelpMessage = "Run module validation only")]
    [switch]$ModuleOnly,
    
    [Parameter(HelpMessage = "Run all validation tests (default)")]
    [switch]$Full,
    
    [Parameter(HelpMessage = "Run in quiet mode (minimal output)")]
    [switch]$Quiet,
    
    [Parameter(HelpMessage = "Pester output detail level")]
    [ValidateSet("None", "Minimal", "Normal", "Detailed", "Diagnostic")]
    [string]$OutputDetail = "Normal",
    
    [Parameter(HelpMessage = "Generate Pester test results in NUnit XML format")]
    [string]$OutputFile,
    
    [Parameter(HelpMessage = "Show legacy format output (maintains backward compatibility)")]
    [switch]$LegacyOutput
)

# Default to full validation if no specific test is selected
if (-not $SyntaxOnly -and -not $ModuleOnly) {
    $Full = $true
}

# Check if Pester is available
try {
    Import-Module Pester -MinimumVersion 5.0 -ErrorAction Stop
    $PesterAvailable = $true
} catch {
    Write-Warning "Pester 5.0+ is not available. Falling back to legacy validation method."
    Write-Warning "To get the best testing experience, install Pester 5.0+: Install-Module Pester -Force"
    $PesterAvailable = $false
}

# Get the root directory (parent of tests)
$RootPath = Split-Path $PSScriptRoot -Parent

if ($PesterAvailable) {
    # Use modern Pester-based testing
    Write-Host "🧪 Running DevContainer Template Validation with Pester" -ForegroundColor Magenta
    Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Magenta
    
    # Build Pester configuration
    $PesterConfig = New-PesterConfiguration
    $PesterConfig.Run.Path = Join-Path $PSScriptRoot "DevContainer.Tests.ps1"
    $PesterConfig.Output.Verbosity = if ($Quiet) { "Minimal" } else { $OutputDetail }
    
    # Set tags based on parameters
    $tags = @()
    if ($SyntaxOnly) { $tags += "Syntax" }
    if ($ModuleOnly) { $tags += "Module" }
    if ($Full) { $tags += @("Syntax", "Module", "Structure", "Configuration", "Integration") }
    
    if ($tags.Count -gt 0) {
        $PesterConfig.Filter.Tag = $tags
    }
    
    # Set output file if specified
    if ($OutputFile) {
        $PesterConfig.TestResult.Enabled = $true
        $PesterConfig.TestResult.OutputPath = $OutputFile
        $PesterConfig.TestResult.OutputFormat = "NUnitXml"
    }
    
    # Run Pester tests
    $TestResults = Invoke-Pester -Configuration $PesterConfig
    
    # Display results summary
    if (-not $Quiet) {
        Write-Host "`n📊 Test Results Summary" -ForegroundColor Yellow
        Write-Host "══════════════════════" -ForegroundColor Yellow
        Write-Host "Total Tests: $($TestResults.TotalCount)" -ForegroundColor White
        Write-Host "Passed: $($TestResults.PassedCount)" -ForegroundColor Green
        Write-Host "Failed: $($TestResults.FailedCount)" -ForegroundColor Red
        Write-Host "Skipped: $($TestResults.SkippedCount)" -ForegroundColor Yellow
        
        if ($TestResults.FailedCount -eq 0) {
            Write-Host "`n🎉 All tests passed! The DevContainer template is ready for use." -ForegroundColor Green
        } else {
            Write-Host "`n⚠️  Some tests failed. Please review the detailed output above." -ForegroundColor Yellow
        }
    }
    
    # Return exit code based on results
    if ($TestResults.FailedCount -gt 0) {
        exit 1
    } else {
        exit 0
    }
} else {
    # Fall back to legacy validation method
    Write-Host "🧪 DevContainer Template Validation (Legacy Mode)" -ForegroundColor Magenta
    Write-Host "═══════════════════════════════════════════════════" -ForegroundColor Magenta

    # Legacy validation code follows (keeping for backward compatibility)
    
    # Initialize results
    $script:TestResults = @{
        Passed = 0
        Failed = 0
        Tests = @()
    }

function Write-TestResult {
    param(
        [string]$TestName,
        [bool]$Passed,
        [string]$Details = "",
        [string]$ErrorMessage = ""
    )
    
    $script:TestResults.Tests += [PSCustomObject]@{
        Name = $TestName
        Passed = $Passed
        Details = $Details
        Error = $ErrorMessage
    }
    
    if ($Passed) {
        $script:TestResults.Passed++
        if (-not $Quiet) { Write-Host "  ✅ $TestName" -ForegroundColor Green }
        if ($Details -and -not $Quiet) { Write-Host "     $Details" -ForegroundColor Gray }
    } else {
        $script:TestResults.Failed++
        Write-Host "  ❌ $TestName" -ForegroundColor Red
        if ($ErrorMessage) { Write-Host "     Error: $ErrorMessage" -ForegroundColor DarkRed }
    }
}

function Test-PowerShellSyntax {
    if (-not $Quiet) { Write-Host "`n🔍 Testing PowerShell Syntax..." -ForegroundColor Cyan }
    
    # Test Initialize-DevContainer.ps1 syntax.
    try {
        $errors = $null
        $tokens = $null
        $scriptPath = Join-Path $RootPath "Initialize-DevContainer.ps1"
        $null = [System.Management.Automation.Language.Parser]::ParseFile(
            $scriptPath, 
            [ref]$tokens, 
            [ref]$errors
        )
        
        if ($errors.Count -eq 0) {
            Write-TestResult "Initialize-DevContainer.ps1 syntax" $true "No parse errors"
        } else {
            $errorMessages = ($errors | ForEach-Object { $_.Message }) -join "; "
            Write-TestResult "Initialize-DevContainer.ps1 syntax" $false "" $errorMessages
        }
            
    } catch {
        Write-TestResult "Initialize-DevContainer.ps1 syntax" $false "" $_.Exception.Message
    }
    
    # Test DevContainerAccelerator module syntax
    try {
        $errors = $null
        $tokens = $null
        $modulePath = Join-Path $RootPath "DevContainerAccelerator\DevContainerAccelerator.psm1"
        $null = [System.Management.Automation.Language.Parser]::ParseFile(
            $modulePath, 
            [ref]$tokens, 
            [ref]$errors
        )
        
        if ($errors.Count -eq 0) {
            Write-TestResult "DevContainerAccelerator.psm1 syntax" $true "No parse errors"
        } else {
            $errorMessages = ($errors | ForEach-Object { $_.Message }) -join "; "
            Write-TestResult "DevContainerAccelerator.psm1 syntax" $false "" $errorMessages
        }
            
    } catch {
        Write-TestResult "DevContainerAccelerator.psm1 syntax" $false "" $_.Exception.Message
    }
    
    # Test script conversion to ScriptBlock
    try {
        $scriptPath = Join-Path $RootPath "Initialize-DevContainer.ps1"
        $scriptContent = Get-Content $scriptPath -Raw
        $null = [ScriptBlock]::Create($scriptContent)
        Write-TestResult "Script to ScriptBlock conversion" $true "Can be converted successfully"
    } catch {
        Write-TestResult "Script to ScriptBlock conversion" $false "" $_.Exception.Message
    }
}

function Test-ModuleFunctionality {
    if (-not $Quiet) { Write-Host "`n📦 Testing Module Functionality..." -ForegroundColor Cyan }
    
    # Test module import
    try {
        $modulePath = Join-Path $RootPath "DevContainerAccelerator\DevContainerAccelerator.psm1"
        Import-Module $modulePath -Force
        Write-TestResult "Module import" $true "Imported successfully"
        
        # Test function exports
        $functions = Get-Command -Module DevContainerAccelerator -ErrorAction SilentlyContinue
        if ($functions.Count -gt 0) {
            Write-TestResult "Function exports" $true "$($functions.Count) functions exported"
            if (-not $Quiet) {
                $functions | ForEach-Object { 
                    Write-Host "     - $($_.Name)" -ForegroundColor DarkGray 
                }
            }
        } else {
            Write-TestResult "Function exports" $false "" "No functions found"
        }
        
        # Test specific helper functions
        if (Get-Command Test-IsGuid -ErrorAction SilentlyContinue) {
            $validResult = Test-IsGuid -InputString "123e4567-e89b-12d3-a456-426614174000"
            $invalidResult = Test-IsGuid -InputString "invalid-guid"
            
            Write-TestResult "GUID validation function" ($validResult -and -not $invalidResult) `
                "Valid GUID: $validResult, Invalid GUID: $invalidResult"
        }
        
        if (Get-Command Write-ColorOutput -ErrorAction SilentlyContinue) {
            Write-TestResult "Write-ColorOutput function" $true "Function available"
        }
        
    } catch {
        Write-TestResult "Module import" $false "" $_.Exception.Message
    }
}

function Test-FileStructure {
    if (-not $Quiet) { Write-Host "`n📁 Testing File Structure..." -ForegroundColor Cyan }
    
    # Core files
    $coreFiles = @(
        @{ Path = "Initialize-DevContainer.ps1"; Required = $true },
        @{ Path = "Install-DevContainerAccelerator.ps1"; Required = $true },
        @{ Path = "README.md"; Required = $true },
        @{ Path = ".devcontainer\devcontainer.json"; Required = $true },
        @{ Path = ".devcontainer\Dockerfile"; Required = $true },
        @{ Path = ".devcontainer\devcontainer.env.example"; Required = $true },
        @{ Path = ".devcontainer\scripts"; Required = $true }
    )
    
    foreach ($file in $coreFiles) {
        $fullPath = Join-Path $RootPath $file.Path
        $exists = Test-Path $fullPath
        $status = if ($exists) { "Found" } else { "Missing" }
        Write-TestResult "File: $($file.Path)" $exists $status
    }
    
    # Test module files
    $moduleFiles = @("DevContainerAccelerator.psd1", "DevContainerAccelerator.psm1")
    foreach ($file in $moduleFiles) {
        $fullPath = Join-Path $RootPath "DevContainerAccelerator\$file"
        $exists = Test-Path $fullPath
        $status = if ($exists) { "Found" } else { "Missing" }
        Write-TestResult "Module file: $file" $exists $status
    }
    
    # Test example files
    $exampleDirs = @("getting-started", "terraform", "bicep", "arm", "powershell", "configuration")
    foreach ($dir in $exampleDirs) {
        $fullPath = Join-Path $RootPath "examples\$dir"
        $exists = Test-Path $fullPath
        $status = if ($exists) { "Directory found" } else { "Directory missing" }
        Write-TestResult "Example directory: $dir" $exists $status
    }
}

# Main execution
if (-not $Quiet) {
    Write-Host "🧪 DevContainer Template Validation" -ForegroundColor Magenta
    Write-Host "════════════════════════════════════" -ForegroundColor Magenta
}

# Run tests based on parameters
if ($Full -or $SyntaxOnly) {
    Test-PowerShellSyntax
}

if ($Full -or $ModuleOnly) {
    Test-ModuleFunctionality
}

if ($Full) {
    Test-FileStructure
}

# Display results
if (-not $Quiet) {
    Write-Host "`n📊 Validation Results" -ForegroundColor Yellow
    Write-Host "═══════════════════════" -ForegroundColor Yellow
    Write-Host "Tests Run: $($script:TestResults.Tests.Count)" -ForegroundColor White
    Write-Host "Passed: $($script:TestResults.Passed)" -ForegroundColor Green
    Write-Host "Failed: $($script:TestResults.Failed)" -ForegroundColor Red
    
    if ($script:TestResults.Failed -eq 0) {
        Write-Host "`n🎉 All tests passed! The DevContainer template is ready for use." -ForegroundColor Green
    } else {
        Write-Host "`n⚠️  Some tests failed. Please review the issues above." -ForegroundColor Yellow
        
        # Show failed tests
        $failedTests = $script:TestResults.Tests | Where-Object { -not $_.Passed }
        if ($failedTests) {
            Write-Host "`nFailed Tests:" -ForegroundColor Red
            foreach ($test in $failedTests) {
                Write-Host "  - $($test.Name): $($test.Error)" -ForegroundColor DarkRed
            }
        }
    }
}

# Return exit code based on results
if ($script:TestResults.Failed -gt 0) {
    exit 1
} else {
    exit 0
}
}
