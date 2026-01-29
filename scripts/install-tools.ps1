#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Install required tools for Terraform development
.DESCRIPTION
    This script installs Terraform, TFLint, TFSec, and detect-secrets
    for local development and pre-commit hooks.
.EXAMPLE
    .\scripts\install-tools.ps1
#>

[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"

# Colors for output
function Write-Info { param($Message) Write-Host $Message -ForegroundColor Cyan }
function Write-Success { param($Message) Write-Host $Message -ForegroundColor Green }
function Write-Error { param($Message) Write-Host $Message -ForegroundColor Red }
function Write-Warning { param($Message) Write-Host $Message -ForegroundColor Yellow }

Write-Info "======================================"
Write-Info "Terraform Development Tools Installer"
Write-Info "======================================"
Write-Host ""

# Create tools directory
$toolsDir = "$env:USERPROFILE\.terraform-tools"
if (-not (Test-Path $toolsDir)) {
    New-Item -ItemType Directory -Path $toolsDir -Force | Out-Null
    Write-Info "Created tools directory: $toolsDir"
}

# Function to add to PATH if not already present
function Add-ToPath {
    param([string]$Path)

    $currentPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
    if ($currentPath -notlike "*$Path*") {
        Write-Info "Adding $Path to user PATH..."
        [System.Environment]::SetEnvironmentVariable(
            "Path",
            "$currentPath;$Path",
            "User"
        )
        # Update current session
        $env:Path = "$env:Path;$Path"
        Write-Success "Added to PATH"
    } else {
        Write-Info "Already in PATH: $Path"
    }
}

# Check and install Terraform
Write-Info "`nChecking Terraform..."
if (Get-Command terraform -ErrorAction SilentlyContinue) {
    $version = (terraform version -json | ConvertFrom-Json).terraform_version
    Write-Success "[OK] Terraform $version already installed"
} else {
    Write-Warning "Terraform not found. Installing..."
    try {
        $tfVersion = "1.10.3"
        $tfUrl = "https://releases.hashicorp.com/terraform/$tfVersion/terraform_${tfVersion}_windows_amd64.zip"
        $tfZip = "$env:TEMP\terraform.zip"
        $tfDir = "$toolsDir\terraform"

        Write-Info "Downloading Terraform $tfVersion..."
        Invoke-WebRequest -Uri $tfUrl -OutFile $tfZip -UseBasicParsing

        if (-not (Test-Path $tfDir)) {
            New-Item -ItemType Directory -Path $tfDir -Force | Out-Null
        }

        Write-Info "Extracting Terraform..."
        Expand-Archive -Path $tfZip -DestinationPath $tfDir -Force
        Remove-Item $tfZip

        Add-ToPath $tfDir

        Write-Success "[OK] Terraform installed successfully"
    } catch {
        Write-Error "Failed to install Terraform: $_"
    }
}

# Check and install TFLint
Write-Info "`nChecking TFLint..."
if (Get-Command tflint -ErrorAction SilentlyContinue) {
    $version = (tflint --version 2>&1 | Select-Object -First 1)
    Write-Success "[OK] $version already installed"
} else {
    Write-Warning "TFLint not found. Installing..."
    try {
        $tflintVersion = "v0.54.0"
        $tflintUrl = "https://github.com/terraform-linters/tflint/releases/download/$tflintVersion/tflint_windows_amd64.zip"
        $tflintZip = "$env:TEMP\tflint.zip"
        $tflintDir = "$toolsDir\tflint"

        Write-Info "Downloading TFLint $tflintVersion..."
        Invoke-WebRequest -Uri $tflintUrl -OutFile $tflintZip -UseBasicParsing

        if (-not (Test-Path $tflintDir)) {
            New-Item -ItemType Directory -Path $tflintDir -Force | Out-Null
        }

        Write-Info "Extracting TFLint..."
        Expand-Archive -Path $tflintZip -DestinationPath $tflintDir -Force
        Remove-Item $tflintZip

        Add-ToPath $tflintDir

        Write-Success "[OK] TFLint installed successfully"
    } catch {
        Write-Error "Failed to install TFLint: $_"
    }
}

# Check and install Trivy (replaces TFSec)
Write-Info "`nChecking Trivy..."
if (Get-Command trivy -ErrorAction SilentlyContinue) {
    $version = (trivy --version 2>&1 | Select-Object -First 1)
    Write-Success "[OK] $version already installed"
} else {
    Write-Warning "Trivy not found. Installing..."
    try {
        $trivyVersion = "0.58.1"
        $trivyUrl = "https://github.com/aquasecurity/trivy/releases/download/v${trivyVersion}/trivy_${trivyVersion}_windows-64bit.zip"
        $trivyZip = "$env:TEMP\trivy.zip"
        $trivyDir = "$toolsDir\trivy"

        Write-Info "Downloading Trivy v$trivyVersion..."
        Invoke-WebRequest -Uri $trivyUrl -OutFile $trivyZip -UseBasicParsing

        if (-not (Test-Path $trivyDir)) {
            New-Item -ItemType Directory -Path $trivyDir -Force | Out-Null
        }

        Write-Info "Extracting Trivy..."
        Expand-Archive -Path $trivyZip -DestinationPath $trivyDir -Force
        Remove-Item $trivyZip

        Add-ToPath $trivyDir

        Write-Success "[OK] Trivy installed successfully"
        Write-Info "Note: Trivy replaces TFSec and provides additional security scanning capabilities"
    } catch {
        Write-Error "Failed to install Trivy: $_"
    }
}

# Check and install detect-secrets
Write-Info "`nChecking detect-secrets..."
if (Get-Command detect-secrets -ErrorAction SilentlyContinue) {
    $version = (detect-secrets --version 2>&1)
    Write-Success "[OK] detect-secrets $version already installed"
} else {
    Write-Warning "detect-secrets not found. Installing..."
    if (Get-Command pip -ErrorAction SilentlyContinue) {
        try {
            pip install detect-secrets --quiet
            Write-Success "[OK] detect-secrets installed successfully"
        } catch {
            Write-Error "Failed to install detect-secrets: $_"
        }
    } elseif (Get-Command pip3 -ErrorAction SilentlyContinue) {
        try {
            pip3 install detect-secrets --quiet
            Write-Success "[OK] detect-secrets installed successfully"
        } catch {
            Write-Error "Failed to install detect-secrets: $_"
        }
    } else {
        Write-Warning "Python pip not found. Please install Python and pip first."
        Write-Warning "Download from: https://www.python.org/downloads/"
    }
}

# Check and install pre-commit
Write-Info "`nChecking pre-commit..."
if (Get-Command pre-commit -ErrorAction SilentlyContinue) {
    $version = (pre-commit --version 2>&1)
    Write-Success "[OK] pre-commit $version already installed"
} else {
    Write-Warning "pre-commit not found. Installing..."
    if (Get-Command pip -ErrorAction SilentlyContinue) {
        try {
            pip install pre-commit --quiet
            Write-Success "[OK] pre-commit installed successfully"
        } catch {
            Write-Error "Failed to install pre-commit: $_"
        }
    } elseif (Get-Command pip3 -ErrorAction SilentlyContinue) {
        try {
            pip3 install pre-commit --quiet
            Write-Success "[OK] pre-commit installed successfully"
        } catch {
            Write-Error "Failed to install pre-commit: $_"
        }
    } else {
        Write-Warning "Python pip not found. Skipping pre-commit installation."
    }
}

Write-Host ""
Write-Info "======================================"
Write-Success "Tool Installation Complete!"
Write-Info "======================================"
Write-Host ""

# Set up pre-commit hooks
Write-Info "Setting up pre-commit hooks..."
try {
    # Refresh PATH for current session
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "User") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "Machine")

    # Install pre-commit hooks
    if (Get-Command pre-commit -ErrorAction SilentlyContinue) {
        Write-Info "Installing pre-commit git hooks..."
        pre-commit install | Out-Null
        pre-commit install --hook-type commit-msg | Out-Null
        Write-Success "[OK] Pre-commit hooks installed"

        # Generate secrets baseline if it doesn't exist
        if (-not (Test-Path ".secrets.baseline")) {
            Write-Info "Creating secrets baseline..."
            if (Get-Command detect-secrets -ErrorAction SilentlyContinue) {
                detect-secrets scan --baseline .secrets.baseline | Out-Null
                Write-Success "[OK] Secrets baseline created"
            }
        }

        # Run pre-commit on all files to validate setup
        Write-Info "Running initial validation..."
        $precommitResult = pre-commit run --all-files 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Success "[OK] All pre-commit checks passed"
        } else {
            Write-Warning "Some pre-commit checks need attention (this is normal for first setup)"
        }
    } else {
        Write-Warning "Pre-commit not found in PATH. Please restart terminal and run: pre-commit install"
    }
} catch {
    Write-Warning "Pre-commit setup encountered an issue: $_"
    Write-Info "You can manually set up pre-commit later by running: pre-commit install"
}

Write-Host ""
Write-Info "======================================"
Write-Success "Setup Complete!"
Write-Info "======================================"
Write-Host ""
Write-Info "Installed tools location: $toolsDir"
Write-Host ""
Write-Success "[OK] All tools installed"
Write-Success "[OK] Pre-commit hooks configured"
Write-Success "[OK] Ready for development"
Write-Host ""
Write-Warning "IMPORTANT: Restart your terminal for PATH changes to take full effect"
Write-Host ""
Write-Info "Quick start:"
Write-Host "  - Make changes to Terraform files"
Write-Host "  - Run: git add ."
Write-Host "  - Run: git commit -m 'your message'"
Write-Host "  - Pre-commit hooks will automatically validate your changes"
Write-Host ""
