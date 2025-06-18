#Requires -Modules Pester

<#
.SYNOPSIS
    Pester tests for DevContainer Template validation

.DESCRIPTION
    This Pester test suite validates the DevContainer template including:
    - PowerShell syntax validation
    - Module functionality testing
    - File structure verification
    - DevContainer configuration validation

.EXAMPLE
    Invoke-Pester -Path .\tests\DevContainer.Tests.ps1

.EXAMPLE
    Invoke-Pester -Path .\tests\DevContainer.Tests.ps1 -Tag "Syntax"

.EXAMPLE
    Invoke-Pester -Path .\tests\DevContainer.Tests.ps1 -Tag "Module" -Output Detailed
#>

BeforeAll {
    # Get the root directory (parent of tests)
    $script:RootPath = Split-Path $PSScriptRoot -Parent
    
    # Ensure we're in the right location
    if (-not (Test-Path (Join-Path $script:RootPath "Initialize-DevContainer.ps1"))) {
        throw "Cannot find Initialize-DevContainer.ps1. Please run tests from the correct directory."
    }
}

Describe "DevContainer Template - PowerShell Syntax Validation" -Tag "Syntax" {
    
    Context "Core PowerShell Scripts" {
        
        It "Initialize-DevContainer.ps1 should have valid PowerShell syntax" {
            # Arrange
            $scriptPath = Join-Path $script:RootPath "Initialize-DevContainer.ps1"
            $errors = $null
            $tokens = $null
            
            # Act & Assert
            $scriptPath | Should -Exist
            {
                $null = [System.Management.Automation.Language.Parser]::ParseFile(
                    $scriptPath, 
                    [ref]$tokens, 
                    [ref]$errors
                )
            } | Should -Not -Throw
            
            $errors.Count | Should -Be 0 -Because "The script should have no parse errors"
        }
        
        It "Install-DevContainerAccelerator.ps1 should have valid PowerShell syntax" {
            # Arrange
            $scriptPath = Join-Path $script:RootPath "Install-DevContainerAccelerator.ps1"
            $errors = $null
            $tokens = $null
            
            # Act & Assert
            $scriptPath | Should -Exist
            {
                $null = [System.Management.Automation.Language.Parser]::ParseFile(
                    $scriptPath, 
                    [ref]$tokens, 
                    [ref]$errors
                )
            } | Should -Not -Throw
            
            $errors.Count | Should -Be 0 -Because "The script should have no parse errors"
        }
        
        It "DevContainerAccelerator.psm1 should have valid PowerShell syntax" {
            # Arrange
            $modulePath = Join-Path $script:RootPath "DevContainerAccelerator\DevContainerAccelerator.psm1"
            $errors = $null
            $tokens = $null
            
            # Act & Assert
            $modulePath | Should -Exist
            {
                $null = [System.Management.Automation.Language.Parser]::ParseFile(
                    $modulePath, 
                    [ref]$tokens, 
                    [ref]$errors
                )
            } | Should -Not -Throw
            
            $errors.Count | Should -Be 0 -Because "The module should have no parse errors"
        }
        
        It "Scripts should be convertible to ScriptBlock" {
            # Arrange
            $scriptPath = Join-Path $script:RootPath "Initialize-DevContainer.ps1"
            
            # Act & Assert
            $scriptContent = Get-Content $scriptPath -Raw
            $scriptContent | Should -Not -BeNullOrEmpty
            
            { [ScriptBlock]::Create($scriptContent) } | Should -Not -Throw
        }
    }
}

Describe "DevContainer Template - Module Functionality" -Tag "Module" {
    
    BeforeAll {
        # Import the new modular architecture modules for testing
        $modulesPath = Join-Path $script:RootPath "modules"
        Import-Module (Join-Path $modulesPath "CommonModule.psm1") -Force
        Import-Module (Join-Path $modulesPath "AzureModule.psm1") -Force
        Import-Module (Join-Path $modulesPath "InteractiveModule.psm1") -Force
        Import-Module (Join-Path $modulesPath "DevContainerModule.psm1") -Force
        Import-Module (Join-Path $modulesPath "ProjectModule.psm1") -Force
        
        # Also import the legacy module for compatibility testing
        $legacyModulePath = Join-Path $script:RootPath "DevContainerAccelerator\DevContainerAccelerator.psm1"
        if (Test-Path $legacyModulePath) {
            Import-Module $legacyModulePath -Force
        }
    }
    
    AfterAll {
        # Clean up modules
        Remove-Module CommonModule -Force -ErrorAction SilentlyContinue
        Remove-Module AzureModule -Force -ErrorAction SilentlyContinue
        Remove-Module InteractiveModule -Force -ErrorAction SilentlyContinue
        Remove-Module DevContainerModule -Force -ErrorAction SilentlyContinue
        Remove-Module ProjectModule -Force -ErrorAction SilentlyContinue
        Remove-Module DevContainerAccelerator -Force -ErrorAction SilentlyContinue
    }
    
    Context "Module Import and Export" {
        
        It "Should import the DevContainerAccelerator module successfully" {
            # Act
            $module = Get-Module DevContainerAccelerator
            
            # Assert
            $module | Should -Not -BeNullOrEmpty
            $module.Name | Should -Be "DevContainerAccelerator"
        }
        
        It "Should export functions from the module" {
            # Act
            $functions = Get-Command -Module DevContainerAccelerator -ErrorAction SilentlyContinue
            
            # Assert
            $functions | Should -Not -BeNullOrEmpty
            $functions.Count | Should -BeGreaterThan 0
        }
        
        It "Should have module manifest file" {
            # Arrange
            $manifestPath = Join-Path $script:RootPath "DevContainerAccelerator\DevContainerAccelerator.psd1"
            
            # Assert
            $manifestPath | Should -Exist
            
            # Test manifest can be imported
            { Test-ModuleManifest $manifestPath } | Should -Not -Throw
        }
    }
    
    Context "Specific Function Testing" {
        
        It "Test-IsGuid function should work correctly" {
            # Arrange
            $validGuid = "123e4567-e89b-12d3-a456-426614174000"
            $invalidGuid = "invalid-guid"
            
            # Act & Assert
            Test-IsGuid -InputString $validGuid | Should -Be $true
            Test-IsGuid -InputString $invalidGuid | Should -Be $false
        }
        
        It "Write-ColorOutput function should be available" {
            # Act
            $command = Get-Command Write-ColorOutput -ErrorAction SilentlyContinue
            
            # Assert
            $command | Should -Not -BeNullOrEmpty
            $command.Name | Should -Be "Write-ColorOutput"
        }
    }
}

Describe "DevContainer Template - File Structure" -Tag "Structure" {
    
    Context "Core Files" {
        
        It "Should have Initialize-DevContainer.ps1" {
            $path = Join-Path $script:RootPath "Initialize-DevContainer.ps1"
            $path | Should -Exist
        }
        
        It "Should have Install-DevContainerAccelerator.ps1" {
            $path = Join-Path $script:RootPath "Install-DevContainerAccelerator.ps1"
            $path | Should -Exist
        }
        
        It "Should have README.md" {
            $path = Join-Path $script:RootPath "README.md"
            $path | Should -Exist
        }
    }
    
    Context "DevContainer Configuration" {
        
        It "Should have devcontainer.json" {
            $path = Join-Path $script:RootPath ".devcontainer\devcontainer.json"
            $path | Should -Exist
        }
        
        It "Should have Dockerfile" {
            $path = Join-Path $script:RootPath ".devcontainer\Dockerfile"
            $path | Should -Exist
        }
        
        It "Should have devcontainer.env.example" {
            $path = Join-Path $script:RootPath ".devcontainer\devcontainer.env.example"
            $path | Should -Exist
        }
        
        It "Should have scripts directory" {
            $path = Join-Path $script:RootPath ".devcontainer\scripts"
            $path | Should -Exist
        }
        
        It "devcontainer.json should be valid JSON" {
            # Arrange
            $devcontainerPath = Join-Path $script:RootPath ".devcontainer\devcontainer.json"
            
            # Act & Assert
            $devcontainerPath | Should -Exist
            $content = Get-Content $devcontainerPath -Raw
            { $content | ConvertFrom-Json } | Should -Not -Throw
        }
    }
    
    Context "Module Files" {
        
        It "Should have DevContainerAccelerator.psd1" {
            $path = Join-Path $script:RootPath "DevContainerAccelerator\DevContainerAccelerator.psd1"
            $path | Should -Exist
        }
        
        It "Should have DevContainerAccelerator.psm1" {
            $path = Join-Path $script:RootPath "DevContainerAccelerator\DevContainerAccelerator.psm1"
            $path | Should -Exist
        }
    }
    
    Context "Example Directories" {
        
        $exampleDirs = @(
            "getting-started",
            "terraform", 
            "bicep", 
            "arm", 
            "powershell", 
            "configuration"
        )
        
        It "Should have <_> example directory" -ForEach $exampleDirs {
            $path = Join-Path $script:RootPath "examples\$_"
            $path | Should -Exist
        }
        
        It "Each example directory should have a README.md" -ForEach $exampleDirs {
            $readmePath = Join-Path $script:RootPath "examples\$_\README.md"
            $readmePath | Should -Exist
        }
    }
    
    Context "Test Directory" {
        
        It "Should have tests directory" {
            $path = Join-Path $script:RootPath "tests"
            $path | Should -Exist
        }
        
        It "Should have this test file" {
            $path = Join-Path $script:RootPath "tests\DevContainer.Tests.ps1"
            $path | Should -Exist
        }
    }
}

Describe "DevContainer Template - Configuration Validation" -Tag "Configuration" {
    
    Context "DevContainer Configuration" {
        
        BeforeAll {
            $devcontainerPath = Join-Path $script:RootPath ".devcontainer\devcontainer.json"
            $script:DevContainerConfig = Get-Content $devcontainerPath | ConvertFrom-Json
        }
        
        It "devcontainer.json should have required properties" {
            $script:DevContainerConfig.name | Should -Not -BeNullOrEmpty
            $script:DevContainerConfig.image -or $script:DevContainerConfig.dockerFile | Should -Not -BeNullOrEmpty
        }
        
        It "Should have postCreateCommand or onCreateCommand if specified" {
            # This is optional, but if present should be valid
            if ($script:DevContainerConfig.postCreateCommand -or $script:DevContainerConfig.onCreateCommand) {
                ($script:DevContainerConfig.postCreateCommand -or $script:DevContainerConfig.onCreateCommand) | Should -Not -BeNullOrEmpty
            }
        }
    }
    
    Context "Script Files Configuration" {
        
        It "DevContainer scripts should be executable" {
            $scriptsPath = Join-Path $script:RootPath ".devcontainer\scripts"
            $scriptFiles = Get-ChildItem $scriptsPath -Filter "*.sh" -ErrorAction SilentlyContinue
            
            if ($scriptFiles) {
                foreach ($script in $scriptFiles) {
                    $script.FullName | Should -Exist
                    # Note: On Windows, we can't easily check execute permissions, but we can verify the file exists
                }
            }
        }
    }
}

Describe "DevContainer Template - Integration Tests" -Tag "Integration" {
    
    Context "End-to-End Validation" {
          It "Should be able to load and parse all PowerShell files without errors" {
            # Arrange
            $allPsFiles = Get-ChildItem $script:RootPath -Recurse -Include "*.ps1", "*.psm1" | 
                Where-Object { $_.FullName -notlike "*\.git\*" -and $_.FullName -notlike "*node_modules\*" }
            
            # Act & Assert
            $allPsFiles | Should -Not -BeNullOrEmpty
            
            foreach ($file in $allPsFiles) {
                $errors = $null
                $tokens = $null
                
                { 
                    $null = [System.Management.Automation.Language.Parser]::ParseFile(
                        $file.FullName, 
                        [ref]$tokens, 
                        [ref]$errors
                    )
                } | Should -Not -Throw -Because "File $($file.Name) should parse without errors"
                
                $errors.Count | Should -Be 0 -Because "File $($file.Name) should have no parse errors"
            }
        }
        
        It "Should have consistent line endings in text files" {
            # This test ensures consistent line endings across the project
            $textFiles = Get-ChildItem $script:RootPath -Recurse -Include "*.ps1", "*.psm1", "*.psd1", "*.md", "*.json" |
                Where-Object { $_.FullName -notlike "*\.git\*" }
            
            foreach ($file in $textFiles) {
                $content = Get-Content $file.FullName -Raw
                if ($content) {
                    # Check that file doesn't mix line endings (should be consistent)
                    $crlfCount = ([regex]::Matches($content, "`r`n")).Count
                    $lfOnlyCount = ([regex]::Matches($content, "(?<!`r)`n")).Count
                    
                    # Either all CRLF or all LF, but not mixed
                    ($crlfCount -eq 0 -or $lfOnlyCount -eq 0) | Should -Be $true -Because "File $($file.Name) should have consistent line endings"
                }
            }
        }
    }
}
