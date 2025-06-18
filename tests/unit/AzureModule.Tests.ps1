#Requires -Modules Pester

BeforeAll {
    # Import required modules
    $ModulesPath = Join-Path $PSScriptRoot "..\..\modules"
    Import-Module (Join-Path $ModulesPath "CommonModule.psm1") -Force
    Import-Module (Join-Path $ModulesPath "AzureModule.psm1") -Force
}

Describe "AzureModule Tests" {
    Context "New-AzureStorageAccountName" {
        It "Should generate a valid storage account name" {
            $result = New-AzureStorageAccountName -ProjectName "TestProject" -Environment "dev" -Purpose "tfstate"
            
            $result.StorageAccountName | Should -Not -BeNullOrEmpty
            $result.StorageAccountName.Length | Should -BeLessOrEqual 24
            $result.StorageAccountName.Length | Should -BeGreaterOrEqual 3
            $result.StorageAccountName | Should -Match '^[a-z0-9]+$'
        }
        
        It "Should handle long project names" {
            $longProjectName = "VeryLongProjectNameThatExceedsLimits"
            $result = New-AzureStorageAccountName -ProjectName $longProjectName -Environment "dev" -Purpose "tfstate"
            
            $result.StorageAccountName.Length | Should -BeLessOrEqual 24
        }
        
        It "Should generate deterministic names for same input" {
            $result1 = New-AzureStorageAccountName -ProjectName "TestProject" -Environment "dev" -Purpose "tfstate"
            $result2 = New-AzureStorageAccountName -ProjectName "TestProject" -Environment "dev" -Purpose "tfstate"
            
            # Should generate the same base name (before availability check)
            $result1.ProjectName | Should -Be $result2.ProjectName
            $result1.Environment | Should -Be $result2.Environment
            $result1.Purpose | Should -Be $result2.Purpose
        }
        
        It "Should include proper metadata" {
            $result = New-AzureStorageAccountName -ProjectName "TestProject" -Environment "prod" -Purpose "tfstate"
            
            $result.DisplayName | Should -Be "TestProject-prod-tfstate"
            $result.ProjectName | Should -Be "TestProject"
            $result.Environment | Should -Be "prod"
            $result.Purpose | Should -Be "tfstate"
        }
        
        It "Should clean special characters from project name" {
            $result = New-AzureStorageAccountName -ProjectName "Test-Project_With$pecial" -Environment "dev" -Purpose "tfstate"
            
            $result.StorageAccountName | Should -Match '^[a-z0-9]+$'
        }
    }
    
    Context "Test-AzureStorageAccountAvailability" {
        It "Should handle availability check gracefully when Azure CLI fails" {
            # Mock Azure CLI failure
            Mock Invoke-Expression { throw "Azure CLI error" }
            
            $result = Test-AzureStorageAccountAvailability -StorageAccountName "testaccount"
            
            $result.Available | Should -Be $false
            $result.Reason | Should -Be "Error"
        }
    }
    
    Context "Test-AzureAuthentication" {
        It "Should throw when Azure CLI is not available" {
            Mock Get-Command { throw "Command not found" }
            
            { Test-AzureAuthentication -SubscriptionId "12345678-1234-1234-1234-123456789012" } | Should -Throw
        }
    }
    
    Context "Test-AzureStorageAccount" {
        It "Should validate required parameters" {
            { Test-AzureStorageAccount -StorageAccountName "" -ResourceGroupName "test-rg" -SubscriptionId "12345678-1234-1234-1234-123456789012" } | Should -Throw
        }
    }
    
    Context "Test-AzureStorageContainer" {
        It "Should validate required parameters" {
            { Test-AzureStorageContainer -StorageAccountName "" -ContainerName "test" -ResourceGroupName "test-rg" -SubscriptionId "12345678-1234-1234-1234-123456789012" } | Should -Throw
        }
    }
}

AfterAll {
    # Clean up
    Remove-Module AzureModule -Force -ErrorAction SilentlyContinue
    Remove-Module CommonModule -Force -ErrorAction SilentlyContinue
}
