#Requires -Version 5.1

<#
.SYNOPSIS
    DevContainer file management functions for DevContainer Accelerator.

.DESCRIPTION
    This module provides DevContainer-specific functionality including file operations,
    environment configuration, and container setup.
#>

Import-Module -Name (Join-Path $PSScriptRoot "CommonModule.psm1") -Force

function Initialize-ProjectDirectory {
    param(
        [string]$ProjectPath
    )
    
    Write-ColorOutput "📁 Initializing project directory: $ProjectPath" "Cyan"
    
    # Create project directory if it doesn't exist
    if (-not (Test-Path $ProjectPath)) {
        New-Item -ItemType Directory -Path $ProjectPath -Force | Out-Null
        Write-ColorOutput "✅ Created project directory" "Green"
    }
    else {
        Write-ColorOutput "✅ Using existing project directory" "Green"
    }
    
    # Ensure .devcontainer directory exists
    $devcontainerPath = Join-Path $ProjectPath ".devcontainer"
    if (-not (Test-Path $devcontainerPath)) {
        New-Item -ItemType Directory -Path $devcontainerPath -Force | Out-Null
        Write-ColorOutput "✅ Created .devcontainer directory" "Green"
    }
    
    return $ProjectPath
}

function Copy-DevContainerFiles {
    param(
        [string]$SourcePath,
        [string]$DestinationPath,
        [switch]$Force
    )
    
    Write-ColorOutput "📋 Copying DevContainer configuration files..." "Cyan"
    
    $devcontainerSource = Join-Path $SourcePath ".devcontainer"
    $devcontainerDest = Join-Path $DestinationPath ".devcontainer"
    
    if (-not (Test-Path $devcontainerSource)) {
        throw "DevContainer template not found at: $devcontainerSource"
    }
    
    # Check if destination already exists and handle force flag
    if ((Test-Path $devcontainerDest) -and -not $Force) {
        Write-ColorOutput "⚠️  DevContainer configuration already exists. Use -Force to overwrite." "Yellow"
        return $false
    }
    
    try {
        # Copy all DevContainer files
        Copy-Item -Path "$devcontainerSource\*" -Destination $devcontainerDest -Recurse -Force
        Write-ColorOutput "✅ DevContainer files copied successfully" "Green"
        return $true
    }
    catch {
        Write-ColorOutput "❌ Failed to copy DevContainer files: $($_.Exception.Message)" "Red"
        throw
    }
}

function New-DevContainerEnv {
    param(
        [string]$ProjectPath,
        [string]$TenantId,
        [string]$SubscriptionId,
        [string]$ClientId = "",
        [string]$Environment = "dev",
        [string]$Location = "eastus",
        [hashtable]$BackendConfig = $null
    )
    
    Write-ColorOutput "🔧 Creating DevContainer environment configuration..." "Cyan"
    
    $envPath = Join-Path $ProjectPath ".devcontainer\devcontainer.env"
    
    $envContent = @"
# Azure Configuration
AZURE_TENANT_ID=$TenantId
AZURE_SUBSCRIPTION_ID=$SubscriptionId
"@
    
    if ($ClientId) {
        $envContent += "`nAZURE_CLIENT_ID=$ClientId"
    }
    
    $envContent += @"

# Project Configuration
ENVIRONMENT=$Environment
AZURE_LOCATION=$Location
"@
    
    if ($BackendConfig) {
        $envContent += @"

# Terraform Backend Configuration
TF_BACKEND_SUBSCRIPTION_ID=$($BackendConfig.SubscriptionId)
TF_BACKEND_RESOURCE_GROUP=$($BackendConfig.ResourceGroup)
TF_BACKEND_STORAGE_ACCOUNT=$($BackendConfig.StorageAccount)
TF_BACKEND_CONTAINER=$($BackendConfig.Container)
"@
    }
    
    try {
        Set-Content -Path $envPath -Value $envContent -Encoding UTF8
        Write-ColorOutput "✅ Environment configuration created: .devcontainer\devcontainer.env" "Green"
        
        # Show environment file content for verification
        Write-ColorOutput "`n📋 Environment Configuration:" "White"
        $envContent.Split("`n") | ForEach-Object {
            if ($_ -and -not $_.StartsWith("#")) {
                Write-ColorOutput "   $_" "Gray"
            }
        }
        
        return $true
    }
    catch {
        Write-ColorOutput "❌ Failed to create environment file: $($_.Exception.Message)" "Red"
        throw
    }
}

Export-ModuleMember -Function Initialize-ProjectDirectory, Copy-DevContainerFiles, New-DevContainerEnv
