#!/usr/bin/env bash
# Arch / Omarchy installer
set -euo pipefail

if ! command -v pacman >/dev/null; then
  echo "pacman not found. This is not an Arch-based system." >&2
  exit 1
fi

echo "==> Installing Arch packages"
PACKAGES=(
  # Core
  base-devel git curl wget unzip tar gzip cmake
  # Shell
  zsh zsh-vi-mode zsh-autosuggestions zsh-syntax-highlighting starship
  # Terminal + multiplexer
  ghostty tmux tpm
  # Editor
  neovim lazygit gitui
  # Modern CLI
  fzf ripgrep fd bat eza zoxide btop yazi
  delta hyperfine watchexec mprocs lazydocker dive ctop bandwhich
  git-absorb gitleaks pre-commit miller sd trash-cli xh
  # Phase 1: shell upgrade
  atuin direnv uv
  # Language toolchains
  nodejs npm python python-pip ruff rustup dotnet-sdk go
  # Phase 2: dev workflow
  bun just act
  # Build tools used by language servers
  gcc make pkgconf openssl
  # Fonts
  ttf-jetbrains-mono-nerd noto-fonts-emoji
  # Git / auth
  github-cli
  # Misc
  age jq yq
)

# AUR helper
if ! command -v yay >/dev/null && ! command -v paru >/dev/null; then
  echo "==> Installing yay (AUR helper)"
  sudo pacman -S --noconfirm --needed base-devel
  tmpdir=$(mktemp -d)
  git clone https://aur.archlinux.org/yay.git "$tmpdir/yay"
  (cd "$tmpdir/yay" && makepkg -si --noconfirm)
  rm -rf "$tmpdir"
fi

AUR_HELPER="$(command -v yay || command -v paru)"

sudo pacman -S --noconfirm --needed "${PACKAGES[@]}"

# AUR packages (tools not in core repos, or with non-standard names)
AUR_PACKAGES=(
  visual-studio-code-bin
  google-chrome
  fzf-tab
)
"$AUR_HELPER" -S --noconfirm --needed "${AUR_PACKAGES[@]}" || true

# Install rustup-managed toolchain if not present
if ! command -v cargo >/dev/null; then
  echo "==> Installing rustup"
  rustup install stable
  rustup default stable
fi

# Gas town: install via `go install` (no official AUR package yet)
if command -v go >/dev/null; then
  echo "==> Installing gas town (gastownhall/gastown)"
  if ! command -v gt >/dev/null; then
    go install github.com/gastownhall/gastown/cmd/gt@latest 2>/dev/null || warn "gas town install failed; see https://github.com/gastownhall/gastown"
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
  chsh -s "$(command -v zsh)"
fi

echo "✓ Arch packages installed"
