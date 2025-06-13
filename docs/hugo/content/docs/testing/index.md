---
title: "Testing Framework"
linkTitle: "Testing"
weight: 3
description: >
  Learn about the modern Pester testing framework with 38 comprehensive tests and multiple execution modes.
---

# Testing Framework

The DevContainer template includes a comprehensive testing framework built on **Pester 5.0+** with 38 tests covering all aspects of the development environment.

## Overview

### Modern Testing Architecture

- **38 Comprehensive Tests** across 5 categories
- **Multiple Execution Modes**: Quick, Full, CI, and Watch
- **Tag-based Test Selection** for faster development cycles
- **Automatic Fallback** to legacy validation when Pester unavailable
- **CI/CD Ready** with structured XML output and exit codes

### Test Categories

| Category | Tests | Description |
|----------|-------|-------------|
| **Syntax** | 8 | PowerShell syntax and script validation |
| **Module** | 12 | DevContainer Accelerator module functionality |
| **Structure** | 6 | Repository structure and file organization |
| **Configuration** | 8 | DevContainer and tool configuration |
| **Integration** | 4 | End-to-end workflow validation |

## Test Execution Modes

### Quick Mode (Development)

Fast feedback for active development:

```powershell
# Run essential tests (typically completes in < 30 seconds)
.\tests\Test-DevContainer.ps1 -Mode Quick

# Run specific test categories
.\tests\Test-DevContainer.ps1 -Mode Quick -Tags "Syntax,Module"
```

**What it includes:**
- PowerShell syntax validation
- Core module functionality
- Basic structure checks

### Full Mode (Comprehensive)

Complete validation of all functionality:

```powershell
# Run all 38 tests with detailed output
.\tests\Test-DevContainer.ps1 -Mode Full

# Show detailed test results
.\tests\Test-DevContainer.ps1 -Mode Full -Detailed
```

**What it includes:**
- All Quick mode tests
- Configuration validation
- Integration testing
- Performance checks

### CI Mode (Automation)

Optimized for CI/CD pipelines:

```powershell
# Generate XML output and set exit codes
.\tests\Test-DevContainer.ps1 -Mode CI

# Check results
echo $LASTEXITCODE  # 0 = success, 1 = failure
```

**Features:**
- Structured XML output (`TestResults.xml`)
- Appropriate exit codes for automation
- Minimal console output
- JUnit-compatible results

### Watch Mode (Continuous)

Continuous testing during development:

```powershell
# Monitor files and re-run tests on changes
.\tests\Test-DevContainer.ps1 -Mode Watch

# Watch specific test tags
.\tests\Test-DevContainer.ps1 -Mode Watch -Tags "Syntax"
```

**Features:**
- File system monitoring
- Automatic test re-execution
- Filtered output for changed files

## Available Test Tags

Use tags to run specific subsets of tests:

```powershell
# PowerShell syntax validation
.\tests\Test-DevContainer.ps1 -Tags "Syntax"

# Module functionality
.\tests\Test-DevContainer.ps1 -Tags "Module"

# Repository structure
.\tests\Test-DevContainer.ps1 -Tags "Structure"

# Configuration validation
.\tests\Test-DevContainer.ps1 -Tags "Configuration"

# Integration testing
.\tests\Test-DevContainer.ps1 -Tags "Integration"

# Combine multiple tags
.\tests\Test-DevContainer.ps1 -Tags "Syntax,Module,Structure"
```

## Test Details

### Syntax Tests (8 tests)

Validates PowerShell scripts and modules:

- Script syntax validation
- Module import testing
- Function availability checks
- Parameter validation

### Module Tests (12 tests)

Tests the DevContainer Accelerator module:

- Module loading and functions
- Parameter validation
- Backend management functionality
- Azure integration capabilities

### Structure Tests (6 tests)

Ensures proper repository organization:

- Required directories and files
- DevContainer configuration
- Example completeness
- Documentation structure

### Configuration Tests (8 tests)

Validates tool and environment configuration:

- DevContainer settings
- Tool availability and versions
- Environment variable setup
- VS Code task configuration

### Integration Tests (4 tests)

End-to-end workflow validation:

- Complete project initialization
- Backend creation and management
- Tool chain integration
- Example execution

## VS Code Integration

The template includes VS Code tasks for easy test execution:

### Available Tasks

- **Test DevContainer (Quick)** - `Ctrl+Shift+P` → "Tasks: Run Task"
- **Test DevContainer (Full)** - Complete validation
- **Test DevContainer (CI)** - CI/CD mode
- **Test DevContainer (Watch)** - Continuous testing

### Running from Command Palette

1. Press `Ctrl+Shift+P`
2. Type "Tasks: Run Task"
3. Select your preferred test mode

### Keyboard Shortcuts (Optional)

Add to your `keybindings.json`:

```json
[
  {
    "key": "ctrl+shift+t",
    "command": "workbench.action.tasks.runTask",
    "args": "Test DevContainer (Quick)"
  }
]
```

## Legacy Compatibility

The framework maintains backward compatibility:

### Automatic Detection

```powershell
# The script automatically detects Pester availability
.\tests\Validate-DevContainer.ps1

# Falls back to legacy validation if Pester not available
```

### Manual Legacy Mode

```powershell
# Force legacy validation
.\tests\Validate-DevContainer.ps1 -ForceLegacy
```

## Customizing Tests

### Adding New Tests

Create new test files in the `tests/` directory:

```powershell
# tests/Custom.Tests.ps1
Describe "Custom Functionality" -Tags "Custom" {
    It "Should validate custom requirement" {
        # Your test logic
        $result | Should -Be $expected
    }
}
```

### Running Custom Tests

```powershell
# Run your custom tests
.\tests\Test-DevContainer.ps1 -Tags "Custom"
```

### Modifying Existing Tests

Edit `tests/DevContainer.Tests.ps1` to customize validation:

```powershell
# Find the test section and modify
Describe "Syntax Validation" -Tags "Syntax" {
    # Add your custom syntax checks
}
```

## Troubleshooting

### Common Issues

**Pester Not Found:**
```powershell
# Install Pester 5.0+
Install-Module -Name Pester -Force -SkipPublisherCheck
```

**Tests Fail in Container:**
```powershell
# Check PowerShell execution policy
Get-ExecutionPolicy
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**Performance Issues:**
```powershell
# Use Quick mode for faster feedback
.\tests\Test-DevContainer.ps1 -Mode Quick

# Or run specific test categories
.\tests\Test-DevContainer.ps1 -Tags "Syntax"
```

### Debug Mode

Enable verbose output for troubleshooting:

```powershell
# Run with verbose output
.\tests\Test-DevContainer.ps1 -Mode Full -Verbose

# Show detailed Pester output
.\tests\Test-DevContainer.ps1 -Mode Full -Detailed
```

## Best Practices

### During Development

1. **Use Quick Mode** for rapid feedback
2. **Run Full Mode** before commits
3. **Use Watch Mode** for continuous validation
4. **Tag Specific Tests** for focused testing

### In CI/CD

1. **Use CI Mode** for automation
2. **Check Exit Codes** for pipeline decisions
3. **Archive Test Results** (TestResults.xml)
4. **Set Timeouts** for long-running tests

### Performance Tips

1. **Filter by Tags** to reduce execution time
2. **Use Quick Mode** during active development
3. **Run Full Mode** periodically
4. **Monitor Resource Usage** in containers

For more troubleshooting help, see the [Troubleshooting Guide](/docs/troubleshooting/).
