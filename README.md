# OCI Installer

One-liner installer for [OCI](https://github.com/rayenking/oci) (OpenCode Iris).

## Install

### Linux / macOS

```bash
curl -fsSL https://raw.githubusercontent.com/rayenking/oci-install/main/install.sh | bash
```

### Windows (PowerShell)

```powershell
irm https://raw.githubusercontent.com/rayenking/oci-install/main/install.ps1 | iex
```

> Requires PowerShell 5.1+ (included in Windows 10/11).

If OCI is already installed, the script shows a menu:

```
OCI is already installed. (oci v0.8.4 windows/amd64)

  1) Reinstall  — backup sessions, fresh install
  2) Update     — update OCI binary to latest
  3) Uninstall  — remove everything
  4) Cancel
```

## What Gets Installed

1. `gh` (GitHub CLI) if not present
2. OCI binary (`/usr/local/bin/oci` on Unix, `%LOCALAPPDATA%\oci\oci.exe` on Windows)
3. OpenCode CLI, configs, RTK, skills, plugins, Claude configs

## Supported Platforms

| OS | Arch | Asset | Installer |
|---|---|---|---|
| Linux | x86_64 | `oci-linux-amd64` | `install.sh` |
| macOS | Apple Silicon | `oci-darwin-arm64` | `install.sh` |
| Windows | x86_64 | `oci-windows-amd64.exe` | `install.ps1` |

## Commands

```bash
oci install     # Fresh install (default)
oci reinstall   # Backup sessions → clean → reinstall
oci uninstall   # Remove everything (asks about sessions)
oci update      # Self-update OCI binary
oci version     # Print version
```

## Requirements

- Linux, macOS, or Windows
- Internet connection
- GitHub account with access to `rayenking/oci`
- `curl` (Linux/macOS) or PowerShell 5.1+ (Windows)
