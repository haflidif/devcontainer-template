#Requires -Modules Pester

BeforeAll {
    # Test paths
    $script:ScriptPath = Join-Path $PSScriptRoot "..\..\Initialize-DevContainer.ps1"
    $script:TestProjectPath = Join-Path $env:TEMP "DevContainerTest-$(Get-Random)"
    
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
            $invalidTemplatePath = Join-Path $env:TEMP "NonExistentTemplate"
            
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
                # Import the module to test the function directly
                $ModulesPath = Join-Path (Split-Path $script:ScriptPath) "modules"
                Import-Module (Join-Path $ModulesPath "CommonModule.psm1") -Force
                Import-Module (Join-Path $ModulesPath "AzureModule.psm1") -Force
                
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
    # Final cleanup
    if (Test-Path $script:TestProjectPath) {
        Remove-Item $script:TestProjectPath -Recurse -Force -ErrorAction SilentlyContinue
    }
}
