#Requires -Version 5.1

<#
.SYNOPSIS
    Azure management functions for Infrastructure as Code development.

.DESCRIPTION
    This module provides Azure-specific functionality including authentication,
    storage account management, and Terraform backend configuration for DevContainer environments.
#>

Import-Module -Name (Join-Path $PSScriptRoot "CommonModule.psm1") -Force

function Test-AzureAuthentication {
    param([string]$SubscriptionId)
    
    try {
        # Check if Azure CLI is available
        $null = Get-Command az -ErrorAction Stop
        
        # Check if logged in
        $accountInfo = az account show --output json 2>$null | ConvertFrom-Json
        if (-not $accountInfo) {
            throw "Not authenticated with Azure CLI. Please run 'az login'"
        }
        
        # Switch to specified subscription if provided
        if ($SubscriptionId -and $accountInfo.id -ne $SubscriptionId) {
            Write-ColorOutput "🔄 Switching to subscription: $SubscriptionId" "Cyan"
            az account set --subscription $SubscriptionId
            if ($LASTEXITCODE -ne 0) {
                throw "Failed to switch to subscription: $SubscriptionId"
            }
        }
        
        return $accountInfo
    }
    catch {
        throw "Azure authentication failed: $($_.Exception.Message)"
    }
}

function Test-AzureStorageAccount {
    param(
        [string]$StorageAccountName,
        [string]$ResourceGroupName,
        [string]$SubscriptionId
    )
    
    # Validate required parameters
    if ([string]::IsNullOrWhiteSpace($StorageAccountName)) {
        throw "StorageAccountName parameter is required and cannot be empty"
    }
    if ([string]::IsNullOrWhiteSpace($ResourceGroupName)) {
        throw "ResourceGroupName parameter is required and cannot be empty"
    }
    if ([string]::IsNullOrWhiteSpace($SubscriptionId)) {
        throw "SubscriptionId parameter is required and cannot be empty"
    }
    
    try {
        $null = Test-AzureAuthentication -SubscriptionId $SubscriptionId
        
        Write-ColorOutput "🔍 Checking if storage account '$StorageAccountName' exists..." "Cyan"
        
        $storageAccount = az storage account show --name $StorageAccountName --resource-group $ResourceGroupName --output json 2>$null
        if ($LASTEXITCODE -eq 0 -and $storageAccount) {
            $storageInfo = $storageAccount | ConvertFrom-Json
            Write-ColorOutput "✅ Storage account found: $($storageInfo.name)" "Green"
            return @{
                Exists = $true
                StorageAccount = $storageInfo
            }
        }
        else {
            Write-ColorOutput "⚠️  Storage account '$StorageAccountName' not found" "Yellow"
            return @{
                Exists = $false
                StorageAccount = $null
            }
        }
    }
    catch {
        throw "Failed to check storage account: $($_.Exception.Message)"
    }
}

function Test-AzureStorageContainer {
    param(
        [string]$StorageAccountName,
        [string]$ContainerName,
        [string]$ResourceGroupName,
        [string]$SubscriptionId
    )
    
    # Validate required parameters
    if ([string]::IsNullOrWhiteSpace($StorageAccountName)) {
        throw "StorageAccountName parameter is required and cannot be empty"
    }
    if ([string]::IsNullOrWhiteSpace($ContainerName)) {
        throw "ContainerName parameter is required and cannot be empty"
    }
    if ([string]::IsNullOrWhiteSpace($ResourceGroupName)) {
        throw "ResourceGroupName parameter is required and cannot be empty"
    }
    if ([string]::IsNullOrWhiteSpace($SubscriptionId)) {
        throw "SubscriptionId parameter is required and cannot be empty"
    }
    
    try {
        $null = Test-AzureAuthentication -SubscriptionId $SubscriptionId
        
        Write-ColorOutput "🔍 Checking if container '$ContainerName' exists in storage account '$StorageAccountName'..." "Cyan"
        
        # Get storage account keys
        $keysResult = az storage account keys list --account-name $StorageAccountName --resource-group $ResourceGroupName --output json
        if ($LASTEXITCODE -ne 0) {
            Write-ColorOutput "❌ Failed to get storage account keys" "Red"
            throw "Failed to retrieve storage account keys"
        }
        
        $keys = $keysResult | ConvertFrom-Json
        if (-not $keys -or $keys.Count -eq 0) {
            throw "No storage account keys found"
        }
        $storageKey = $keys[0].value
        
        # Check container existence with better error handling
        $containerResult = az storage container show --name $ContainerName --account-name $StorageAccountName --account-key $storageKey --output json 2>$null
        
        if ($LASTEXITCODE -eq 0 -and $containerResult -and $containerResult.Trim() -ne "") {
            try {
                $containerInfo = $containerResult | ConvertFrom-Json
                if ($containerInfo -and $containerInfo.name) {
                    Write-ColorOutput "✅ Container found: $($containerInfo.name)" "Green"
                    return @{
                        Exists = $true
                        Container = $containerInfo
                    }
                }
            }
            catch {
                Write-ColorOutput "⚠️  Failed to parse container info, treating as not found" "Yellow"
            }
        } else {
            # Check if this might be a network access issue
            $errorOutput = az storage container show --name $ContainerName --account-name $StorageAccountName --account-key $storageKey 2>&1
            if ($errorOutput -match "network|access|firewall|private") {
                Write-ColorOutput "⚠️  Container check failed - possibly due to network restrictions" "Yellow"
                Write-ColorOutput "ℹ️  Storage account may have public access disabled or firewall rules" "Gray"
                return @{
                    Exists = $null  # Unknown due to network restrictions
                    Container = $null
                    NetworkRestricted = $true
                }
            }
        }
        
        Write-ColorOutput "⚠️  Container '$ContainerName' not found" "Yellow"
        return @{
            Exists = $false
            Container = $null
        }
    }
    catch {
        Write-ColorOutput "⚠️  Failed to check storage container: $($_.Exception.Message)" "Yellow"
        Write-ColorOutput "ℹ️  This might be due to network access restrictions on the storage account" "Gray"
        return @{
            Exists = $null
            Container = $null
            NetworkRestricted = $true
            Error = $_.Exception.Message
        }
    }
}

function Test-AzureStorageAccountAvailability {
    param([string]$StorageAccountName)
    
    try {
        $result = az storage account check-name --name $StorageAccountName --output json 2>$null
        if ($LASTEXITCODE -eq 0 -and $result) {
            $checkResult = $result | ConvertFrom-Json
            return @{
                Available = $checkResult.nameAvailable
                Reason = $checkResult.reason
                Message = $checkResult.message
            }
        }
        return @{ Available = $false; Reason = "CheckFailed"; Message = "Unable to check availability" }
    }
    catch {
        return @{ Available = $false; Reason = "Error"; Message = $_.Exception.Message }
    }
}

function New-AzureStorageAccountName {
    param(
        [string]$ProjectName,
        [string]$Environment = "dev",
        [string]$Purpose = "tfstate"
    )
    
    # Clean project name - only lowercase letters and numbers
    $cleanProjectName = $ProjectName.ToLower() -replace '[^a-z0-9]', ''
    $cleanEnvironment = $Environment.ToLower() -replace '[^a-z0-9]', ''
    $cleanPurpose = $Purpose.ToLower() -replace '[^a-z0-9]', ''
    
    # Generate a short hash for uniqueness (8 characters) - deterministic based on input
    $uniqueString = "$ProjectName-$Environment-$Purpose"
    $hash = [System.Security.Cryptography.HashAlgorithm]::Create('SHA256').ComputeHash([System.Text.Encoding]::UTF8.GetBytes($uniqueString))
    $shortHash = [Convert]::ToHexString($hash)[0..7] -join '' | ForEach-Object { $_.ToLower() }
    
    # Calculate available space for project name (24 total - hash - environment - purpose)
    $maxProjectLength = 24 - $shortHash.Length - $cleanEnvironment.Length - $cleanPurpose.Length
    if ($maxProjectLength -le 0) {
        # If not enough space, prioritize hash for uniqueness
        $maxProjectLength = 24 - $shortHash.Length - 3 # Reserve 3 chars minimum
        $cleanProjectName = $cleanProjectName.Substring(0, [Math]::Min($cleanProjectName.Length, $maxProjectLength))
        $storageAccountName = "$cleanProjectName$shortHash"
    } else {
        $cleanProjectName = $cleanProjectName.Substring(0, [Math]::Min($cleanProjectName.Length, $maxProjectLength))
        $storageAccountName = "$cleanProjectName$cleanEnvironment$cleanPurpose$shortHash"
    }
    
    # Ensure we don't exceed 24 characters
    if ($storageAccountName.Length -gt 24) {
        $storageAccountName = $storageAccountName.Substring(0, 24)
    }
    
    # Validate the generated name meets Azure requirements
    if ($storageAccountName.Length -lt 3) {
        throw "Generated storage account name '$storageAccountName' is too short (minimum 3 characters)"
    }
    if ($storageAccountName.Length -gt 24) {
        throw "Generated storage account name '$storageAccountName' is too long (maximum 24 characters)"
    }
    if ($storageAccountName -notmatch '^[a-z0-9]+$') {
        throw "Generated storage account name '$storageAccountName' contains invalid characters (only lowercase letters and numbers allowed)"
    }
    
    # Check availability and try alternatives if needed
    $finalStorageAccountName = $storageAccountName
    $availability = Test-AzureStorageAccountAvailability -StorageAccountName $finalStorageAccountName
    $attempt = 1
    
    while (-not $availability.Available -and $attempt -le 5) {
        if ($availability.Reason -eq "AlreadyExists") {
            # Try with a numeric suffix
            $suffix = $attempt.ToString().PadLeft(2, '0')
            $baseName = $storageAccountName.Substring(0, [Math]::Min($storageAccountName.Length, 22))
            $finalStorageAccountName = "$baseName$suffix"
            $availability = Test-AzureStorageAccountAvailability -StorageAccountName $finalStorageAccountName
            $attempt++
        } else {
            # Other errors (invalid name, etc.) - can't fix automatically
            break
        }
    }
    
    return @{
        StorageAccountName = $finalStorageAccountName
        DisplayName = "$ProjectName-$Environment-$Purpose"
        ProjectName = $ProjectName
        Environment = $Environment
        Purpose = $Purpose
        Available = $availability.Available
        AvailabilityMessage = $availability.Message
    }
}

function New-AzureTerraformBackend {
    param(
        [string]$StorageAccountName,
        [string]$ResourceGroupName,
        [string]$ContainerName,
        [string]$Location,
        [string]$SubscriptionId,
        [switch]$CreateResourceGroup,
        [string]$DisplayName = "",
        [string]$ProjectName = "",
        [string]$Environment = "",
        [string]$Purpose = "tfstate"
    )
      try {
        $null = Test-AzureAuthentication -SubscriptionId $SubscriptionId
        
        Write-ColorOutput "🏗️  Creating Terraform backend infrastructure..." "Magenta"
        
        # Check/Create Resource Group
        if ($CreateResourceGroup) {
            Write-ColorOutput "📁 Creating resource group '$ResourceGroupName'..." "Cyan"
            $rgResult = az group create --name $ResourceGroupName --location $Location --output json
            if ($LASTEXITCODE -ne 0) {
                throw "Failed to create resource group"
            }
            
            if ([string]::IsNullOrWhiteSpace($rgResult)) {
                throw "Azure CLI returned empty result when creating resource group"
            }
            
            try {
                $resourceGroup = $rgResult | ConvertFrom-Json
                if (-not $resourceGroup -or -not $resourceGroup.name) {
                    throw "Resource group creation returned invalid response"
                }
                Write-ColorOutput "✅ Resource group created: $($resourceGroup.name)" "Green"
            }
            catch {
                Write-ColorOutput "❌ Failed to parse resource group creation response: $rgResult" "Red"
                throw "Failed to parse Azure CLI response for resource group creation"
            }
        }
        else {
            # Check if resource group exists
            $null = az group show --name $ResourceGroupName --output json 2>$null
            if ($LASTEXITCODE -ne 0) {
                throw "Resource group '$ResourceGroupName' does not exist. Use -CreateResourceGroup to create it."
            }
        }
        
        # Check if storage account already exists
        $storageCheck = Test-AzureStorageAccount -StorageAccountName $StorageAccountName -ResourceGroupName $ResourceGroupName -SubscriptionId $SubscriptionId
        
        if (-not $storageCheck.Exists) {
            Write-ColorOutput "💾 Creating storage account '$StorageAccountName'..." "Cyan"
            
            # Build tags for the storage account
            $tags = @()
            if ($DisplayName) { $tags += "DisplayName=$DisplayName" }
            if ($ProjectName) { $tags += "ProjectName=$ProjectName" }
            if ($Environment) { $tags += "Environment=$Environment" }
            if ($Purpose) { $tags += "Purpose=$Purpose" }
            $tags += "CreatedBy=DevContainer-Template"
            $tags += "CreatedDate=$(Get-Date -Format 'yyyy-MM-dd')"
            
            $storageResult = az storage account create `
                --name $StorageAccountName `
                --resource-group $ResourceGroupName `
                --location $Location `
                --sku Standard_LRS `
                --kind StorageV2 `
                --access-tier Hot `
                --encryption-services blob `
                --https-only true `
                --min-tls-version TLS1_2 `
                --allow-blob-public-access false `
                --tags $tags `
                --output json
                
            if ($LASTEXITCODE -ne 0) {
                throw "Failed to create storage account"
            }
            
            if ([string]::IsNullOrWhiteSpace($storageResult)) {
                throw "Azure CLI returned empty result when creating storage account"
            }
            
            try {
                $storageAccount = $storageResult | ConvertFrom-Json
                if (-not $storageAccount -or -not $storageAccount.name) {
                    throw "Storage account creation returned invalid response"
                }
                Write-ColorOutput "✅ Storage account created: $($storageAccount.name)" "Green"
            }
            catch {
                Write-ColorOutput "❌ Failed to parse storage account creation response: $storageResult" "Red"
                throw "Failed to parse Azure CLI response for storage account creation"
            }
        }
        else {
            Write-ColorOutput "✅ Using existing storage account: $StorageAccountName" "Green"
            $storageAccount = $storageCheck.StorageAccount
            
            # Update tags on existing storage account
            Write-ColorOutput "🏷️  Updating storage account tags..." "Cyan"
            
            # Build tags for the existing storage account (same format as creation)
            $updateTags = @()
            if ($DisplayName) { $updateTags += "DisplayName=$DisplayName" }
            if ($ProjectName) { $updateTags += "ProjectName=$ProjectName" }
            if ($Environment) { $updateTags += "Environment=$Environment" }
            if ($Purpose) { $updateTags += "Purpose=$Purpose" }
            $updateTags += "CreatedBy=DevContainer-Template"
            $updateTags += "UpdatedDate=$(Get-Date -Format 'yyyy-MM-dd')"
            
            $updateResult = az storage account update `
                --name $StorageAccountName `
                --resource-group $ResourceGroupName `
                --tags @updateTags `
                --output json
                
            if ($LASTEXITCODE -eq 0) {
                Write-ColorOutput "✅ Storage account tags updated successfully" "Green"
            } else {
                Write-ColorOutput "⚠️  Failed to update storage account tags" "Yellow"
                Write-ColorOutput "ℹ️  Update result: $updateResult" "Gray"
            }
        }
        
        # Check/Create Container
        $containerCheck = Test-AzureStorageContainer -StorageAccountName $StorageAccountName -ContainerName $ContainerName -ResourceGroupName $ResourceGroupName -SubscriptionId $SubscriptionId
        
        if ($containerCheck.NetworkRestricted) {
            Write-ColorOutput "⚠️  Cannot verify container existence due to network restrictions" "Yellow"
            Write-ColorOutput "ℹ️  Please ensure the '$ContainerName' container exists in your storage account" "Gray"
            Write-ColorOutput "ℹ️  You can create it manually in the Azure portal if needed" "Gray"
        }
        elseif (-not $containerCheck.Exists) {
            Write-ColorOutput "📦 Creating storage container '$ContainerName'..." "Cyan"
            
            $keys = az storage account keys list --account-name $StorageAccountName --resource-group $ResourceGroupName --output json | ConvertFrom-Json
            $storageKey = $keys[0].value
            
            $containerCreateResult = az storage container create `
                --name $ContainerName `
                --account-name $StorageAccountName `
                --account-key $storageKey `
                --public-access off `
                --output json 2>&1
                
            if ($LASTEXITCODE -eq 0) {
                Write-ColorOutput "✅ Storage container created: $ContainerName" "Green"
            } else {
                Write-ColorOutput "⚠️  Failed to create container - possibly due to network restrictions" "Yellow"
                Write-ColorOutput "ℹ️  Error: $containerCreateResult" "Gray"
                Write-ColorOutput "ℹ️  You may need to create the container manually: $ContainerName" "Gray"
                Write-ColorOutput "ℹ️  Consider temporarily enabling public access or using a private endpoint" "Gray"
            }
        }
        else {
            Write-ColorOutput "✅ Using existing storage container: $ContainerName" "Green"
        }
        
        # Enable versioning for better state management
        Write-ColorOutput "🔧 Configuring storage account settings..." "Cyan"
        az storage account blob-service-properties update `
            --account-name $StorageAccountName `
            --resource-group $ResourceGroupName `
            --enable-versioning true `
            --enable-delete-retention true `
            --delete-retention-days 30 `
            --output none
            
        if ($LASTEXITCODE -eq 0) {
            Write-ColorOutput "✅ Enabled blob versioning and soft delete" "Green"
        }
        
        return @{
            Success = $true
            StorageAccount = $StorageAccountName
            ResourceGroup = $ResourceGroupName
            Container = $ContainerName
            Location = $Location
        }
    }
    catch {
        Write-ColorOutput "❌ Failed to create Terraform backend: $($_.Exception.Message)" "Red"
        throw
    }
}

function Test-TerraformBackend {
    param(
        [string]$StorageAccountName,
        [string]$ResourceGroupName,
        [string]$ContainerName,
        [string]$SubscriptionId
    )
      try {
        $null = Test-AzureAuthentication -SubscriptionId $SubscriptionId
        
        Write-ColorOutput "🔍 Validating Terraform backend configuration..." "Cyan"
        
        # Check storage account
        $storageCheck = Test-AzureStorageAccount -StorageAccountName $StorageAccountName -ResourceGroupName $ResourceGroupName -SubscriptionId $SubscriptionId
        if (-not $storageCheck.Exists) {
            return @{
                Valid = $false
                Message = "Storage account $StorageAccountName not found in resource group $ResourceGroupName"
            }
        }
        
        # Check container
        $containerCheck = Test-AzureStorageContainer -StorageAccountName $StorageAccountName -ContainerName $ContainerName -ResourceGroupName $ResourceGroupName -SubscriptionId $SubscriptionId
        if (-not $containerCheck.Exists) {
            return @{
                Valid = $false
                Message = "Container $ContainerName not found in storage account $StorageAccountName"
            }
        }
        
        Write-ColorOutput "✅ Terraform backend validation successful" "Green"
        return @{
            Valid = $true
            Message = "Backend configuration is valid"
        }
    }
    catch {
        return @{
            Valid = $false
            Message = "Backend validation failed: $($_.Exception.Message)"
        }
    }
}

Export-ModuleMember -Function Test-AzureAuthentication, Test-AzureStorageAccount, Test-AzureStorageContainer, Test-AzureStorageAccountAvailability, New-AzureStorageAccountName, New-AzureTerraformBackend, Test-TerraformBackend
