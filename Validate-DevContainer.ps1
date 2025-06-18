#Requires -Version 5.1

<#
.SYNOPSIS
    Validates DevContainer template modules and script integrity.

.DESCRIPTION
    Performs basic validation checks on all modules and the main script
    to ensure they can be loaded without errors.
#>

Write-Host "🔍 DevContainer Template Validation" -ForegroundColor Blue
Write-Host "════════════════════════════════════════" -ForegroundColor Blue

$ErrorCount = 0
$ModulesPath = Join-Path $PSScriptRoot "modules"
$MainScript = Join-Path $PSScriptRoot "Initialize-DevContainer.ps1"

# Test 1: Check if modules directory exists
Write-Host "`n📁 Checking modules directory..." -ForegroundColor Cyan
if (Test-Path $ModulesPath) {
    Write-Host "✅ Modules directory found: $ModulesPath" -ForegroundColor Green
} else {
    Write-Host "❌ Modules directory not found: $ModulesPath" -ForegroundColor Red
    $ErrorCount++
}

# Test 2: Check if all required module files exist
$RequiredModules = @(
    "CommonModule.psm1",
    "AzureModule.psm1",
    "InteractiveModule.psm1",
    "DevContainerModule.psm1",
    "ProjectModule.psm1"
)

Write-Host "`n📋 Checking module files..." -ForegroundColor Cyan
foreach ($module in $RequiredModules) {
    $modulePath = Join-Path $ModulesPath $module
    if (Test-Path $modulePath) {
        Write-Host "✅ $module" -ForegroundColor Green
    } else {
        Write-Host "❌ $module - NOT FOUND" -ForegroundColor Red
        $ErrorCount++
    }
}

# Test 3: Try to import each module
Write-Host "`n🔧 Testing module imports..." -ForegroundColor Cyan
foreach ($module in $RequiredModules) {
    $modulePath = Join-Path $ModulesPath $module
    if (Test-Path $modulePath) {
        try {
            Import-Module $modulePath -Force -ErrorAction Stop
            Write-Host "✅ $module imported successfully" -ForegroundColor Green
            Remove-Module (Split-Path $modulePath -LeafBase) -Force -ErrorAction SilentlyContinue
        }
        catch {
            Write-Host "❌ $module failed to import: $($_.Exception.Message)" -ForegroundColor Red
            $ErrorCount++
        }
    }
}

# Test 4: Check main script syntax
Write-Host "`n📜 Checking main script syntax..." -ForegroundColor Cyan
if (Test-Path $MainScript) {
    try {
        $null = [System.Management.Automation.PSParser]::Tokenize((Get-Content $MainScript -Raw), [ref]$null)
        Write-Host "✅ Main script syntax is valid" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ Main script has syntax errors: $($_.Exception.Message)" -ForegroundColor Red
        $ErrorCount++
    }
} else {
    Write-Host "❌ Main script not found: $MainScript" -ForegroundColor Red
    $ErrorCount++
}

# Test 5: Try to load main script (dry run)
Write-Host "`n🚀 Testing main script module loading..." -ForegroundColor Cyan
try {
    # Test the module import section by running just that part
    $ModulesPathTest = Join-Path $PSScriptRoot "modules"
    
    # Check if modules directory exists
    if (-not (Test-Path $ModulesPathTest)) {
        throw "Modules directory not found at: $ModulesPathTest"
    }
    
    # Import modules in order
    $moduleFiles = @(
        "CommonModule.psm1",
        "AzureModule.psm1", 
        "InteractiveModule.psm1",
        "DevContainerModule.psm1",
        "ProjectModule.psm1"
    )
    
    foreach ($moduleFile in $moduleFiles) {
        $modulePathTest = Join-Path $ModulesPathTest $moduleFile
        if (-not (Test-Path $modulePathTest)) {
            throw "Module not found: $modulePathTest"
        }
        Import-Module -Name $modulePathTest -Force
    }
    
    Write-Host "✅ Main script module loading works correctly" -ForegroundColor Green
    
    # Clean up imported modules
    foreach ($moduleFile in $moduleFiles) {
        $moduleName = [System.IO.Path]::GetFileNameWithoutExtension($moduleFile)
        Remove-Module $moduleName -Force -ErrorAction SilentlyContinue
    }
}
catch {
    Write-Host "❌ Main script module loading failed: $($_.Exception.Message)" -ForegroundColor Red
    $ErrorCount++
}

# Test 6: Validate function exports
Write-Host "`n🔗 Checking function exports..." -ForegroundColor Cyan
$ExpectedExports = @{
    "CommonModule" = @("Write-ColorOutput", "Test-IsGuid", "Test-Prerequisites", "Show-NextSteps")
    "AzureModule" = @("Test-AzureAuthentication", "Test-AzureStorageAccount", "New-AzureStorageAccountName", "New-AzureTerraformBackend", "Test-TerraformBackend")
    "InteractiveModule" = @("Get-InteractiveInput", "Get-BackendConfiguration")
    "DevContainerModule" = @("Initialize-ProjectDirectory", "Copy-DevContainerFiles", "New-DevContainerEnv")
    "ProjectModule" = @("Add-ExampleFiles")
}

foreach ($moduleName in $ExpectedExports.Keys) {
    $modulePath = Join-Path $ModulesPath "$moduleName.psm1"
    if (Test-Path $modulePath) {
        try {
            Import-Module $modulePath -Force
            $exportedFunctions = (Get-Module $moduleName).ExportedFunctions.Keys
            
            foreach ($expectedFunction in $ExpectedExports[$moduleName]) {
                if ($exportedFunctions -contains $expectedFunction) {
                    Write-Host "✅ $moduleName exports $expectedFunction" -ForegroundColor Green
                } else {
                    Write-Host "❌ $moduleName missing export: $expectedFunction" -ForegroundColor Red
                    $ErrorCount++
                }
            }
            
            Remove-Module $moduleName -Force -ErrorAction SilentlyContinue
        }
        catch {
            Write-Host "❌ Failed to test exports for $moduleName : $($_.Exception.Message)" -ForegroundColor Red
            $ErrorCount++
        }
    }
}

# Final summary
Write-Host "`n📊 Validation Summary:" -ForegroundColor Blue
Write-Host "════════════════════════" -ForegroundColor Blue

if ($ErrorCount -eq 0) {
    Write-Host "✅ All validation checks passed!" -ForegroundColor Green
    Write-Host "🚀 DevContainer Template is ready to use." -ForegroundColor Green
    exit 0
} else {
    Write-Host "❌ $ErrorCount validation error(s) found." -ForegroundColor Red
    Write-Host "🔧 Please fix the issues above before using the script." -ForegroundColor Yellow
    exit 1
}
