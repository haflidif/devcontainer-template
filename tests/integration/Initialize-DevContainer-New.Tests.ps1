#Requires -Modules Pester

BeforeAll {
    # Test paths - Use more robust path resolution for CI environments
    $testDir = if ($PSScriptRoot) { 
        $PSScriptRoot 
    } else { 
        Split-Path -Parent $MyInvocation.MyCommand.Path 
    }
    
    $script:ScriptPath = Join-Path (Split-Path (Split-Path $testDir -Parent) -Parent) "Initialize-DevContainer.ps1"
    $script:TestProjectPath = Join-Path ([System.IO.Path]::GetTempPath()) "DevContainerTest-$(Get-Random)"
    
    # Validate that the script exists
    if (-not (Test-Path $script:ScriptPath)) {
        throw "Initialize-DevContainer.ps1 not found at: $script:ScriptPath"
    }
    
    # Ensure test project directory doesn't exist
    if (Test-Path $script:TestProjectPath) {
        Remove-Item $script:TestProjectPath -Recurse -Force
    }
}

Describe "Initialize-DevContainer Integration Tests" {
    Context "Module Import" {
        It "Should import all required modules without error" {
            # Test that the script can load without throwing errors by providing valid parameters
            { & $script:ScriptPath -TenantId "12345678-1234-1234-1234-123456789012" -SubscriptionId "87654321-4321-4321-4321-210987654321" -ProjectName "test" -WhatIf } | Should -Not -Throw
        }
    }
    
    Context "Parameter Validation" {
        It "Should validate GUID format for TenantId" {
            # Capture all output from the script execution including Write-Host
            $output = & $script:ScriptPath -TenantId "invalid-guid" -SubscriptionId "12345678-1234-1234-1234-123456789012" -ProjectName "test" -WhatIf *>&1 | Out-String
            
            # Check that the expected error message appears in the output
            $output | Should -Match "Valid Azure Tenant ID is required"
        }
        
        It "Should validate GUID format for SubscriptionId" {
            # Capture all output from the script execution including Write-Host
            $output = & $script:ScriptPath -TenantId "12345678-1234-1234-1234-123456789012" -SubscriptionId "invalid-guid" -ProjectName "test" -WhatIf *>&1 | Out-String
            
            # Check that the expected error message appears in the output
            $output | Should -Match "Valid Azure Subscription ID is required"
        }
        
        It "Should use directory name as ProjectName when not provided" {
            # Test should not fail due to missing ProjectName when WhatIf is used
            $output = & $script:ScriptPath -TenantId "12345678-1234-1234-1234-123456789012" -SubscriptionId "87654321-4321-4321-4321-210987654321" -ProjectPath $script:TestProjectPath -WhatIf *>&1 | Out-String
            
            # Should not contain ProjectName validation error
            $output | Should -Not -Match "ProjectName is required"
        }
    }
    
    Context "File Operations" {
        BeforeEach {
            # Create test directory
            New-Item -ItemType Directory -Path $script:TestProjectPath -Force | Out-Null
        }
        
        AfterEach {
            # Clean up test directory
            if (Test-Path $script:TestProjectPath) {
                Remove-Item $script:TestProjectPath -Recurse -Force
            }
        }
        
        It "Should handle missing template source gracefully" {
            # Use cross-platform temp path resolution
            $tempPath = if ($env:TEMP) { $env:TEMP } else { [System.IO.Path]::GetTempPath() }
            $invalidTemplatePath = Join-Path $tempPath "NonExistentTemplate"
            
            # Capture all output from the script execution including Write-Host
            $output = & $script:ScriptPath -TenantId "12345678-1234-1234-1234-123456789012" -SubscriptionId "87654321-4321-4321-4321-210987654321" -ProjectName "test" -ProjectPath $script:TestProjectPath -TemplateSource $invalidTemplatePath -WhatIf *>&1 | Out-String
            
            # Check that the expected error message appears in the output
            $output | Should -Match "DevContainer template not found"
        }
    }
    
    Context "Storage Account Name Generation" {
        It "Should generate valid storage account names for various project names" {
            $testCases = @(
                "simple-project",
                "Project_With$pecial-Characters!",
                "VeryLongProjectNameThatExceedsCharacterLimits",
                "123-numeric-start",
                "Mixed-CASE-project"
            )
            
            foreach ($projectName in $testCases) {
                # Import the module to test the function directly - Use robust path resolution
                $scriptDir = Split-Path $script:ScriptPath -Parent
                $ModulesPath = Join-Path $scriptDir "modules"
                
                # Validate modules exist before importing
                $commonModulePath = Join-Path $ModulesPath "CommonModule.psm1"
                $azureModulePath = Join-Path $ModulesPath "AzureModule.psm1"
                
                if (-not (Test-Path $commonModulePath)) {
                    throw "CommonModule.psm1 not found at: $commonModulePath"
                }
                if (-not (Test-Path $azureModulePath)) {
                    throw "AzureModule.psm1 not found at: $azureModulePath"
                }
                
                Import-Module $commonModulePath -Force
                Import-Module $azureModulePath -Force
                
                $result = New-AzureStorageAccountName -ProjectName $projectName -Environment "dev" -Purpose "tfstate"
                
                $result.StorageAccountName | Should -Not -BeNullOrEmpty
                $result.StorageAccountName.Length | Should -BeLessOrEqual 24
                $result.StorageAccountName.Length | Should -BeGreaterOrEqual 3
                $result.StorageAccountName | Should -Match '^[a-z0-9]+$'
            }
        }
    }
}

AfterAll {
    # Final cleanup - Add null check for CI safety
    if ($script:TestProjectPath -and (Test-Path $script:TestProjectPath)) {
        Remove-Item $script:TestProjectPath -Recurse -Force -ErrorAction SilentlyContinue
    }
}
