#!/usr/bin/env bash
# Debian / Ubuntu / WSL installer
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

if ! command -v apt-get >/dev/null; then
  echo "apt-get not found. This is not a Debian-based system." >&2
  exit 1
fi

log "Installing Debian packages"

sudo apt-get update
sudo apt-get install -y \
  zsh \
  neovim tmux fzf ripgrep fd-find bat \
  btop git curl wget unzip \
  gh age jq yq \
  build-essential pkg-config libssl-dev cmake \
  zsh-autosuggestions zsh-syntax-highlighting \
  kitty direnv just golang-go \
  xclip wl-clipboard

# Tools not in apt (or older versions)
if ! command -v eza >/dev/null; then
  log "Installing eza"
  sudo mkdir -p /etc/apt/keyrings
  wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb/release.asc \
    | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg 2>/dev/null || true
  echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" \
    | sudo tee /etc/apt/sources.list.d/gierens.list >/dev/null
  sudo apt-get update && sudo apt-get install -y eza
fi

if ! command -v zoxide >/dev/null; then
  log "Installing zoxide"
  curl -sSf https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
fi

if ! command -v lazygit >/dev/null; then
  log "Installing lazygit"
  LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" \
    | grep -Po '"tag_name": "v\K[^"]*')
  curl -Lo /tmp/lazygit.tar.gz \
    "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
  tar xf /tmp/lazygit.tar.gz -C /tmp lazygit
  sudo install /tmp/lazygit /usr/local/bin
fi

if ! command -v delta >/dev/null; then
  log "Installing delta"
  DELTA_VERSION=$(curl -s "https://api.github.com/repos/dandavison/delta/releases/latest" \
    | grep -Po '"tag_name": "\K[^"]*')
  curl -Lo /tmp/delta.deb \
    "https://github.com/dandavison/delta/releases/latest/download/git-delta_${DELTA_VERSION}_amd64.deb"
  sudo dpkg -i /tmp/delta.deb
fi

# Symlink fd-find → fd
ensure_symlink "fd-find" "fd"

# Starship (not in Debian stable)
if ! command -v starship >/dev/null; then
  log "Installing starship"
  curl -sSf https://starship.rs/install.sh | sh -s -- -y 2>/dev/null || \
    cargo install starship --locked 2>/dev/null || true
fi

# Gitui (not in Debian stable)
if ! command -v gitui >/dev/null; then
  log "Installing gitui via cargo"
  cargo install gitui --locked 2>/dev/null || true
fi

# Git-absorb (not in Debian stable)
if ! command -v git-absorb >/dev/null; then
  log "Installing git-absorb via cargo"
  cargo install git-absorb --locked 2>/dev/null || true
fi

# yazi (not in Debian stable)
if ! command -v yazi >/dev/null; then
  log "Installing yazi via cargo"
  cargo install yazi --locked 2>/dev/null || true
fi

# hyperfine (not in Debian stable)
if ! command -v hyperfine >/dev/null; then
  log "Installing hyperfine via cargo"
  cargo install hyperfine --locked 2>/dev/null || true
fi

# watchexec (not in Debian stable)
if ! command -v watchexec >/dev/null; then
  log "Installing watchexec via cargo"
  cargo install watchexec --locked 2>/dev/null || true
fi

# sd (not in Debian stable)
if ! command -v sd >/dev/null; then
  log "Installing sd via cargo"
  cargo install sd --locked 2>/dev/null || true
fi

# miller (not in Debian stable)
if ! command -v mlr >/dev/null && ! command -v miller >/dev/null; then
  log "Installing miller via cargo"
  cargo install miller --locked 2>/dev/null || true
fi

# bandwhich (not in Debian stable)
if ! command -v bandwhich >/dev/null; then
  log "Installing bandwhich via cargo"
  cargo install bandwhich --locked 2>/dev/null || true
fi

# xh (not in Debian stable)
if ! command -v xh >/dev/null; then
  log "Installing xh via cargo"
  cargo install xh --locked 2>/dev/null || true
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

# Phase 2: dev workflow
for tool in bun act; do
  if ! command -v "$tool" >/dev/null; then
    log "Installing $tool"
    case "$tool" in
      bun)
        curl -fsSL https://bun.sh/install | bash
        export PATH="$HOME/.bun/bin:$PATH"
        ;;
      act)  curl -fsSL https://raw.githubusercontent.com/nektos/act/master/install.sh \
              | sudo bash -s -- -b /usr/local/bin ;;
    esac
  fi
done

# Miscellaneous tools (via go install or cargo)
if ! command -v lazydocker >/dev/null; then go install github.com/jesseduffield/lazydocker@latest 2>/dev/null || true; fi
if ! command -v dive >/dev/null; then go install github.com/wagoodman/dive@latest 2>/dev/null || true; fi
if ! command -v ctop >/dev/null; then go install github.com/bcicen/ctop@latest 2>/dev/null || true; fi
if ! command -v gitleaks >/dev/null; then go install github.com/gitleaks/gitleaks@latest 2>/dev/null || true; fi
if ! command -v mprocs >/dev/null; then go install github.com/pvolok/mprocs@latest 2>/dev/null || true; fi
if ! command -v trash >/dev/null && ! command -v trash-put >/dev/null; then cargo install trash-cli --locked 2>/dev/null || true; fi

# --- Shared steps (via lib.sh) -----------------------------------------------
install_rustup_toolchain
install_gastown
set_default_shell_zsh

ok "Debian packages installed"
