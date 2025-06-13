@{
    # Module manifest for DevContainerAccelerator
    RootModule = 'DevContainerAccelerator.psm1'
    ModuleVersion = '1.0.0'
    GUID = 'a1b2c3d4-e5f6-7890-1234-567890abcdef'
    Author = 'DevContainer Template Team'
    CompanyName = 'Open Source'
    Copyright = '(c) 2025. All rights reserved.'
    Description = 'PowerShell module to accelerate DevContainer setup for Infrastructure as Code projects (Terraform/Bicep)'
    
    # Minimum version of the PowerShell engine required by this module
    PowerShellVersion = '5.1'
    
    # Functions to export from this module
    FunctionsToExport = @(
        'Initialize-DevContainer',
        'New-IaCProject',
        'Test-DevContainerPrerequisites',
        'Update-DevContainerTemplate'
    )
    
    # Cmdlets to export from this module
    CmdletsToExport = @()
    
    # Variables to export from this module
    VariablesToExport = @()
    
    # Aliases to export from this module
    AliasesToExport = @(
        'init-devcontainer',
        'new-iac'
    )
    
    # Private data to pass to the module specified in RootModule/ModuleToProcess
    PrivateData = @{
        PSData = @{
            Tags = @('DevContainer', 'Terraform', 'Bicep', 'Azure', 'IaC', 'Infrastructure', 'Docker', 'VSCode')            LicenseUri = 'https://github.com/haflidif/devcontainer-template/blob/main/LICENSE'
            ProjectUri = 'https://github.com/haflidif/devcontainer-template'
            ReleaseNotes = @'
1.0.0
- Initial release
- Support for Terraform and Bicep projects
- Azure authentication configuration
- Automated DevContainer setup
- Example file templates
- Cross-platform PowerShell support
'@
        }
    }
}
