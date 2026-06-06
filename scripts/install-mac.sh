#!/usr/bin/env bash
# macOS installer (uses Homebrew + Brewfile)
set -euo pipefail

# Allow DOTFILES_DIR override, but default to parent of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="${DOTFILES_DIR:-$(dirname "$SCRIPT_DIR")}"

if ! command -v brew >/dev/null; then
  echo "==> Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"
fi

echo "==> Running brew bundle (from $DOTFILES_DIR/Brewfile)"
brew bundle --file "$DOTFILES_DIR/Brewfile" || true

# Set zsh as default shell (Apple ships zsh but we want Homebrew's)
if ! grep -q "$(brew --prefix)/bin/zsh" /etc/shells; then
  echo "==> Adding Homebrew zsh to /etc/shells"
  echo "$(brew --prefix)/bin/zsh" | sudo tee -a /etc/shells
fi
if [[ "$SHELL" != "$(brew --prefix)/bin/zsh" ]]; then
  echo "==> Setting Homebrew zsh as default"
  chsh -s "$(brew --prefix)/bin/zsh"
fi

# Gas town: install via `go install` (no official brew formula yet)
if command -v go >/dev/null; then
  echo "==> Installing gas town (gastownhall/gastown)"
  if ! command -v gt >/dev/null; then
    go install github.com/gastownhall/gastown/cmd/gt@latest 2>/dev/null || true
  fi
  if ! command -v bd >/dev/null; then
    go install github.com/gastownhall/beads/cmd/bd@latest 2>/dev/null || true
  fi
  if ! command -v bv >/dev/null; then
    go install github.com/gastownhall/beads/cmd/bv@latest 2>/dev/null || true
  fi
fi

echo "✓ macOS packages installed"
