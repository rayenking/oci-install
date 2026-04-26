# OCI Installer

One-liner installer for [OCI](https://github.com/rayenking/oci) (OpenCode Iris).

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/rayenking/oci-install/main/install.sh | bash
```

If OCI is already installed, the script shows a menu:

```
OCI is already installed. (oci v0.2.0 darwin/arm64)

  1) Reinstall  — backup sessions, fresh install
  2) Update     — update OCI binary to latest
  3) Uninstall  — remove everything
  4) Cancel
```

## What Gets Installed

1. `gh` (GitHub CLI) if not present
2. OCI binary to `/usr/local/bin/oci`
3. OpenCode CLI, configs, RTK, skills, plugins, Claude configs

## Commands

```bash
oci install     # Fresh install (default)
oci reinstall   # Backup sessions → clean → reinstall
oci uninstall   # Remove everything (asks about sessions)
oci update      # Self-update OCI binary
oci version     # Print version
```

## Requirements

- Linux or macOS
- `curl`
- Internet connection
- GitHub account with access to `rayenking/oci`
