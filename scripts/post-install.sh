#!/usr/bin/env bash
# Post-install hooks: runs after chezmoi apply
set -euo pipefail

echo "==> Post-install hooks"

# Install LazyVim extras and sync plugins
if command -v nvim >/dev/null; then
  echo "  -> nvim will install LazyVim plugins on first run"
fi

# Set zsh as default shell if not already
if command -v zsh >/dev/null && [[ "$SHELL" != */zsh ]]; then
  echo "  -> Setting zsh as default shell"
  chsh -s "$(command -v zsh)" 2>/dev/null || sudo chsh -s "$(command -v zsh)" "$USER"
fi

# Starship cache dir
if command -v starship >/dev/null; then
  mkdir -p "$HOME/.cache/starship"
fi

# tmux: install tpm (Tmux Plugin Manager) on first run
if command -v tmux >/dev/null && [[ ! -d $HOME/.tmux/plugins/tpm ]]; then
  echo "  -> Installing tpm (Tmux Plugin Manager)"
  git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm
fi

# Install fzf-git
if [[ ! -d $HOME/.fzf-git ]]; then
  echo "  -> Installing fzf-git"
  git clone https://github.com/junegunn/fzf-git.sh $HOME/.fzf-git 2>/dev/null || true
fi

# Install fzf-tab plugin (where pkg manager didn't provide it)
if [[ ! -d $HOME/.zsh/plugins/fzf-tab ]] && [[ ! -d /usr/share/zsh/plugins/fzf-tab ]] && [[ ! -d /opt/homebrew/share/fzf-tab ]]; then
  echo "  -> Installing fzf-tab plugin to ~/.zsh/plugins/fzf-tab"
  mkdir -p "$HOME/.zsh/plugins"
  git clone https://github.com/Aloxaf/fzf-tab $HOME/.zsh/plugins/fzf-tab
fi

# Install zsh-autosuggestions if not provided by pkg manager
if [[ ! -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]] \
   && [[ ! -f /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]] \
   && [[ ! -d $HOME/.zsh/plugins/zsh-autosuggestions ]]; then
  echo "  -> Installing zsh-autosuggestions"
  git clone https://github.com/zsh-users/zsh-autosuggestions $HOME/.zsh/plugins/zsh-autosuggestions
fi

# Install zsh-syntax-highlighting if not provided by pkg manager
if [[ ! -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] \
   && [[ ! -f /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] \
   && [[ ! -d $HOME/.zsh/plugins/zsh-syntax-highlighting ]]; then
  echo "  -> Installing zsh-syntax-highlighting"
  git clone https://github.com/zsh-users/zsh-syntax-highlighting $HOME/.zsh/plugins/zsh-syntax-highlighting
fi

# Install zsh-vi-mode if not provided by pkg manager
if [[ ! -f /usr/share/zsh-vi-mode/zsh-vi-mode.zsh ]] \
   && [[ ! -f /opt/homebrew/share/zsh-vi-mode/zsh-vi-mode.zsh ]] \
   && [[ ! -d $HOME/.zsh/plugins/zsh-vi-mode ]]; then
  echo "  -> Installing zsh-vi-mode to ~/.zsh/plugins/zsh-vi-mode"
  mkdir -p "$HOME/.zsh/plugins"
  git clone https://github.com/jeffreytse/zsh-vi-mode $HOME/.zsh/plugins/zsh-vi-mode
fi

# Atuin: import history from existing shell (one-time, only if no Atuin db)
if command -v atuin >/dev/null && [[ ! -f $HOME/.local/share/atuin/history.db ]]; then
  echo "  -> Importing shell history into Atuin"
  if [[ -f $HOME/.zsh_history ]]; then
    atuin import auto 2>/dev/null || true
  fi
fi

# Atuin: nothing to do here; keybinding is set in dot_zshrc
# (Atuin manages its own DB. The user runs `atuin register` / `atuin login` separately
# if they want cloud sync. We don't auto-create that.)

# direnv: create per-project allow helper alias
echo "  -> direnv: use 'da' to allow, 'dr' to reload, 'dst' for status"

# Create includeIf work/personal stubs if missing
if [[ ! -f $HOME/.gitconfig.local ]]; then
  dotfiles_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
  if [[ -f "$dotfiles_root/docs/gitconfig.local.example" ]]; then
    cp "$dotfiles_root/docs/gitconfig.local.example" "$HOME/.gitconfig.local"
    echo "  -> Created ~/.gitconfig.local (EDIT IT with your name/email)"
  fi
fi

if [[ ! -f $HOME/.gitconfig.work ]]; then
  cat > "$HOME/.gitconfig.work" <<'EOF'
# Work identity (loaded for repos in ~/work/*)
[user]
  name = Your Work Name
  email = you@work.com
EOF
  echo "  -> Created stub ~/.gitconfig.work"
fi

if [[ ! -f $HOME/.gitconfig.personal ]]; then
  cat > "$HOME/.gitconfig.personal" <<'EOF'
# Personal identity (loaded for repos in ~/personal/*)
[user]
  name = Your Personal Name
  email = you@personal.com
EOF
  echo "  -> Created stub ~/.gitconfig.personal"
fi

# Bun: create global install dir (avoids warnings on first `bun add -g`)
mkdir -p "$HOME/.bun/install/global" 2>/dev/null || true

# mise: trust is per-project, not global — print a hint
echo "  -> mise: trust project configs with 'mise trust' inside each project"

# yazi: create cache dir
mkdir -p "$HOME/.cache/yazi" 2>/dev/null || true

# Pre-warm starship cache (faster first prompt)
if command -v starship >/dev/null; then
  starship print-config >/dev/null 2>&1 || true
fi

# OpenCode: scaffold the ~/.config/opencode directories
mkdir -p "$HOME/.config/opencode"/{agents,skills,commands,themes,instructions}
mkdir -p "$HOME/.agents/skills" "$HOME/.opencode/skills"

# OpenCode: install addyosmani/agent-skills
AGENT_SKILLS_REPO="$HOME/.agents/skills/addy-agent-skills"
if [[ ! -d "$AGENT_SKILLS_REPO" ]]; then
  echo "  -> Installing addyosmani/agent-skills"
  git clone --depth 1 https://github.com/addyosmani/agent-skills.git "$AGENT_SKILLS_REPO"
fi
for skill in "$AGENT_SKILLS_REPO/skills"/*/; do
  name="$(basename "$skill")"
  target="$HOME/.opencode/skills/$name"
  [[ ! -L "$target" ]] && ln -sf "$skill" "$target"
done

# Recompute skills-lock.json hashes (replace placeholders with real sha256)
if [[ -f "$HOME/.config/opencode/skills-lock.json" ]]; then
  echo "  -> Recomputing skill hashes in skills-lock.json"
  python3 - <<'PYEOF' 2>/dev/null || true
import json, hashlib
from datetime import datetime, timezone
from pathlib import Path

lock = Path.home() / ".config/opencode/skills-lock.json"
data = json.loads(lock.read_text())
now = datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")
for name, entry in data.get("skills", {}).items():
    p = Path(entry.get("skillPath", "")).expanduser()
    if p.exists():
        entry["computedHash"] = hashlib.sha256(p.read_bytes()).hexdigest()
        # Set installedAt on first install (placeholder), preserve on subsequent runs
        if entry.get("installedAt", "").startswith("REPLACE") or not entry.get("installedAt"):
            entry["installedAt"] = now
        entry["lastVerifiedAt"] = now
lock.write_text(json.dumps(data, indent=2) + "\n")
PYEOF
fi

# Gas town: check if installed
if command -v gt >/dev/null; then
  echo "  -> Gas town installed: $(command -v gt)"
  echo "     Initialize a town with:  gt town new"
  echo "     Available commands:     gt, bd, bv  (all set up by post-install)"
else
  echo "  -> Gas town not installed (optional)"
  echo "     Install with:  go install github.com/gastownhall/gastown/cmd/gt@latest"
  echo "                    go install github.com/gastownhall/beads/cmd/bd@latest"
  echo "                    go install github.com/gastownhall/beads/cmd/bv@latest"
  echo "     See:           https://github.com/gastownhall/gastown"
fi

# Hook up the new-skill / new-agent scaffolders (add to ~/.local/bin)
dotfiles_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [[ -d "$dotfiles_root/scripts" ]]; then
  mkdir -p "$HOME/.local/bin"
  for scaffolder in new-skill.sh new-agent.sh; do
    src="$dotfiles_root/scripts/$scaffolder"
    dst="$HOME/.local/bin/${scaffolder%.sh}"
    if [[ -f "$src" ]]; then
      cp "$src" "$dst"
      chmod +x "$dst"
    fi
  done
  echo "  -> Scaffolders: new-skill, new-agent (in ~/.local/bin)"
fi

# Show summary
echo ""
echo "✓ Post-install done"
echo ""
echo "Next steps:"
echo "  1. Edit ~/.gitconfig.local with your name/email"
echo "  2. Edit ~/.gitconfig.work and ~/.gitconfig.personal"
echo "  3. (Optional) Register Atuin account:  atuin register -u <user> -e <email>"
echo "  4. (Optional) Login to Atuin:          atuin login -u <user>"
echo "  5. (Optional) Enable sync:             atuin sync"
echo "  6. (Optional) Trust mise in projects:  cd ~/work/proj && mise trust"
echo "  7. (Optional) Initialize gas town:     gt town new"
echo "  8. (Optional) Add a new skill:         new-skill my-pattern-name"
echo "  9. (Optional) Add a new agent:         new-agent my-role-name"
echo " 10. Reload zsh:                         source ~/.zshrc"
echo ""
