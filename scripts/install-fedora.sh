#!/usr/bin/env bash
# Fedora / Nobara installer
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

if ! command -v dnf >/dev/null; then
  echo "dnf not found. This is not a Fedora-based system." >&2
  exit 1
fi

log "Installing Fedora packages"

# Core packages (guaranteed in Fedora repos)
sudo dnf install -y \
  zsh zsh-autosuggestions zsh-syntax-highlighting zsh-vi-mode starship \
  kitty tmux \
  neovim lazygit gitui \
  fzf ripgrep fd-find bat \
  git-delta hyperfine watchexec \
  git-absorb pre-commit miller sd trash-cli \
  nodejs npm \
  python3 python3-pip \
  rust cargo \
  golang \
  gcc make pkgconf openssl-devel cmake \
  jetbrains-mono-fonts fontawesome-fonts symbols-only-nerd-fonts \
  gh \
  age jq yq \
  xclip wl-clipboard

# Additional packages (may not be in all Fedora versions — skip if missing)
for pkg in ghostty btop yazi tpm fzf-tab mprocs lazydocker dive ctop bandwhich gitleaks xh just direnv act dotnet-sdk-9.0; do
  sudo dnf install -y "$pkg" 2>/dev/null && echo "  -> $pkg installed" || echo "  -> $pkg not in repos, will use fallback"
done

# Fedora's `fd` is named `fd-find`
ensure_symlink "fd-find" "fd"

# --- Tool fallbacks (for packages not in Fedora repos) -----------------------

# Ghostty (not in Fedora 40/41)
if ! command -v ghostty >/dev/null; then
  log "Skipping ghostty — install manually from https://ghostty.org/download"
fi

# eza (needs cargo)
if ! command -v eza >/dev/null; then
  log "Installing eza via cargo"
  cargo install eza --locked || true
fi

# yazi (may not be in older Fedora)
if ! command -v yazi >/dev/null; then
  log "Installing yazi via cargo"
  cargo install yazi --locked || true
fi

# btop (may not be in older Fedora)
if ! command -v btop >/dev/null; then
  log "Installing btop via cargo"
  cargo install btop --locked || true
fi

# zoxide
if ! command -v zoxide >/dev/null; then
  log "Installing zoxide"
  curl -sSf https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
fi

# Phase 1: shell upgrade tools
for tool in atuin uv; do
  if ! command -v "$tool" >/dev/null; then
    log "Installing $tool"
    case "$tool" in
      atuin)  curl -sSf https://raw.githubusercontent.com/atuinsh/atuin/main/install.sh | sh ;;
      uv)     curl -LsSf https://astral.sh/uv/install.sh | sh ;;
    esac
  fi
done

# Phase 2: dev workflow (bun)
if ! command -v bun >/dev/null; then
  log "Installing bun"
  curl -fsSL https://bun.sh/install | bash
  export PATH="$HOME/.bun/bin:$PATH"
fi

# lazydocker, dive, ctop, bandwhich, gitleaks, xh, mprocs (via go install or cargo)
if ! command -v lazydocker >/dev/null; then go install github.com/jesseduffield/lazydocker@latest 2>/dev/null || true; fi
if ! command -v dive >/dev/null; then go install github.com/wagoodman/dive@latest 2>/dev/null || true; fi
if ! command -v ctop >/dev/null; then go install github.com/bcicen/ctop@latest 2>/dev/null || true; fi
if ! command -v bandwhich >/dev/null; then cargo install bandwhich --locked 2>/dev/null || true; fi
if ! command -v gitleaks >/dev/null; then go install github.com/gitleaks/gitleaks@latest 2>/dev/null || true; fi
if ! command -v xh >/dev/null; then cargo install xh --locked 2>/dev/null || true; fi
if ! command -v mprocs >/dev/null; then go install github.com/pvolok/mprocs@latest 2>/dev/null || true; fi

# --- Shared steps (via lib.sh) -----------------------------------------------
install_gastown
set_default_shell_zsh

ok "Fedora packages installed"
