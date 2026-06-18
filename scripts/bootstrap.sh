#!/usr/bin/env bash
# bootstrap.sh — set up a fresh machine with the dotfiles setup
#
# Usage:
#   bash ~/dotfiles/scripts/bootstrap.sh
#   bash ~/dotfiles/scripts/bootstrap.sh --skip-packages
#   bash ~/dotfiles/scripts/bootstrap.sh --chezmoi-source PATH
#
# What it does:
#   1. Detects your OS (arch/fedora/debian/macos/wsl/windows)
#   2. Installs prereqs: chezmoi, age, git
#   3. Installs all packages via the OS-specific installer
#   4. Runs `chezmoi apply` to link all dotfiles
#   5. Runs post-install hooks (tpm, zsh plugins, git stubs, etc.)
#
# After this, restart your shell with: exec zsh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"
source "$SCRIPT_DIR/lib.sh"

# --- Args --------------------------------------------------------------------
SKIP_PACKAGES=0
CHEZMOI_SOURCE="$DOTFILES_DIR"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --skip-packages) SKIP_PACKAGES=1; shift ;;
    --chezmoi-source) CHEZMOI_SOURCE="$2"; shift 2 ;;
    *) echo "Unknown arg: $1"; exit 1 ;;
  esac
done

# =============================================================================
# Step 1: OS detection
# =============================================================================
OS="$(detect_os)"
log "Detected OS: $OS"

# =============================================================================
# Step 2: Install prereqs (chezmoi, age, git)
# =============================================================================
log "Installing prereqs"
install_chezmoi
install_age
install_git
ensure_local_bin

# =============================================================================
# Step 3: Install packages
# =============================================================================
if [[ $SKIP_PACKAGES -eq 1 ]]; then
  warn "Skipping packages (--skip-packages)"
else
  log "Installing packages"
  case "$OS" in
    arch)        "$SCRIPT_DIR/install-arch.sh" ;;
    fedora)      "$SCRIPT_DIR/install-fedora.sh" ;;
    debian|wsl)  "$SCRIPT_DIR/install-debian.sh" ;;
    macos)       "$SCRIPT_DIR/install-mac.sh" ;;
    windows)     "$SCRIPT_DIR/install-windows.ps1" ;;
    *)           warn "Unknown OS '$OS', skipping package install" ;;
  esac
fi

# =============================================================================
# Step 4: Apply dotfiles with chezmoi
# =============================================================================
log "Applying dotfiles with chezmoi"

if [[ ! -d "$CHEZMOI_SOURCE/.git" ]] && ! git -C "$CHEZMOI_SOURCE" rev-parse --git-dir >/dev/null 2>&1; then
  log "Initializing git in $CHEZMOI_SOURCE"
  (cd "$CHEZMOI_SOURCE" && git init -b main && git add -A && git commit -m "initial dotfiles" --allow-empty)
fi

# Ensure chezmoi source points to the dotfiles repo
# --force allows overwriting a previous config that might point elsewhere (e.g. ~/.local/share/chezmoi)
if [[ ! -f "$HOME/.config/chezmoi/chezmoi.toml" ]] \
   || ! grep -q "sourceDir.*$CHEZMOI_SOURCE" "$HOME/.config/chezmoi/chezmoi.toml" 2>/dev/null; then
  log "Configuring chezmoi source to $CHEZMOI_SOURCE"
  chezmoi init --source "$CHEZMOI_SOURCE" --force
fi

log "Running chezmoi apply (backs up conflicts to ~/.local/share/chezmoi/backups)"
chezmoi apply --force

# =============================================================================
# Step 5: Post-install hooks
# =============================================================================
if [[ -f "$DOTFILES_DIR/scripts/post-install.sh" ]]; then
  log "Running post-install hooks"
  bash "$DOTFILES_DIR/scripts/post-install.sh"
fi

# =============================================================================
# Done
# =============================================================================
echo ""
ok "Bootstrap complete!"
echo ""
echo "  Next steps:"
echo "    1. Restart your shell:  exec zsh"
echo "    2. Open nvim:           nvim  (LazyVim installs plugins)"
echo "    3. Set git identity:    nvim ~/.gitconfig.local"
echo "    4. (Optional) Atuin:    atuin register -u <user> -e <email>"
echo "    5. (Optional) Gas town: gt town new"
echo ""
