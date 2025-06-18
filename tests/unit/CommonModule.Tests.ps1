#Requires -Modules Pester

BeforeAll {
    # Import the module being tested
    $ModulePath = Join-Path $PSScriptRoot "..\..\modules\CommonModule.psm1"
    Import-Module $ModulePath -Force
}

Describe "CommonModule Tests" {
    Context "Write-ColorOutput" {
        It "Should output message without throwing error" {
            { Write-ColorOutput "Test Message" "Green" } | Should -Not -Throw
        }
        
        It "Should handle empty color parameter" {
            { Write-ColorOutput "Test Message" } | Should -Not -Throw
        }
        
        It "Should handle empty message" {
            { Write-ColorOutput "" "Red" } | Should -Not -Throw
        }
    }
    
    Context "Test-IsGuid" {
        It "Should return true for valid GUID" {
            $validGuid = "12345678-1234-1234-1234-123456789012"
            Test-IsGuid -InputString $validGuid | Should -Be $true
        }
        
        It "Should return false for invalid GUID" {
            Test-IsGuid -InputString "not-a-guid" | Should -Be $false
        }
        
        It "Should return false for empty string" {
            Test-IsGuid -InputString "" | Should -Be $false
        }
        
        It "Should return false for GUID without hyphens" {
            Test-IsGuid -InputString "12345678123412341234123456789012" | Should -Be $false
        }
        
        It "Should return false for GUID with wrong length" {
            Test-IsGuid -InputString "1234-1234-1234-1234" | Should -Be $false
        }
    }
    
    Context "Test-Prerequisites" {
        It "Should check for Docker and VS Code" {
            # Mock the Get-Command calls and Write-ColorOutput to suppress output
            Mock Get-Command -ModuleName CommonModule { 
                param($Name, $ErrorAction)
                if ($Name -eq "docker") { return @{ Name = "docker"; CommandType = "Application" } }
                if ($Name -eq "code") { return @{ Name = "code"; CommandType = "Application" } }
                throw [System.Management.Automation.CommandNotFoundException]::new("Command not found")
            }
            Mock Write-ColorOutput -ModuleName CommonModule { }
            
            Test-Prerequisites | Should -Be $true
        }
        
        It "Should return false when Docker is missing" {
            Mock Get-Command -ModuleName CommonModule { 
                param($Name, $ErrorAction)
                if ($Name -eq "docker") { 
                    throw [System.Management.Automation.CommandNotFoundException]::new("Command 'docker' not found")
                }
                if ($Name -eq "code") { return @{ Name = "code"; CommandType = "Application" } }
                throw [System.Management.Automation.CommandNotFoundException]::new("Command not found")
            }
            Mock Write-ColorOutput -ModuleName CommonModule { }
            
            Test-Prerequisites | Should -Be $false
        }
        
        It "Should return false when VS Code is missing" {
            Mock Get-Command -ModuleName CommonModule { 
                param($Name, $ErrorAction)
                if ($Name -eq "docker") { return @{ Name = "docker"; CommandType = "Application" } }
                if ($Name -eq "code") { 
                    throw [System.Management.Automation.CommandNotFoundException]::new("Command 'code' not found")
                }
                throw [System.Management.Automation.CommandNotFoundException]::new("Command not found")
            }
            Mock Write-ColorOutput -ModuleName CommonModule { }
            
            Test-Prerequisites | Should -Be $false
        }
    }
    
    Context "Show-NextSteps" {
        It "Should not throw when called with minimal parameters" {
            { Show-NextSteps -ProjectPath "C:\test" -ProjectType "terraform" } | Should -Not -Throw
        }
        
        It "Should not throw when called with backend info" {
            $backendInfo = @{
                StorageAccount = "testsa"
                ResourceGroup = "test-rg"
                Container = "tfstate"
            }
            { Show-NextSteps -ProjectPath "C:\test" -ProjectType "terraform" -BackendInfo $backendInfo } | Should -Not -Throw
        }
    }
}

AfterAll {
    # Clean up
    Remove-Module CommonModule -Force -ErrorAction SilentlyContinue
}
