#!/usr/bin/env bash
set -euo pipefail

REPO="rayenking/oci"
BINARY_NAME="oci"
INSTALL_DIR="/usr/local/bin"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

banner() {
  echo -e "${CYAN}"
  cat << 'EOF'
   ____  _____ _____
  / __ \/ ___//  _/
 / / / / /    / /
/ /_/ / /____/ /
\____/\____/___/

OpenCode Iris Installer
EOF
  echo -e "${NC}"
}

info()  { echo -e "${GREEN}[+]${NC} $*"; }
warn()  { echo -e "${YELLOW}[!]${NC} $*"; }
error() { echo -e "${RED}[x]${NC} $*"; exit 1; }

detect_platform() {
  OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
  ARCH="$(uname -m)"

  case "$ARCH" in
    x86_64|amd64) ARCH="amd64" ;;
    aarch64|arm64) ARCH="arm64" ;;
    *) error "Unsupported architecture: $ARCH" ;;
  esac

  case "$OS" in
    linux|darwin) ;;
    *) error "Unsupported OS: $OS" ;;
  esac

  ASSET_NAME="${BINARY_NAME}-${OS}-${ARCH}"
}

ensure_gh() {
  if command -v gh &>/dev/null; then
    info "GitHub CLI found: $(gh --version | head -1)"
  else
    info "Installing GitHub CLI..."
    case "$OS" in
      linux)
        if command -v pacman &>/dev/null; then
          sudo pacman -S --noconfirm github-cli
        elif command -v apt-get &>/dev/null; then
          curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg 2>/dev/null
          echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null
          sudo apt-get update -qq && sudo apt-get install -y gh
        elif command -v dnf &>/dev/null; then
          sudo dnf install -y gh
        elif command -v brew &>/dev/null; then
          brew install gh
        else
          error "Cannot auto-install gh. Install manually: https://cli.github.com"
        fi
        ;;
      darwin)
        if command -v brew &>/dev/null; then
          brew install gh
        else
          error "Install Homebrew first (https://brew.sh) or install gh manually"
        fi
        ;;
    esac
  fi
}

ensure_gh_auth() {
  if gh auth status &>/dev/null; then
    info "GitHub CLI authenticated"
  else
    warn "Not logged in to GitHub. Starting login..."
    echo ""
    gh auth login </dev/tty
    echo ""
    gh auth status &>/dev/null || error "GitHub auth failed"
    info "GitHub CLI authenticated"
  fi
}

download_oci() {
  TMPDIR="$(mktemp -d)"
  trap 'rm -rf "$TMPDIR"' EXIT

  info "Downloading OCI binary (${ASSET_NAME})..."
  gh release download --repo "$REPO" --pattern "$ASSET_NAME" --dir "$TMPDIR" --clobber 2>/dev/null \
    || error "Failed to download. Make sure you have access to ${REPO}"

  chmod +x "${TMPDIR}/${ASSET_NAME}"

  if [ -w "$INSTALL_DIR" ]; then
    mv "${TMPDIR}/${ASSET_NAME}" "${INSTALL_DIR}/${BINARY_NAME}"
  else
    info "Need sudo to install to ${INSTALL_DIR}..."
    sudo mv "${TMPDIR}/${ASSET_NAME}" "${INSTALL_DIR}/${BINARY_NAME}"
  fi

  info "OCI installed to ${INSTALL_DIR}/${BINARY_NAME}"
}

show_menu() {
  local action="${1:-}"

  if [ -n "$action" ]; then
    case "$action" in
      install|reinstall|update|uninstall) OCI_ACTION="$action"; return ;;
      *) error "Unknown action: $action. Use: install, reinstall, update, uninstall" ;;
    esac
  fi

  if command -v oci &>/dev/null; then
    echo -e "${BOLD}OCI is already installed.${NC} ($(oci version))"
    echo ""
    echo "  1) Reinstall  — backup sessions, fresh install"
    echo "  2) Update     — update OCI binary to latest"
    echo "  3) Uninstall  — remove everything"
    echo "  4) Cancel"
    echo ""
    read -rp "Choose [1-4]: " choice </dev/tty
    case "$choice" in
      1) OCI_ACTION="reinstall" ;;
      2) OCI_ACTION="update" ;;
      3) OCI_ACTION="uninstall" ;;
      4) echo "Cancelled."; exit 0 ;;
      *) error "Invalid choice" ;;
    esac
  else
    OCI_ACTION="install"
  fi
}

run_action() {
  case "$OCI_ACTION" in
    install)
      download_oci
      echo ""
      info "Running OCI installer..."
      echo ""
      "${INSTALL_DIR}/${BINARY_NAME}" install
      ;;
    reinstall)
      download_oci
      echo ""
      info "Running OCI reinstall..."
      echo ""
      "${INSTALL_DIR}/${BINARY_NAME}" reinstall
      ;;
    update)
      if command -v oci &>/dev/null; then
        download_oci
        info "OCI binary updated."
      else
        download_oci
        info "OCI installed."
      fi
      ;;
    uninstall)
      if command -v oci &>/dev/null; then
        oci uninstall
      else
        error "OCI is not installed"
      fi
      ;;
  esac
}

main() {
  banner
  detect_platform
  info "Platform: ${OS}/${ARCH}"
  echo ""

  ensure_gh
  ensure_gh_auth
  echo ""

  show_menu "${1:-}"
  run_action
}

main "$@"
