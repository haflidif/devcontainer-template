#Requires -Version 5.1

<#
.SYNOPSIS
    Project initialization and example file management for DevContainer Accelerator.

.DESCRIPTION
    This module provides functionality for adding example files and initializing
    Terraform and Bicep projects.
#>

Import-Module -Name (Join-Path $PSScriptRoot "CommonModule.psm1") -Force

function Add-ExampleFiles {
    param(
        [string]$ProjectPath,
        [string]$ProjectType,
        [string]$TemplateSource
    )
    
    Write-ColorOutput "📄 Adding example files..." "Cyan"
    
    $examplesPath = Join-Path $TemplateSource "examples"
    if (-not (Test-Path $examplesPath)) {
        Write-ColorOutput "⚠️  Examples directory not found at: $examplesPath" "Yellow"
        return $false
    }
    
    try {
        # Copy common examples
        $commonExamplesPath = Join-Path $examplesPath "common"
        if (Test-Path $commonExamplesPath) {
            Copy-Item -Path "$commonExamplesPath\*" -Destination $ProjectPath -Recurse -Force
            Write-ColorOutput "✅ Common example files added" "Green"
        }
        
        # Copy project-specific examples
        if ($ProjectType -in @('terraform', 'both')) {
            $terraformExamplesPath = Join-Path $examplesPath "terraform"
            if (Test-Path $terraformExamplesPath) {
                Copy-Item -Path "$terraformExamplesPath\*" -Destination $ProjectPath -Recurse -Force
                Write-ColorOutput "✅ Terraform example files added" "Green"
            }
        }
        
        if ($ProjectType -in @('bicep', 'both')) {
            $bicepExamplesPath = Join-Path $examplesPath "bicep"
            if (Test-Path $bicepExamplesPath) {
                Copy-Item -Path "$bicepExamplesPath\*" -Destination $ProjectPath -Recurse -Force
                Write-ColorOutput "✅ Bicep example files added" "Green"
            }
        }
        
        # Copy getting started examples
        $gettingStartedPath = Join-Path $examplesPath "getting-started"
        if (Test-Path $gettingStartedPath) {
            Copy-Item -Path "$gettingStartedPath\*" -Destination $ProjectPath -Recurse -Force
            Write-ColorOutput "✅ Getting started files added" "Green"
        }
        
        return $true
    }
    catch {
        Write-ColorOutput "❌ Failed to add example files: $($_.Exception.Message)" "Red"
        throw
    }
}

Export-ModuleMember -Function Add-ExampleFiles
