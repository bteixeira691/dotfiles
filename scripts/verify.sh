#!/usr/bin/env bash
# Verify dotfiles/bootstrap completeness.
# Exits 1 if any critical check fails; warns for non-critical.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

if [[ -t 1 ]]; then
  BOLD=$'\033[1m'; RED=$'\033[31m'; GREEN=$'\033[32m'; YELLOW=$'\033[33m'; BLUE=$'\033[34m'; RESET=$'\033[0m'
else
  BOLD=""; RED=""; GREEN=""; YELLOW=""; BLUE=""; RESET=""
fi

PASS=0; FAIL=0; WARN=0

ok()   { PASS=$((PASS+1)); printf "%b✓%b %s\n" "$GREEN" "$RESET" "$1"; }
fail() { FAIL=$((FAIL+1)); printf "%b✗%b %s\n" "$RED" "$RESET" "$1"; }
warn() { WARN=$((WARN+1)); printf "%b!%b %s\n" "$YELLOW" "$RESET" "$1"; }
info() { printf "%b  %b%s\n" "$BLUE" "$RESET" "$1"; }

header() { printf "\n%b==>%b %s\n" "$BOLD" "$RESET" "$1"; }

# --- Helpers ------------------------------------------------------------------
check_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    fail "$1: NOT FOUND"
    return
  fi
  case "$1" in
    go)  ver=$(go version 2>&1) ;;
    tmux) ver=$(tmux -V 2>&1) ;;
    *)   ver=$($1 --version 2>&1) || ver="version check failed" ;;
  esac
  ok "$1: $(echo "$ver" | head -1)"
}

check_file() {
  if [[ -f "$1" ]]; then
    ok "file: $1"
  else
    if [[ $# -ge 2 ]]; then
      fail "file: $1 ($2)"
    else
      fail "file: $1"
    fi
  fi
}

check_dir() {
  if [[ -d "$1" ]]; then
    ok "dir: $1"
  else
    fail "dir: $1"
  fi
}

check_symlink() {
  if [[ -L "$1" ]]; then
    ok "symlink: $1 -> $(readlink "$1")"
  else
    warn "symlink: $1 NOT a symlink"
  fi
}

# =============================================================================
echo "Verify: $DOTFILES_DIR"
echo

# 1. Core tools
header "Core tools"
for cmd in chezmoi age git zsh nvim tmux fzf starship; do
  check_cmd "$cmd"
done
# rage is an age-compatible reimplementation
command -v rage >/dev/null 2>&1 && ok "rage: $(rage --version)" || warn "rage not installed (optional, age-compatible)"

# 2. Modern CLI tools
header "Modern CLI tools"
for cmd in bat eza fd ripgrep delta zoxide lazygit btop yazi; do
  check_cmd "$cmd"
done

# 3. Shell / dev tooling
header "Shell / dev tooling"
for cmd in direnv atuin uv just act gh jq yq; do
  check_cmd "$cmd"
done

# 4. Language toolchains (Arch-centric; warn only)
header "Language toolchains"
for cmd in node npm python3 rustc cargo go; do
  check_cmd "$cmd"
done
command -v bun >/dev/null 2>&1 && ok "bun: $(bun --version)" || warn "bun not installed"
command -v dotnet >/dev/null 2>&1 && ok "dotnet: $(dotnet --version 2>/dev/null | head -1)" || warn "dotnet not installed"

# 5. chezmoi state
header "chezmoi state"
if chezmoi managed >/dev/null 2>&1; then
  COUNT=$(chezmoi managed 2>/dev/null | wc -l)
  ok "chezmoi managed files: $COUNT"
  chezmoi verify >/dev/null 2>&1 && ok "chezmoi verify: all files match" || fail "chezmoi verify: files differ from source"
else
  fail "chezmoi not initialized (run 'chezmoi init --source $DOTFILES_DIR')"
fi

# 6. Shell config
header "Shell config"
check_file "$HOME/.zshenv"
check_file "$HOME/.zshrc"
check_file "$XDG_CONFIG_HOME/zsh/aliases.zsh"
check_file "$XDG_CONFIG_HOME/zsh/exports.zsh"
check_file "$XDG_CONFIG_HOME/zsh/vi-mode.zsh"
check_file "$XDG_CONFIG_HOME/zsh/tools.zsh"
check_file "$XDG_CONFIG_HOME/zsh/prompt.zsh"
check_file "$XDG_CONFIG_HOME/zsh/fzf-tab.zsh"

if [[ "$SHELL" = */zsh ]]; then
  ok "SHELL is zsh: $SHELL"
else
  fail "SHELL is not zsh (currently $SHELL)"
fi

# 7. Git config
header "Git config"
check_file "$HOME/.gitconfig"
check_file "$HOME/.gitconfig.local"
check_file "$HOME/.gitconfig.work"
check_file "$HOME/.gitconfig.personal"

if [[ -f "$HOME/.gitconfig.local" ]] && grep -qE 'Your (Name|Work Name|Personal Name)' "$HOME/.gitconfig.local" 2>/dev/null; then
  warn "~/.gitconfig.local still has placeholder name (edit it!)"
elif [[ -f "$HOME/.gitconfig.local" ]]; then
  ok "~/.gitconfig.local has custom name"
fi

# 8. XDG directories
header "XDG directories"
check_dir "$XDG_CONFIG_HOME"
check_dir "$XDG_DATA_HOME"
check_dir "$XDG_STATE_HOME"
check_dir "$XDG_CACHE_HOME"

# 9. Config directories
header "Config directories"
for dir in ghostty nvim starship.toml yazi zsh atuin btop direnv lazygit delta opencode; do
  path="$XDG_CONFIG_HOME/$dir"
  if [[ -e "$path" ]]; then
    ok "$path"
  else
    fail "$path"
  fi
done

# 10. Zsh plugins
header "Zsh plugins"
for plugin in fzf-tab zsh-autosuggestions zsh-syntax-highlighting; do
  found=0
  for loc in \
    "/usr/share/zsh/plugins/$plugin/$plugin.zsh" \
    "/usr/share/zsh/plugins/$plugin/$plugin.plugin.zsh" \
    "/opt/homebrew/share/$plugin/$plugin.plugin.zsh" \
    "/opt/homebrew/share/$plugin/$plugin.zsh" \
    "$HOME/.zsh/plugins/$plugin/$plugin.plugin.zsh" \
    "$HOME/.zsh/plugins/$plugin/$plugin.zsh"; do
    if [[ -f "$loc" ]]; then
      ok "$plugin: $loc"
      found=1
      break
    fi
  done
  [[ $found -eq 0 ]] && warn "$plugin: not found"
done

# 11. TPM (Tmux Plugin Manager)
header "Tmux"
check_file "$HOME/.tmux/plugins/tpm/tpm"
check_file "$HOME/.tmux.conf"

# 12. Age keys
header "Age encryption"
if [[ -f "$HOME/.config/age/keys.txt" ]]; then
  ok "age keys: $HOME/.config/age/keys.txt"
  # Check if encrypted files exist in chezmoi
  ENCRYPTED=$(chezmoi managed 2>/dev/null | xargs -r chezmoi source-path 2>/dev/null | grep -c '\.age$' 2>/dev/null || true)
  if [[ "$ENCRYPTED" -gt 0 ]]; then
    ok "age encrypted files: $ENCRYPTED"
  fi
else
  warn "age keys not found at ~/.config/age/keys.txt"
fi

# 13. Atuin
header "Atuin"
if command -v atuin >/dev/null; then
  if [[ -f "$HOME/.local/share/atuin/history.db" ]]; then
    ok "atuin history db exists"
  else
    warn "atuin history db not found (run 'atuin import auto')"
  fi
fi

# 14. Starship
header "Starship"
check_file "$XDG_CONFIG_HOME/starship.toml"

# 15. OpenCode config (optional external deps)
header "OpenCode config"
for d in "$HOME/.config/opencode/agents" "$HOME/.config/opencode/skills" \
         "$HOME/.config/opencode/commands" "$HOME/.config/opencode/themes" \
         "$HOME/.config/opencode/instructions"; do
  [[ -d "$d" ]] && ok "$d" || warn "$d not found (created by post-install)"
done
[[ -d "$HOME/.agents/skills/addy-agent-skills" ]] \
  && ok "$HOME/.agents/skills/addy-agent-skills" \
  || warn "addy-agent-skills not found (optional, installed by post-install)"

# 16. PATH / bin
header "PATH / bin"
check_dir "$HOME/.local/bin"
check_dir "$HOME/bin"

echo ""

# Summary
TOTAL=$((PASS + FAIL))
printf "%b%d passed,%b %d failed,%b %d warnings%b (%d total checks)\n" \
  "$GREEN" "$PASS" "$RED" "$FAIL" "$YELLOW" "$WARN" "$RESET" "$TOTAL"

[[ $FAIL -eq 0 ]] && exit 0 || exit 1
