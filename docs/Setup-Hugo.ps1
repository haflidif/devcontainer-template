#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Sets up Hugo development environment for the DevContainer Template documentation.

.DESCRIPTION
    This script initializes the Hugo development environment, installs dependencies,
    and prepares the documentation site for local development.

.PARAMETER Install
    Install Hugo and required dependencies.

.PARAMETER Serve
    Start the Hugo development server.

.PARAMETER Build
    Build the documentation site for production.

.PARAMETER Clean
    Clean build artifacts and caches.

.PARAMETER Update
    Update Hugo modules and dependencies.

.EXAMPLE
    .\Setup-Hugo.ps1 -Install
    Installs Hugo and dependencies.

.EXAMPLE
    .\Setup-Hugo.ps1 -Serve
    Starts the development server.

.EXAMPLE
    .\Setup-Hugo.ps1 -Build
    Builds the site for production.
#>

[CmdletBinding()]
param(
    [switch]$Install,
    [switch]$Serve,
    [switch]$Build,
    [switch]$Clean,
    [switch]$Update
)

# Set error handling
$ErrorActionPreference = "Stop"

# Helper functions - Define these first
function Write-Status {
    param([string]$Message, [string]$Type = "Info")
    
    $color = switch ($Type) {
        "Success" { "Green" }
        "Warning" { "Yellow" }
        "Error" { "Red" }
        default { "Cyan" }
    }
    
    Write-Host "📝 $Message" -ForegroundColor $color
}

function Test-Command {
    param([string]$Command)
    
    try {
        Get-Command $Command -ErrorAction Stop | Out-Null
        return $true
    }
    catch {
        return $false
    }
}

# Configuration
$HugoVersion = "0.147.8"

# Auto-detect correct Hugo directory based on current location
$ScriptDir = $PSScriptRoot
$CurrentDir = Get-Location

# Determine Hugo directory path
if (Test-Path "hugo") {
    # Running from docs directory
    $HugoDir = "hugo"
} elseif (Test-Path "docs/hugo") {
    # Running from repository root
    $HugoDir = "docs/hugo"
} elseif (Test-Path "$ScriptDir/hugo") {
    # Script in docs directory, hugo subfolder
    $HugoDir = "$ScriptDir/hugo"
} else {
    # Try to find hugo directory in common locations
    $PossiblePaths = @(
        "hugo",
        "docs/hugo", 
        "../hugo",
        "./docs/hugo"
    )
    
    $HugoDir = $null
    foreach ($path in $PossiblePaths) {
        if (Test-Path $path) {
            $HugoDir = $path
            break
        }
    }
    
    if (-not $HugoDir) {
        Write-Status "Hugo directory not found. Please run this script from either:" "Error"
        Write-Status "  - Repository root (where docs/hugo exists)" "Error"
        Write-Status "  - docs directory (where hugo subfolder exists)" "Error"
        exit 1
    }
}

$PublicDir = "$HugoDir/public"

Write-Status "Using Hugo directory: $HugoDir" "Info"

function Install-Hugo {
    Write-Status "Installing Hugo..." "Info"
    
    if (Test-Command "hugo") {
        $currentVersion = (hugo version) -replace ".*v(\d+\.\d+\.\d+).*", '$1'
        if ([version]$currentVersion -ge [version]$HugoVersion) {
            Write-Status "Hugo $currentVersion is already installed and up to date." "Success"
            return
        }
    }
    
    if ($IsWindows -or $env:OS -eq "Windows_NT") {
        # Windows installation
        if (Test-Command "choco") {
            Write-Status "Installing Hugo via Chocolatey..." "Info"
            choco install hugo-extended -y
        }
        elseif (Test-Command "winget") {
            Write-Status "Installing Hugo via winget..." "Info"
            winget install Hugo.Hugo.Extended
        }
        else {
            Write-Status "Please install Hugo manually from https://gohugo.io/installation/" "Warning"
            Write-Status "Or install Chocolatey/winget first." "Warning"
            return
        }
    }
    elseif ($IsMacOS) {
        # macOS installation
        if (Test-Command "brew") {
            Write-Status "Installing Hugo via Homebrew..." "Info"
            brew install hugo
        }
        else {
            Write-Status "Please install Homebrew first: https://brew.sh/" "Warning"
            return
        }
    }
    else {
        # Linux installation
        Write-Status "Installing Hugo on Linux..." "Info"
        $downloadUrl = "https://github.com/gohugoio/hugo/releases/download/v$HugoVersion/hugo_extended_${HugoVersion}_linux-amd64.tar.gz"
        
        # Create temporary directory
        $tempDir = [System.IO.Path]::GetTempPath() + "hugo-install"
        New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
        
        try {
            # Download and extract
            $archive = "$tempDir/hugo.tar.gz"
            Invoke-WebRequest -Uri $downloadUrl -OutFile $archive
            tar -xzf $archive -C $tempDir
            
            # Install to /usr/local/bin
            $installDir = "/usr/local/bin"
            if (Test-Path "$tempDir/hugo") {
                sudo cp "$tempDir/hugo" $installDir/
                sudo chmod +x "$installDir/hugo"
                Write-Status "Hugo installed to $installDir/hugo" "Success"
            }
        }
        finally {
            # Cleanup
            Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
    
    # Verify installation
    if (Test-Command "hugo") {
        $installedVersion = hugo version
        Write-Status "Hugo installed successfully: $installedVersion" "Success"
    }
    else {
        Write-Status "Hugo installation failed. Please install manually." "Error"
        exit 1
    }
}

function Install-Dependencies {
    Write-Status "Installing dependencies..." "Info"
    
    # Change to Hugo directory (path already validated in main script)
    Push-Location $HugoDir
    
    try {
        # Initialize Hugo modules if not already done
        if (-not (Test-Path "go.mod")) {
            Write-Status "Initializing Hugo modules..." "Info"
            hugo mod init github.com/haflidif/devcontainer-template
        }
        
        # Get Hugo modules
        Write-Status "Downloading Hugo modules..." "Info"
        hugo mod get github.com/google/docsy@v0.7.2
        hugo mod get github.com/google/docsy/dependencies@v0.7.2
        hugo mod tidy
        
        # Install Node.js dependencies if package.json exists
        if (Test-Path "package.json") {
            if (Test-Command "npm") {
                Write-Status "Installing Node.js dependencies..." "Info"
                npm install
            }
            else {
                Write-Status "npm not found. Please install Node.js to install theme dependencies." "Warning"
            }
        }
        
        Write-Status "Dependencies installed successfully." "Success"
    }
    finally {
        Pop-Location
    }
}

function Start-HugoServer {
    Write-Status "Starting Hugo development server..." "Info"
    
    Push-Location $HugoDir
    
    try {
        Write-Status "Server will be available at: http://localhost:1313" "Info"
        Write-Status "Press Ctrl+C to stop the server." "Info"
        
        # Start Hugo server with live reload
        hugo server --buildDrafts --buildFuture --bind "0.0.0.0" --port 1313
    }
    finally {
        Pop-Location
    }
}

function Build-Site {
    Write-Status "Building Hugo site for production..." "Info"
    
    if (-not (Test-Path $HugoDir)) {
        Write-Status "Hugo directory not found: $HugoDir" "Error"
        exit 1
    }
    
    Push-Location $HugoDir
    
    try {
        # Clean previous build
        if (Test-Path "public") {
            Remove-Item -Path "public" -Recurse -Force
            Write-Status "Cleaned previous build artifacts." "Info"
        }
        
        # Build the site
        Write-Status "Building site..." "Info"
        $env:HUGO_ENVIRONMENT = "production"
        $env:HUGO_ENV = "production"
        
        hugo --gc --minify
        
        if ($LASTEXITCODE -eq 0) {
            Write-Status "Site built successfully in public/ directory." "Success"
            
            # Show build statistics
            $publicPath = Resolve-Path "public"
            $fileCount = (Get-ChildItem -Path $publicPath -Recurse -File).Count
            $totalSize = (Get-ChildItem -Path $publicPath -Recurse -File | Measure-Object -Property Length -Sum).Sum
            $sizeMB = [math]::Round($totalSize / 1MB, 2)
            
            Write-Status "Build statistics:" "Info"
            Write-Status "  Files: $fileCount" "Info"
            Write-Status "  Total size: $sizeMB MB" "Info"
            Write-Status "  Output directory: $publicPath" "Info"
        }
        else {
            Write-Status "Build failed with exit code: $LASTEXITCODE" "Error"
            exit $LASTEXITCODE
        }
    }
    finally {
        Pop-Location
    }
}

function Clean-Environment {
    Write-Status "Cleaning Hugo environment..." "Info"
    
    Push-Location $HugoDir -ErrorAction SilentlyContinue
    
    try {
        # Clean build artifacts
        $itemsToClean = @("public", "resources", ".hugo_build.lock", "node_modules")
        
        foreach ($item in $itemsToClean) {
            if (Test-Path $item) {
                Remove-Item -Path $item -Recurse -Force
                Write-Status "Removed: $item" "Info"
            }
        }
        
        # Clean Hugo modules cache
        if (Test-Command "hugo") {
            hugo mod clean
            Write-Status "Cleaned Hugo modules cache." "Info"
        }
        
        # Clean npm cache if npm is available
        if (Test-Command "npm") {
            npm cache clean --force
            Write-Status "Cleaned npm cache." "Info"
        }
        
        Write-Status "Environment cleaned successfully." "Success"
    }
    finally {
        Pop-Location
    }
}

function Update-Dependencies {
    Write-Status "Updating Hugo dependencies..." "Info"
    
    Push-Location $HugoDir
    
    try {
        # Update Hugo modules
        if (Test-Command "hugo") {
            Write-Status "Updating Hugo modules..." "Info"
            hugo mod get -u
            hugo mod tidy
        }
        
        # Update Node.js dependencies
        if ((Test-Path "package.json") -and (Test-Command "npm")) {
            Write-Status "Updating Node.js dependencies..." "Info"
            npm update
        }
        
        Write-Status "Dependencies updated successfully." "Success"
    }
    finally {
        Pop-Location
    }
}

function Show-Help {
    Write-Host @"
Hugo Documentation Setup Script

USAGE:
    .\Setup-Hugo.ps1 [-Install] [-Serve] [-Build] [-Clean] [-Update]

OPTIONS:
    -Install    Install Hugo and dependencies
    -Serve      Start the Hugo development server
    -Build      Build the site for production
    -Clean      Clean build artifacts and caches
    -Update     Update Hugo modules and dependencies

EXAMPLES:
    .\Setup-Hugo.ps1 -Install
        Install Hugo and set up the development environment

    .\Setup-Hugo.ps1 -Serve
        Start the development server at http://localhost:1313

    .\Setup-Hugo.ps1 -Build
        Build the production site in public/ directory

    .\Setup-Hugo.ps1 -Clean -Install -Serve
        Clean, install dependencies, and start development server

REQUIREMENTS:
    - PowerShell 5.1+ or PowerShell Core 7+
    - Internet connection for downloading dependencies
    - Git (for Hugo modules)
    - Node.js and npm (optional, for theme dependencies)

For more information, see docs/hugo/README.md
"@
}

# Main execution
try {
    Write-Status "DevContainer Template - Hugo Documentation Setup" "Info"
    Write-Status "=============================================" "Info"
    
    # Show help if no parameters provided
    if (-not ($Install -or $Serve -or $Build -or $Clean -or $Update)) {
        Show-Help
        exit 0
    }
    
    # Execute requested actions
    if ($Clean) {
        Clean-Environment
    }
    
    if ($Install) {
        Install-Hugo
        Install-Dependencies
    }
    
    if ($Update) {
        Update-Dependencies
    }
    
    if ($Build) {
        Build-Site
    }
    
    if ($Serve) {
        Start-HugoServer
    }
    
    Write-Status "Setup completed successfully!" "Success"
}
catch {
    Write-Status "Setup failed: $($_.Exception.Message)" "Error"
    Write-Status "Stack trace: $($_.ScriptStackTrace)" "Error"
    exit 1
}
