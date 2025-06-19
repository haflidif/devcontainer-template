---
title: "Testing"
linkTitle: "Testing"
weight: 3
description: >
  Comprehensive testing framework using Pester for validation, security scanning, and quality assurance.
---

# Testing Framework

The DevContainer template includes a comprehensive testing framework built on Pester 5.0+ with modular test organization and CI/CD integration.

## Overview

The testing framework provides:

- **Unit Tests** - Test individual functions and modules
- **Integration Tests** - Test complete workflows and interactions
- **Security Tests** - Validate security configurations and compliance
- **Performance Tests** - Monitor execution times and resource usage
- **Syntax Tests** - Validate PowerShell, Terraform, and Bicep syntax

## Quick Testing

### Run All Tests

```powershell
# Run comprehensive test suite
.\tests\Run-Tests.ps1

# Run with detailed output
.\tests\Run-Tests.ps1 -Verbose

# Run specific test categories
.\tests\Run-Tests.ps1 -Tags "Unit,Integration"
```

### Quick Validation

```powershell
# Fast validation (< 30 seconds)
.\tests\Test-DevContainer.ps1 -Mode Quick

# Comprehensive validation (full test suite)
.\tests\Test-DevContainer.ps1 -Mode Comprehensive
```

## Test Organization

### Directory Structure

```
tests/
├── Run-Tests.ps1              # Main test runner
├── Test-DevContainer.ps1      # Quick validation script
├── Config.ps1                 # Test configuration
├── unit/                      # Unit tests
│   ├── CommonModule.Tests.ps1
│   ├── AzureModule.Tests.ps1
│   └── DevContainerModule.Tests.ps1
├── integration/               # Integration tests
│   ├── Initialize-DevContainer.Tests.ps1
│   ├── End-to-End.Tests.ps1
│   └── Workflow.Tests.ps1
├── security/                  # Security tests
│   ├── TFSec.Tests.ps1
│   ├── Checkov.Tests.ps1
│   └── PSRule.Tests.ps1
└── performance/               # Performance tests
    ├── Benchmarks.Tests.ps1
    └── LoadTesting.Tests.ps1
```

### Test Categories

Tests are organized using Pester tags:

- `Unit` - Individual function testing
- `Integration` - Workflow and interaction testing
- `Security` - Security and compliance validation
- `Performance` - Performance and benchmarking
- `Syntax` - Code syntax validation
- `Module` - PowerShell module testing
- `E2E` - End-to-end testing
- `Quick` - Fast validation tests
- `Slow` - Long-running tests

## Unit Testing

### Testing PowerShell Modules

Example unit test for the CommonModule:

```powershell
Describe "CommonModule Tests" -Tags @("Unit", "Module", "Quick") {
    BeforeAll {
        Import-Module "$PSScriptRoot\..\modules\CommonModule.psm1" -Force
    }

    Context "Test-Prerequisites" {
        It "Should return true when all prerequisites are met" {
            # Mock external dependencies
            Mock Get-Command { return $true } -ParameterFilter { $Name -eq "git" }
            Mock Get-Command { return $true } -ParameterFilter { $Name -eq "docker" }
            
            Test-Prerequisites | Should -Be $true
        }

        It "Should return false when prerequisites are missing" {
            Mock Get-Command { return $false } -ParameterFilter { $Name -eq "git" }
            
            Test-Prerequisites | Should -Be $false
        }
    }

    Context "Initialize-ProjectDirectory" {
        It "Should create project directory structure" {
            $testPath = Join-Path $TestDrive "test-project"
            
            Initialize-ProjectDirectory -ProjectName "test-project" -ProjectPath $testPath
            
            $testPath | Should -Exist
            Join-Path $testPath ".devcontainer" | Should -Exist
        }
    }
}
```

### Testing Azure Module

```powershell
Describe "AzureModule Tests" -Tags @("Unit", "Module", "Azure") {
    BeforeAll {
        Import-Module "$PSScriptRoot\..\modules\AzureModule.psm1" -Force
        
        # Mock Azure CLI commands
        Mock az { return '{"value": [{"id": "test-subscription"}]}' } -ParameterFilter { 
            $args -contains "account" -and $args -contains "list" 
        }
    }

    Context "Test-AzureConnection" {
        It "Should validate Azure authentication" {
            Test-AzureConnection | Should -Be $true
        }
    }

    Context "New-AzureResourceGroup" {
        It "Should create resource group with correct naming" {
            Mock az { return '{"id": "/subscriptions/test/resourceGroups/rg-test-dev"}' }
            
            $result = New-AzureResourceGroup -Name "test" -Location "eastus" -Environment "dev"
            
            $result.Name | Should -Match "rg-test-dev"
        }
    }
}
```

## Integration Testing

### End-to-End Workflow Testing

```powershell
Describe "DevContainer Initialization E2E" -Tags @("Integration", "E2E", "Slow") {
    BeforeAll {
        $testProjectPath = Join-Path $TestDrive "e2e-test-project"
        $originalLocation = Get-Location
    }

    AfterAll {
        Set-Location $originalLocation
        if (Test-Path $testProjectPath) {
            Remove-Item $testProjectPath -Recurse -Force
        }
    }

    It "Should initialize complete DevContainer project" {
        # Test full initialization workflow
        .\Initialize-DevContainer.ps1 -ProjectName "e2e-test" `
                                     -ProjectPath $testProjectPath `
                                     -ProjectType "terraform" `
                                     -WhatIf

        # Verify project structure
        Join-Path $testProjectPath ".devcontainer" | Should -Exist
        Join-Path $testProjectPath "terraform" | Should -Exist
        Join-Path $testProjectPath "tests" | Should -Exist
    }

    It "Should pass all validation tests" {
        Set-Location $testProjectPath
        
        $result = .\tests\Test-DevContainer.ps1 -Mode Quick
        
        $result.Success | Should -Be $true
        $result.FailedTests | Should -HaveCount 0
    }
}
```

## Security Testing

### Infrastructure Security Validation

```powershell
Describe "Security Scanning" -Tags @("Security", "Compliance") {
    Context "TFSec Validation" {
        It "Should pass TFSec security checks" {
            if (Test-Path "terraform") {
                $result = & tfsec terraform --format json | ConvertFrom-Json
                $highSeverityIssues = $result.results | Where-Object { $_.severity -eq "HIGH" }
                
                $highSeverityIssues | Should -HaveCount 0
            }
        }
    }

    Context "Checkov Validation" {
        It "Should pass Checkov compliance checks" {
            if (Test-Path "terraform") {
                $result = & checkov -d terraform --framework terraform --output json | ConvertFrom-Json
                $failedChecks = $result.summary.failed
                
                $failedChecks | Should -BeLessOrEqual 0
            }
        }
    }

    Context "PSRule Validation" {
        It "Should pass PowerShell rule validation" {
            if (Get-Module PSRule.Rules.Azure -ListAvailable) {
                $result = Invoke-PSRule -InputPath . -Format File
                $failedRules = $result | Where-Object { $_.Outcome -eq "Fail" }
                
                $failedRules | Should -HaveCount 0
            }
        }
    }
}
```

## Performance Testing

### Benchmark Testing

```powershell
Describe "Performance Benchmarks" -Tags @("Performance", "Benchmark") {
    Context "Initialization Performance" {
        It "Should initialize project within acceptable time" {
            $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
            
            .\Initialize-DevContainer.ps1 -ProjectName "perf-test" `
                                         -ProjectType "terraform" `
                                         -WhatIf
            
            $stopwatch.Stop()
            $stopwatch.ElapsedSeconds | Should -BeLessOrEqual 30
        }
    }

    Context "Test Execution Performance" {
        It "Should run quick tests within time limit" {
            $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
            
            .\tests\Test-DevContainer.ps1 -Mode Quick
            
            $stopwatch.Stop()
            $stopwatch.ElapsedSeconds | Should -BeLessOrEqual 60
        }
    }
}
```

## Test Configuration

### Test Settings

Configure test behavior in `tests\Config.ps1`:

```powershell
# Test execution configuration
$TestConfig = @{
    # Coverage settings
    EnableCoverage = $true
    CoverageThreshold = 80
    CoverageOutputPath = "TestResults\Coverage"
    
    # Output settings
    OutputFormat = "NUnitXml"
    OutputPath = "TestResults\TestResults.xml"
    JUnitOutputPath = "TestResults\JUnit.xml"
    
    # Test execution
    StrictMode = $true
    FailOnFirstError = $false
    MaxParallelJobs = 4
    
    # Test categories
    QuickTests = @("Unit", "Quick", "Syntax")
    ComprehensiveTests = @("Unit", "Integration", "Security")
    CITests = @("Unit", "Integration", "Security", "Performance")
}
```

## CI/CD Integration

### GitHub Actions Integration

Example workflow configuration:

```yaml
name: Test DevContainer

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Setup PowerShell
      uses: azure/powershell@v1
      with:
        pwsh: true
    
    - name: Install Pester
      shell: pwsh
      run: Install-Module -Name Pester -Force -SkipPublisherCheck
    
    - name: Run Tests
      shell: pwsh
      run: |
        .\tests\Run-Tests.ps1 -Tags "Unit,Integration" `
                             -OutputFormat "NUnitXml" `
                             -OutputFile "TestResults.xml"
    
    - name: Publish Test Results
      uses: dorny/test-reporter@v1
      if: always()
      with:
        name: Test Results
        path: TestResults.xml
        reporter: dotnet-trx
```

### Azure DevOps Integration

```yaml
trigger:
- main
- develop

pool:
  vmImage: 'ubuntu-latest'

steps:
- task: PowerShell@2
  displayName: 'Install Pester'
  inputs:
    targetType: 'inline'
    script: 'Install-Module -Name Pester -Force -SkipPublisherCheck'

- task: PowerShell@2
  displayName: 'Run Tests'
  inputs:
    targetType: 'filePath'
    filePath: 'tests/Run-Tests.ps1'
    arguments: '-Tags "Unit,Integration" -OutputFormat "NUnitXml" -OutputFile "TestResults.xml"'

- task: PublishTestResults@2
  displayName: 'Publish Test Results'
  inputs:
    testResultsFormat: 'NUnit'
    testResultsFiles: 'TestResults.xml'
```

## Test Utilities

### Helper Functions

Common test utilities in `tests\TestHelpers.psm1`:

```powershell
function New-TestProject {
    param([string]$Name, [string]$Type = "terraform")
    
    $testPath = Join-Path $TestDrive $Name
    New-Item -Path $testPath -ItemType Directory -Force
    
    # Create minimal project structure for testing
    $devcontainerPath = Join-Path $testPath ".devcontainer"
    New-Item -Path $devcontainerPath -ItemType Directory -Force
    
    return $testPath
}

function Assert-ProjectStructure {
    param([string]$ProjectPath, [string]$ProjectType)
    
    $requiredPaths = @(
        ".devcontainer",
        "tests",
        $ProjectType
    )
    
    foreach ($path in $requiredPaths) {
        $fullPath = Join-Path $ProjectPath $path
        $fullPath | Should -Exist -Because "Required path $path should exist"
    }
}
```

## Troubleshooting Tests

### Common Test Issues

1. **Pester Version Conflicts**:
   ```powershell
   # Remove old Pester versions
   Get-Module Pester -ListAvailable | Remove-Module -Force
   Install-Module Pester -Force -SkipPublisherCheck
   ```

2. **Module Import Issues**:
   ```powershell
   # Force reload modules
   Get-Module CommonModule,AzureModule,DevContainerModule | Remove-Module -Force
   Import-Module .\modules\*.psm1 -Force
   ```

3. **Azure Authentication in Tests**:
   ```powershell
   # Use service principal for CI/CD
   az login --service-principal -u $env:AZURE_CLIENT_ID -p $env:AZURE_CLIENT_SECRET --tenant $env:AZURE_TENANT_ID
   ```

For more testing guidance, check the [examples](../examples/) and [troubleshooting guide](../troubleshooting/).

## Next Steps

- Explore [Configuration Options](../configuration/)
- Check out [Examples](../examples/)  
- Learn about [PowerShell Modules](../powershell/)
