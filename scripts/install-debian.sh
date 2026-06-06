#!/usr/bin/env bash
# Debian / Ubuntu / WSL installer
set -euo pipefail

if ! command -v apt-get >/dev/null; then
  echo "apt-get not found. This is not a Debian-based system." >&2
  exit 1
fi

echo "==> Installing Debian packages"
sudo apt-get update
sudo apt-get install -y \
  zsh \
  neovim tmux fzf ripgrep fd-find bat \
  btop git curl wget unzip \
  gh age jq yq \
  build-essential pkg-config libssl-dev cmake \
  zsh-autosuggestions zsh-syntax-highlighting

# Tools not in apt (or older)
if ! command -v eza >/dev/null; then
  echo "==> Installing eza"
  sudo mkdir -p /etc/apt/keyrings
  wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb/release.asc \
    | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg 2>/dev/null || true
  echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" \
    | sudo tee /etc/apt/sources.list.d/gierens.list >/dev/null
  sudo apt-get update && sudo apt-get install -y eza
fi

if ! command -v zoxide >/dev/null; then
  echo "==> Installing zoxide"
  curl -sSf https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
fi

if ! command -v lazygit >/dev/null; then
  echo "==> Installing lazygit"
  LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
  curl -Lo /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
  tar xf /tmp/lazygit.tar.gz -C /tmp lazygit
  sudo install /tmp/lazygit /usr/local/bin
fi

if ! command -v delta >/dev/null; then
  echo "==> Installing delta"
  DELTA_VERSION=$(curl -s "https://api.github.com/repos/dandavison/delta/releases/latest" | grep -Po '"tag_name": "\K[^"]*')
  curl -Lo /tmp/delta.deb "https://github.com/dandavison/delta/releases/latest/download/git-delta_${DELTA_VERSION}_amd64.deb"
  sudo dpkg -i /tmp/delta.deb
fi

# Phase 1: shell upgrade tools
for tool in atuin direnv uv; do
  if ! command -v "$tool" >/dev/null; then
    echo "==> Installing $tool"
    case "$tool" in
      atuin)  curl -sSf https://raw.githubusercontent.com/atuinsh/atuin/main/install.sh | sh ;;
      direnv) sudo apt-get install -y direnv ;;
      uv)     curl -LsSf https://astral.sh/uv/install.sh | sh ;;
    esac
  fi
done

# Phase 2: dev workflow
for tool in just bun act; do
  if ! command -v "$tool" >/dev/null; then
    echo "==> Installing $tool"
    case "$tool" in
      just) sudo apt-get install -y just ;;
      bun)
        curl -fsSL https://bun.sh/install | bash
        export PATH="$HOME/.bun/bin:$PATH"
        ;;
      act)  curl -fsSL https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash -s -- -b /usr/local/bin ;;
    esac
  fi
done

# Gas town: install via `go install`
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

echo "✓ Debian packages installed"
