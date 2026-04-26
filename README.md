# OCI Installer

One-liner installer for [OCI](https://github.com/rayenking/oci) (OpenCode Iris).

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/rayenking/oci-install/main/install.sh | bash
```

## What Happens

1. Installs `gh` (GitHub CLI) if not present
2. Prompts `gh auth login` if not authenticated
3. Downloads the latest OCI binary from the private release
4. Runs `oci install` which sets up everything:
   - OpenCode CLI
   - All config files (opencode.json, oh-my-openagent.json, dcp.jsonc)
   - RTK (Rust Token Killer)
   - GitHub CLI
   - 19 development skills
   - Claude Code configs

## Requirements

- Linux or macOS
- `curl`
- Internet connection
- GitHub account with access to `rayenking/oci`

## Update

After initial install, update with:

```bash
oci update
```
