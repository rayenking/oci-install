#Requires -Version 5.1
<#
.SYNOPSIS
    OCI (OpenCode Iris) Installer for Windows
.DESCRIPTION
    Downloads and installs OCI binary, then runs the setup wizard.
.EXAMPLE
    irm https://raw.githubusercontent.com/rayenking/oci-install/main/install.ps1 | iex
#>

$ErrorActionPreference = 'Stop'

$Repo = 'rayenking/oci'
$BinaryName = 'oci'
$InstallDir = Join-Path $env:LOCALAPPDATA 'oci'

function Write-Banner {
    Write-Host @"

   ____  _____ _____
  / __ \/ ___//  _/
 / / / / /    / /
/ /_/ / /____/ /
\____/\____/___/

OpenCode Iris Installer (Windows)

"@ -ForegroundColor Cyan
}

function Write-Info  { param($msg) Write-Host "[+] $msg" -ForegroundColor Green }
function Write-Warn  { param($msg) Write-Host "[!] $msg" -ForegroundColor Yellow }
function Write-Err   { param($msg) Write-Host "[x] $msg" -ForegroundColor Red; exit 1 }

function Get-Platform {
    $arch = if ([Environment]::Is64BitOperatingSystem) { 'amd64' } else { Write-Err 'OCI requires 64-bit Windows' }
    return "${BinaryName}-windows-${arch}.exe"
}

function Ensure-GH {
    if (Get-Command gh -ErrorAction SilentlyContinue) {
        $ver = (gh --version | Select-Object -First 1)
        Write-Info "GitHub CLI found: $ver"
        return
    }

    Write-Info 'Installing GitHub CLI via winget...'
    try {
        winget install --id GitHub.cli --accept-package-agreements --accept-source-agreements --silent
        $env:PATH = [Environment]::GetEnvironmentVariable('PATH', 'Machine') + ';' + [Environment]::GetEnvironmentVariable('PATH', 'User')
    } catch {
        Write-Warn 'winget install failed. Trying scoop...'
        if (Get-Command scoop -ErrorAction SilentlyContinue) {
            scoop install gh
        } else {
            Write-Err 'Cannot auto-install gh. Install manually: https://cli.github.com'
        }
    }

    if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
        Write-Err 'gh not found after install. Restart terminal and try again.'
    }
}

function Ensure-GHAuth {
    $null = gh auth status 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Info 'GitHub CLI authenticated'
        return
    }

    Write-Warn 'Not logged in to GitHub. Starting login...'
    Write-Host ''
    gh auth login
    Write-Host ''

    $null = gh auth status 2>&1
    if ($LASTEXITCODE -ne 0) { Write-Err 'GitHub auth failed' }
    Write-Info 'GitHub CLI authenticated'
}

function Download-OCI {
    $assetName = Get-Platform

    if (-not (Test-Path $InstallDir)) {
        New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
    }

    $tmpDir = Join-Path $env:TEMP "oci-install-$(Get-Random)"
    New-Item -ItemType Directory -Path $tmpDir -Force | Out-Null

    try {
        Write-Info "Downloading OCI binary ($assetName)..."
        gh release download --repo $Repo --pattern $assetName --dir $tmpDir --clobber 2>&1
        if ($LASTEXITCODE -ne 0) { Write-Err "Failed to download. Make sure you have access to $Repo" }

        $src = Join-Path $tmpDir $assetName
        $dst = Join-Path $InstallDir "${BinaryName}.exe"
        Move-Item -Path $src -Destination $dst -Force

        Write-Info "OCI installed to $dst"
    } finally {
        Remove-Item -Path $tmpDir -Recurse -Force -ErrorAction SilentlyContinue
    }

    # Add to user PATH if not already there
    $userPath = [Environment]::GetEnvironmentVariable('PATH', 'User')
    if ($userPath -notlike "*$InstallDir*") {
        [Environment]::SetEnvironmentVariable('PATH', "$InstallDir;$userPath", 'User')
        $env:PATH = "$InstallDir;$env:PATH"
        Write-Info "Added $InstallDir to user PATH"
    }
}

function Show-Menu {
    $ociPath = Join-Path $InstallDir "${BinaryName}.exe"
    if (Test-Path $ociPath) {
        $ver = & $ociPath version 2>&1
        Write-Host "OCI is already installed. ($ver)" -ForegroundColor White
        Write-Host ''
        Write-Host '  1) Reinstall  - backup sessions, fresh install'
        Write-Host '  2) Update     - update OCI binary to latest'
        Write-Host '  3) Uninstall  - remove everything'
        Write-Host '  4) Cancel'
        Write-Host ''
        $choice = Read-Host 'Choose [1-4]'
        switch ($choice) {
            '1' { return 'reinstall' }
            '2' { return 'update' }
            '3' { return 'uninstall' }
            '4' { Write-Host 'Cancelled.'; exit 0 }
            default { Write-Err 'Invalid choice' }
        }
    }
    return 'install'
}

function Run-Action {
    param($action)
    $ociExe = Join-Path $InstallDir "${BinaryName}.exe"

    switch ($action) {
        'install' {
            Download-OCI
            Write-Host ''
            Write-Info 'Running OCI installer...'
            Write-Host ''
            & $ociExe install
        }
        'reinstall' {
            Download-OCI
            Write-Host ''
            Write-Info 'Running OCI reinstall...'
            Write-Host ''
            & $ociExe reinstall
        }
        'update' {
            Download-OCI
            Write-Info 'OCI binary updated.'
        }
        'uninstall' {
            if (Test-Path $ociExe) {
                & $ociExe uninstall
            } else {
                Write-Err 'OCI is not installed'
            }
        }
    }
}

# Main
Write-Banner
$platform = Get-Platform
Write-Info "Platform: windows/amd64"
Write-Host ''

Ensure-GH
Ensure-GHAuth
Write-Host ''

$action = Show-Menu
Run-Action $action
