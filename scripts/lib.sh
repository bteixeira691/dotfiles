#!/usr/bin/env bash
# lib.sh — shared functions for bootstrap and install scripts
# Source this file. Do not execute directly.
#
# Usage:
#   SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
#   source "$SCRIPT_DIR/lib.sh"

set -euo pipefail

# =============================================================================
# Colors
# =============================================================================
setup_colors() {
  if [[ -t 1 ]]; then
    BOLD=$'\033[1m'; RED=$'\033[31m'; GREEN=$'\033[32m'
    YELLOW=$'\033[33m'; BLUE=$'\033[34m'; RESET=$'\033[0m'
  else
    BOLD=""; RED=""; GREEN=""; YELLOW=""; BLUE=""; RESET=""
  fi
}

log()  { printf "%b==>%b %b%s%b\n" "$BOLD" "$RESET" "$BLUE" "$1" "$RESET"; }
ok()   { printf "%b✓%b %s\n" "$GREEN" "$RESET" "$1"; }
warn() { printf "%b!%b %s\n" "$YELLOW" "$RESET" "$1"; }
fail() { printf "%b✗%b %s\n" "$RED" "$RESET" "$1"; exit 1; }

setup_colors

# =============================================================================
# OS detection
# =============================================================================
detect_os() {
  case "$(uname -s)" in
    Linux)
      if grep -qi microsoft /proc/version 2>/dev/null; then
        echo "wsl"
      elif [[ -f /etc/os-release ]]; then
        . /etc/os-release
        case "$ID" in
          arch|omarchy|manjaro|endeavouros) echo "arch" ;;
          fedora|nobara)                    echo "fedora" ;;
          ubuntu|debian|pop|linuxmint)      echo "debian" ;;
          *)                                echo "linux-unknown" ;;
        esac
      else
        echo "linux-unknown"
      fi
      ;;
    Darwin)  echo "macos" ;;
    CYGWIN*|MINGW*|MSYS*) echo "windows" ;;
    *) echo "unsupported" ;;
  esac
}

# =============================================================================
# Prereq installers (chezmoi, age, git)
# =============================================================================
install_chezmoi() {
  if ! command -v chezmoi >/dev/null 2>&1; then
    log "Installing chezmoi"
    mkdir -p "$HOME/.local/bin"
    curl -fsSL https://chezmoi.io/get | sh -s -- -b "$HOME/.local/bin" || {
      warn "chezmoi install failed. Install manually: https://chezmoi.io/install"
      return 1
    }
    export PATH="$HOME/.local/bin:$PATH"
  fi
  ok "chezmoi: $(chezmoi --version)"
}

install_age() {
  if command -v age >/dev/null 2>&1 || command -v rage >/dev/null 2>&1; then
    ok "age: $(command -v age || command -v rage)"
    return
  fi

  log "Installing age (encryption)"
  case "$(detect_os)" in
    arch)   sudo pacman -S --noconfirm --needed age ;;
    fedora) sudo dnf install -y age ;;
    debian|wsl) sudo apt-get update && sudo apt-get install -y age ;;
    macos)  brew install age ;;
    windows) winget install FiloSottile.age ;;
  esac
  ok "age: $(command -v age || command -v rage)"
}

install_git() {
  if ! command -v git >/dev/null 2>&1; then
    warn "git not found. Install git first."
    return 1
  fi
  ok "git: $(git --version)"
}

# =============================================================================
# Shared install steps (used by all platform installers)
# =============================================================================

# Gas town / beads (go install)
install_gastown() {
  if ! command -v go >/dev/null; then
    warn "go not found — skipping gas town install"
    return
  fi

  log "Installing gas town (gastownhall/gastown)"
  if ! command -v gt >/dev/null; then
    go install github.com/gastownhall/gastown/cmd/gt@latest 2>/dev/null || warn "gt install failed"
  fi
  if ! command -v bd >/dev/null; then
    go install github.com/gastownhall/beads/cmd/bd@latest 2>/dev/null || warn "bd install failed"
  fi
  if ! command -v bv >/dev/null; then
    go install github.com/gastownhall/beads/cmd/bv@latest 2>/dev/null || warn "bv install failed"
  fi

  command -v gt >/dev/null && ok "gt: $(gt version 2>/dev/null || echo installed)"
  command -v bd >/dev/null && ok "bd: $(bd version 2>/dev/null || echo installed)"
  command -v bv >/dev/null && ok "bv: $(bv version 2>/dev/null || echo installed)"
}

# Set zsh as default shell
set_default_shell_zsh() {
  if command -v zsh >/dev/null && [[ "$SHELL" != */zsh ]]; then
    log "Setting zsh as default shell"
    if command -v chsh >/dev/null; then
      chsh -s "$(command -v zsh)" 2>/dev/null \
        || sudo chsh -s "$(command -v zsh)" "$USER" 2>/dev/null \
        || warn "could not change shell (do it manually: chsh -s $(command -v zsh))"
    fi
  fi
  command -v zsh >/dev/null && ok "zsh: $(zsh --version)"
}

# Install rustup-managed toolchain if not present
install_rustup_toolchain() {
  if command -v cargo >/dev/null; then
    ok "rust/cargo already installed"
    return
  fi
  if command -v rustup >/dev/null; then
    log "Installing rustup toolchain"
    rustup install stable
    rustup default stable
    ok "rustup: $(rustup --version)"
  fi
}

# Add ~/.local/bin to PATH if not already
ensure_local_bin() {
  mkdir -p "$HOME/.local/bin"
  if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    export PATH="$HOME/.local/bin:$PATH"
  fi
}

# Symlink a binary from one location to another (e.g., fd-find → fd)
ensure_symlink() {
  local src="$1" dst="$2"
  if command -v "$src" >/dev/null && ! command -v "$dst" >/dev/null; then
    sudo ln -sf "$(command -v "$src")" "/usr/local/bin/$dst" 2>/dev/null \
      || ln -sf "$(command -v "$src")" "$HOME/.local/bin/$dst"
    ok "symlinked $src → $dst"
  fi
}
