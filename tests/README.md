# DevContainer Template Tests

This directory contains validation and testing scripts for the DevContainer template using modern Pester testing framework.

## Test Files

### DevContainer.Tests.ps1

Modern Pester-based test suite that provides comprehensive validation with structured test organization, better reporting, and CI/CD integration capabilities.

### Validate-DevContainer.ps1

Wrapper script that automatically detects and uses Pester when available, falling back to legacy validation for backward compatibility.

### Test-DevContainer.ps1

Quick test runner that provides common testing scenarios:
- **Quick tests** - Fast syntax and structure validation
- **Full tests** - Comprehensive test suite
- **CI mode** - Optimized for CI/CD pipelines
- **Watch mode** - Automatically re-run tests when files change

## Requirements

- **PowerShell 5.1+** or **PowerShell Core 7.0+**
- **Pester 5.0+** (recommended for best experience)

Install Pester if not available:
```powershell
Install-Module Pester -Force -Scope CurrentUser
```

## Usage

### Quick Start with Test Runner (Easiest)

```powershell
# Quick validation (recommended for development)
.\tests\Test-DevContainer.ps1

# Full comprehensive tests
.\tests\Test-DevContainer.ps1 -Full

# CI/CD pipeline mode with XML output
.\tests\Test-DevContainer.ps1 -CI

# Watch mode (auto-run tests on file changes)
.\tests\Test-DevContainer.ps1 -Watch
```

### Using the Wrapper Script (Recommended)

```powershell
# Run all validation tests with Pester
.\tests\Validate-DevContainer.ps1

# Run specific test categories
.\tests\Validate-DevContainer.ps1 -SyntaxOnly
.\tests\Validate-DevContainer.ps1 -ModuleOnly

# Run in quiet mode
.\tests\Validate-DevContainer.ps1 -Quiet

# Generate test results file
.\tests\Validate-DevContainer.ps1 -OutputFile "TestResults.xml"

# Control output detail level
.\tests\Validate-DevContainer.ps1 -OutputDetail "Detailed"
```

### Using Pester Directly (Advanced)

```powershell
# Run all tests
Invoke-Pester -Path .\tests\DevContainer.Tests.ps1

# Run specific test categories using tags
Invoke-Pester -Path .\tests\DevContainer.Tests.ps1 -Tag "Syntax"
Invoke-Pester -Path .\tests\DevContainer.Tests.ps1 -Tag "Module"
Invoke-Pester -Path .\tests\DevContainer.Tests.ps1 -Tag "Structure"

# Run with detailed output
Invoke-Pester -Path .\tests\DevContainer.Tests.ps1 -Output Detailed

# Generate test results for CI/CD
$config = New-PesterConfiguration
$config.Run.Path = ".\tests\DevContainer.Tests.ps1"
$config.TestResult.Enabled = $true
$config.TestResult.OutputPath = "TestResults.xml"
Invoke-Pester -Configuration $config
```

## Test Categories and Tags

The Pester tests are organized with the following tags for selective execution:

### Syntax (`-Tag "Syntax"`)
- Parse `Initialize-DevContainer.ps1` for syntax errors
- Parse `Initialize-DevContainer.ps1` for syntax errors
- Parse individual module files for syntax errors
- Test script conversion to ScriptBlock

### Module (`-Tag "Module"`)
- Import PowerShell module
- Verify function exports
- Test module manifest
- Test helper function functionality (if available)

### Structure (`-Tag "Structure"`)
- Verify core files exist
- Check DevContainer configuration files
- Validate module files
- Verify example directories and files
- Check test directory structure

### Configuration (`-Tag "Configuration"`)
- Validate DevContainer JSON configuration
- Check script file permissions
- Verify configuration file syntax

### Integration (`-Tag "Integration"`)
- End-to-end validation of all PowerShell files
- Cross-file consistency checks
- Line ending consistency validation

## CI/CD Integration

The Pester tests support CI/CD integration through:

- **NUnit XML output** for test result reporting
- **Structured exit codes** (0 = success, 1 = failure)
- **Tag-based test selection** for different pipeline stages
- **Configurable output verbosity** for build logs

Example GitHub Actions integration:
```yaml
- name: Run DevContainer Tests
  shell: pwsh
  run: |
    .\tests\Validate-DevContainer.ps1 -OutputFile "TestResults.xml" -OutputDetail "Normal"
    
- name: Publish Test Results
  uses: dorny/test-reporter@v1
  if: always()
  with:
    name: DevContainer Tests
    path: TestResults.xml
    reporter: dotnet-trx
```

## Legacy Support

If Pester 5.0+ is not available, the validation script automatically falls back to the original validation method while maintaining the same command-line interface.

## Exit Codes

- `0` - All tests passed
- `1` - One or more tests failed

## Troubleshooting

### Pester Not Found
```
Install-Module Pester -Force -Scope CurrentUser -MinimumVersion 5.0
```

### Permission Issues
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Module Import Issues
Ensure you're running from the correct directory (repository root) or specify the full path to the test files.
