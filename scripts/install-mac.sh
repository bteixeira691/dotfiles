#!/usr/bin/env bash
# macOS installer (uses Homebrew + Brewfile)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="${DOTFILES_DIR:-$(dirname "$SCRIPT_DIR")}"
source "$SCRIPT_DIR/lib.sh"

if ! command -v brew >/dev/null; then
  log "Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"
fi

log "Running brew bundle (from $DOTFILES_DIR/Brewfile)"
if ! brew bundle --file "$DOTFILES_DIR/Brewfile"; then
  warn "Some Homebrew packages failed to install. Check output above."
  warn "Run 'brew bundle --file $DOTFILES_DIR/Brewfile' later to retry."
fi

# Set zsh as default shell (Apple ships zsh but we want Homebrew's)
if command -v brew >/dev/null; then
  if ! grep -q "$(brew --prefix)/bin/zsh" /etc/shells 2>/dev/null; then
    log "Adding Homebrew zsh to /etc/shells"
    echo "$(brew --prefix)/bin/zsh" | sudo tee -a /etc/shells
  fi
  if [[ "$SHELL" != "$(brew --prefix)/bin/zsh" ]]; then
    log "Setting Homebrew zsh as default"
    chsh -s "$(brew --prefix)/bin/zsh"
  fi
fi

# --- Shared steps (via lib.sh) -----------------------------------------------
install_gastown

ok "macOS packages installed"
