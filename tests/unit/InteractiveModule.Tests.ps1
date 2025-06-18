#Requires -Modules Pester

BeforeAll {
    # Import required modules
    $ModulesPath = Join-Path $PSScriptRoot "..\..\modules"
    Import-Module (Join-Path $ModulesPath "CommonModule.psm1") -Force
    Import-Module (Join-Path $ModulesPath "AzureModule.psm1") -Force
    Import-Module (Join-Path $ModulesPath "InteractiveModule.psm1") -Force
}

Describe "InteractiveModule Tests" {
    Context "Get-InteractiveInput" {
        It "Should return default value when input is empty" {
            # Mock Read-Host to return empty string
            Mock Read-Host { return "" }
            
            $result = Get-InteractiveInput -Prompt "Test Prompt" -DefaultValue "default"
            $result | Should -Be "default"
        }
        
        It "Should return user input when provided" {
            # Mock Read-Host to return user input
            Mock Read-Host { return "user input" }
            
            $result = Get-InteractiveInput -Prompt "Test Prompt" -DefaultValue "default"
            $result | Should -Be "user input"
        }
        
        It "Should handle empty default value" {
            Mock Read-Host { return "user input" }
            
            $result = Get-InteractiveInput -Prompt "Test Prompt"
            $result | Should -Be "user input"
        }
    }
    
    Context "Get-BackendConfiguration" {
        It "Should generate proper backend configuration structure" {
            # Mock all user inputs
            Mock Get-InteractiveInput { 
                switch ($Prompt) {
                    "Backend Subscription ID" { return "sub-123" }
                    "Resource Group for backend" { return "test-rg" }
                    "Storage Account name" { return "testsa" }
                    "Container name" { return "tfstate" }
                    "Enter choice (1-3)" { return "1" }
                    default { return "default" }
                }
            }
            
            # Mock storage account name generation
            Mock New-AzureStorageAccountName {
                return @{
                    StorageAccountName = "testsa123"
                    DisplayName = "TestProject-dev-tfstate"
                }
            }
            
            $result = Get-BackendConfiguration -ProjectName "TestProject" -SubscriptionId "main-sub" -Location "eastus"
            
            $result.SubscriptionId | Should -Be "sub-123"
            $result.ResourceGroup | Should -Be "test-rg"
            $result.StorageAccount | Should -Be "testsa"
            $result.Container | Should -Be "tfstate"
            $result.Action | Should -Be "validate"
        }
        
        It "Should handle create action selection" {
            Mock Get-InteractiveInput { 
                switch ($Prompt) {
                    "Enter choice (1-3)" { return "2" }
                    default { return "default" }
                }
            }
            
            Mock New-AzureStorageAccountName {
                return @{
                    StorageAccountName = "testsa123"
                    DisplayName = "TestProject-dev-tfstate"
                }
            }
            
            $result = Get-BackendConfiguration -ProjectName "TestProject" -SubscriptionId "main-sub" -Location "eastus"
            $result.Action | Should -Be "create"
        }
        
        It "Should handle skip action selection" {
            Mock Get-InteractiveInput { 
                switch ($Prompt) {
                    "Enter choice (1-3)" { return "3" }
                    default { return "default" }
                }
            }
            
            Mock New-AzureStorageAccountName {
                return @{
                    StorageAccountName = "testsa123"
                    DisplayName = "TestProject-dev-tfstate"
                }
            }
            
            $result = Get-BackendConfiguration -ProjectName "TestProject" -SubscriptionId "main-sub" -Location "eastus"
            $result.Action | Should -Be "skip"
        }
    }
}

AfterAll {
    # Clean up
    Remove-Module InteractiveModule -Force -ErrorAction SilentlyContinue
    Remove-Module AzureModule -Force -ErrorAction SilentlyContinue
    Remove-Module CommonModule -Force -ErrorAction SilentlyContinue
}
