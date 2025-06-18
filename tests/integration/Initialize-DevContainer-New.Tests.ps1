#Requires -Modules Pester

BeforeAll {
    # Test paths
    $ScriptPath = Join-Path $PSScriptRoot "..\..\Initialize-DevContainer-New.ps1"
    $TestProjectPath = Join-Path $env:TEMP "DevContainerTest-$(Get-Random)"
    
    # Ensure test project directory doesn't exist
    if (Test-Path $TestProjectPath) {
        Remove-Item $TestProjectPath -Recurse -Force
    }
}

Describe "Initialize-DevContainer-New Integration Tests" {
    Context "Module Import" {
        It "Should import all required modules without error" {
            # Test that the script can load without throwing errors
            { & $ScriptPath -WhatIf } | Should -Not -Throw
        }
    }
    
    Context "Parameter Validation" {
        It "Should validate GUID format for TenantId" {
            $result = & $ScriptPath -TenantId "invalid-guid" -SubscriptionId "12345678-1234-1234-1234-123456789012" -ProjectName "test" 2>&1
            $result | Should -Match "Valid Azure Tenant ID is required"
        }
        
        It "Should validate GUID format for SubscriptionId" {
            $result = & $ScriptPath -TenantId "12345678-1234-1234-1234-123456789012" -SubscriptionId "invalid-guid" -ProjectName "test" 2>&1
            $result | Should -Match "Valid Azure Subscription ID is required"
        }
        
        It "Should use directory name as ProjectName when not provided" {
            # This test requires mocking some functions to avoid actual Azure calls
            Mock Test-Prerequisites { return $true } -ModuleName CommonModule
            Mock Test-Path { return $true }
            Mock New-Item { return @{ FullName = $TestProjectPath } }
            Mock Copy-Item { return $true }
            Mock Set-Content { return $true }
            
            # Test should not fail due to missing ProjectName
            $result = & $ScriptPath -TenantId "12345678-1234-1234-1234-123456789012" -SubscriptionId "87654321-4321-4321-4321-210987654321" -ProjectPath $TestProjectPath 2>&1
            
            # Should not contain ProjectName validation error
            $result | Should -Not -Match "ProjectName is required"
        }
    }
    
    Context "File Operations" {
        BeforeEach {
            # Create test directory
            New-Item -ItemType Directory -Path $TestProjectPath -Force | Out-Null
        }
        
        AfterEach {
            # Clean up test directory
            if (Test-Path $TestProjectPath) {
                Remove-Item $TestProjectPath -Recurse -Force
            }
        }
        
        It "Should handle missing template source gracefully" {
            $invalidTemplatePath = Join-Path $env:TEMP "NonExistentTemplate"
            
            # Mock prerequisites to pass
            Mock Test-Prerequisites { return $true } -ModuleName CommonModule
            Mock Test-AzureAuthentication { return @{ id = "test" } } -ModuleName AzureModule
            
            $result = & $ScriptPath -TenantId "12345678-1234-1234-1234-123456789012" -SubscriptionId "87654321-4321-4321-4321-210987654321" -ProjectName "test" -ProjectPath $TestProjectPath -TemplateSource $invalidTemplatePath 2>&1
            
            $result | Should -Match "DevContainer template not found"
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
                $ModulesPath = Join-Path (Split-Path $ScriptPath) "modules"
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
    if (Test-Path $TestProjectPath) {
        Remove-Item $TestProjectPath -Recurse -Force -ErrorAction SilentlyContinue
    }
}
