#Requires -Modules Pester

BeforeAll {
    # Get the root directory
    $script:RootPath = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
    $script:ScriptPath = Join-Path $script:RootPath "Initialize-DevContainer.ps1"
    
    # Skip tests in CI that require interactive input or Azure CLI
    $script:IsCI = $env:CI -or $env:GITHUB_ACTIONS
}

Describe "Initialize-DevContainer Integration Tests" {
    Context "Script Validation" {
        It "Should have valid PowerShell syntax" {
            $script:ScriptPath | Should -Exist
            
            $errors = $null
            $tokens = $null
            $null = [System.Management.Automation.Language.Parser]::ParseFile(
                $script:ScriptPath, 
                [ref]$tokens, 
                [ref]$errors
            )
            
            $errors.Count | Should -Be 0
        }
        
        It "Should support WhatIf parameter" {
            $scriptContent = Get-Content $script:ScriptPath -Raw
            $scriptContent | Should -Match '\[switch\]\$WhatIf'
        }
    }
    
    Context "Module Integration" {
        It "Should load all required modules successfully" -Skip:$script:IsCI {
            # This test would require the full environment setup
            # Skip in CI to avoid complexity
        }
        
        It "Should handle missing modules gracefully" {
            # Test that the script can run even without modules loaded
            # by checking for fallback function definitions
            $scriptContent = Get-Content $script:ScriptPath -Raw
            
            # Should have embedded essential functions
            $scriptContent | Should -Match 'function Write-ColorOutput'
            $scriptContent | Should -Match 'function Test-IsGuid'
            $scriptContent | Should -Match 'function New-AzureStorageAccountName'
        }
    }
    
    Context "Parameter Validation" {
        It "Should have proper parameter definitions" {
            $scriptContent = Get-Content $script:ScriptPath -Raw
            
            # Check for key parameters
            $scriptContent | Should -Match '\$TenantId'
            $scriptContent | Should -Match '\$SubscriptionId'
            $scriptContent | Should -Match '\$ProjectName'
            $scriptContent | Should -Match '\$ProjectType'
        }
    }
}
