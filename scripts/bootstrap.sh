#!/usr/bin/env bash
# Bootstrap a fresh machine with the dotfiles setup.
# Detects OS and dispatches to the right installer.
#
# Usage: ./scripts/bootstrap.sh [--skip-packages] [--chezmoi-source PATH]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"
SKIP_PACKAGES=0
CHEZMOI_SOURCE="$DOTFILES_DIR"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --skip-packages) SKIP_PACKAGES=1; shift ;;
    --chezmoi-source) CHEZMOI_SOURCE="$2"; shift 2 ;;
    *) echo "Unknown arg: $1"; exit 1 ;;
  esac
done

# --- Colors for output --------------------------------------------------------
if [[ -t 1 ]]; then
  BOLD=$'\033[1m'; BLUE=$'\033[34m'; GREEN=$'\033[32m'; YELLOW=$'\033[33m'; RESET=$'\033[0m'
else
  BOLD=""; BLUE=""; GREEN=""; YELLOW=""; RESET=""
fi

log()  { printf "%b==>%b %b%s%b\n" "$BOLD" "$RESET" "$BLUE" "$1" "$RESET"; }
ok()   { printf "%b✓%b %s\n" "$GREEN" "$RESET" "$1"; }
warn() { printf "%b!%b %s\n" "$YELLOW" "$RESET" "$1"; }

# --- OS detection -------------------------------------------------------------
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

OS="$(detect_os)"
log "Detected OS: $OS"

# --- Prereqs: chezmoi + age + git ---------------------------------------------
install_prereqs() {
  if ! command -v chezmoi >/dev/null 2>&1; then
    log "Installing chezmoi"
    sh -c "$(curl -fsSL https://chezmoi.io/get)" || {
      warn "chezmoi install failed. Install manually: https://chezmoi.io/install"
      exit 1
    }
  fi
  ok "chezmoi: $(chezmoi --version)"

  if ! command -v age >/dev/null 2>&1 && ! command -v rage >/dev/null 2>&1; then
    log "Installing age (encryption)"
    case "$OS" in
      arch)   sudo pacman -S --noconfirm --needed age ;;
      fedora) sudo dnf install -y age ;;
      debian|wsl)
        sudo apt-get update && sudo apt-get install -y age ;;
      macos)  brew install age ;;
      windows) winget install FiloSottile.age ;;
    esac
  fi
  ok "age: $(command -v age || command -v rage)"

  if ! command -v git >/dev/null 2>&1; then
    warn "git not found. Install git first."
    exit 1
  fi
  ok "git: $(git --version)"
}

# --- Package installation -----------------------------------------------------
install_packages() {
  [[ $SKIP_PACKAGES -eq 1 ]] && { warn "Skipping packages (--skip-packages)"; return; }
  case "$OS" in
    arch)        "$SCRIPT_DIR/install-arch.sh" ;;
    fedora)      "$SCRIPT_DIR/install-fedora.sh" ;;
    debian|wsl)  "$SCRIPT_DIR/install-debian.sh" ;;
    macos)       "$SCRIPT_DIR/install-mac.sh" ;;
    windows)     "$SCRIPT_DIR/install-windows.sh" ;;
    *)           warn "Unknown OS '$OS', skipping package install" ;;
  esac
}

# --- Dotfiles apply -----------------------------------------------------------
apply_dotfiles() {
  if [[ ! -d "$CHEZMOI_SOURCE/.git" ]] && ! git -C "$CHEZMOI_SOURCE" rev-parse --git-dir >/dev/null 2>&1; then
    log "Initializing git in $CHEZMOI_SOURCE"
    (cd "$CHEZMOI_SOURCE" && git init -b main && git add -A && git commit -m "initial dotfiles" --allow-empty)
  fi

  if ! chezmoi managed -i path 2>/dev/null | grep -q .; then
    log "Initializing chezmoi from $CHEZMOI_SOURCE"
    chezmoi init --source "$CHEZMOI_SOURCE"
  fi

  log "Running chezmoi apply (this will back up conflicting files to ~/.local/share/chezmoi/backups)"
  chezmoi apply --force

  if [[ -f "$CHEZMOI_SOURCE/scripts/post-install.sh" ]]; then
    log "Running post-install hooks"
    bash "$CHEZMOI_SOURCE/scripts/post-install.sh"
  fi
}

# --- Main ---------------------------------------------------------------------
install_prereqs
install_packages
apply_dotfiles

ok "Bootstrap complete!"
echo
echo "Next steps:"
echo "  1. Restart your shell: exec zsh"
echo "  2. Open nvim and let LazyVim install plugins: nvim"
echo "  3. Edit ~/.gitconfig.local with your name and email"
echo "  4. Set up age encryption (see README.md > Secrets)"
