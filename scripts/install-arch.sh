#!/usr/bin/env bash
# Arch / Omarchy installer
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

if ! command -v pacman >/dev/null; then
  echo "pacman not found. This is not an Arch-based system." >&2
  exit 1
fi

log "Installing Arch packages"

PACKAGES=(
  # Core
  base-devel git curl wget unzip tar gzip cmake
  # Shell
  zsh zsh-autosuggestions zsh-syntax-highlighting starship
  # Terminal + multiplexer
  ghostty kitty tmux
  # Editor
  neovim lazygit gitui
  # Modern CLI
  fzf ripgrep fd bat eza zoxide btop yazi
  git-delta hyperfine watchexec lazydocker dive ctop bandwhich
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
  # Clipboard (tmux integration)
  xclip wl-clipboard
  # Misc
  age jq yq
)

# --- AUR helper ---------------------------------------------------------------
if ! command -v yay >/dev/null && ! command -v paru >/dev/null; then
  log "Installing yay (AUR helper)"
  sudo pacman -S --noconfirm --needed base-devel
  tmpdir=$(mktemp -d)
  git clone https://aur.archlinux.org/yay.git "$tmpdir/yay"
  (cd "$tmpdir/yay" && makepkg -si --noconfirm)
  rm -rf "$tmpdir"
fi

AUR_HELPER="$(command -v yay || command -v paru)"

# Remove conflicting packages (rust conflicts with rustup)
if pacman -Qi rust >/dev/null 2>&1; then
  echo "  -> Removing rust (will use rustup instead)"
  sudo pacman -R --noconfirm rust 2>/dev/null || true
fi

sudo pacman -S --noconfirm --needed "${PACKAGES[@]}"

# AUR packages
AUR_PACKAGES=(
  visual-studio-code-bin
  google-chrome
  fzf-tab
  zsh-vi-mode
  tpm
  mprocs
)

# Clean yay build cache to avoid interactive prompts
for pkg in "${AUR_PACKAGES[@]}"; do
  rm -rf "$HOME/.cache/yay/$pkg" 2>/dev/null || true
done

if ! "$AUR_HELPER" -S --noconfirm --needed "${AUR_PACKAGES[@]}"; then
  warn "Some AUR packages failed to install (see above). Retry with: $AUR_HELPER -S <package>"
fi

# --- Shared steps (via lib.sh) -----------------------------------------------
install_rustup_toolchain
install_gastown
set_default_shell_zsh

ok "Arch packages installed"
