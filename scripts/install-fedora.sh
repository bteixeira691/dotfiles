#!/usr/bin/env bash
# Fedora / Nobara installer
set -euo pipefail

if ! command -v dnf >/dev/null; then
  echo "dnf not found. This is not a Fedora-based system." >&2
  exit 1
fi

echo "==> Installing Fedora packages"
sudo dnf install -y \
  zsh zsh-autosuggestions zsh-syntax-highlighting zsh-vi-mode starship \
  ghostty tmux tpm \
  neovim lazygit gitui \
  fzf ripgrep fd-find bat \
  btop yazi git-delta \
  hyperfine watchexec mprocs lazydocker dive ctop bandwhich \
  git-absorb gitleaks pre-commit miller sd trash-cli xh \
  nodejs npm \
  python3 python3-pip \
  rust cargo \
  dotnet-sdk-9.0 golang \
  gcc make pkgconf openssl-devel cmake \
  jetbrains-mono-fonts fontawesome-fonts symbols-only-nerd-fonts \
  gh \
  age jq yq \
  fzf-tab

# Fedora's `fd` is named `fd-find`
if command -v fd-find >/dev/null && ! command -v fd >/dev/null; then
  sudo ln -sf "$(command -v fd-find)" /usr/local/bin/fd
fi

# Tools not in dnf (or older than what we want)
if ! command -v eza >/dev/null; then
  echo "==> Installing eza via cargo"
  cargo install eza --locked || true
fi

if ! command -v zoxide >/dev/null; then
  echo "==> Installing zoxide"
  curl -sSf https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
fi

# Phase 1: shell upgrade tools
for tool in atuin direnv uv; do
  if ! command -v "$tool" >/dev/null; then
    echo "==> Installing $tool"
    case "$tool" in
      atuin)   curl -sSf https://raw.githubusercontent.com/atuinsh/atuin/main/install.sh | sh ;;
      direnv)  sudo dnf install -y direnv ;;
      uv)      curl -LsSf https://astral.sh/uv/install.sh | sh ;;
    esac
  fi
done

# Phase 2: dev workflow (just, bun, act)
for tool in just bun act; do
  if ! command -v "$tool" >/dev/null; then
    echo "==> Installing $tool"
    case "$tool" in
      just) sudo dnf install -y just ;;
      bun)
        curl -fsSL https://bun.sh/install | bash
        export PATH="$HOME/.bun/bin:$PATH"
        ;;
      act)  sudo dnf install -y act ;;
    esac
  fi
done

# Gas town: install via `go install` (no official Fedora package yet)
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

# Set zsh as default shell
if [[ "$SHELL" != */zsh ]]; then
  echo "==> Setting zsh as default shell"
  sudo chsh -s "$(command -v zsh)" "$USER"
fi

echo "✓ Fedora packages installed"
