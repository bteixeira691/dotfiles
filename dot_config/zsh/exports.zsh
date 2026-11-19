# ===== Per-shell exports that depend on shell being interactive =====
# Machine-wide env (PATH, XDG, language toolchains) lives in ~/.zshenv.
# This file only holds interactive-shell wiring.

# --- fzf ---------------------------------------------------------------------
if command -v fzf >/dev/null; then
  export FZF_COMPLETION_TRIGGER='**'
  export FZF_TMUX=1
  export FZF_TMUX_HEIGHT='40%'
fi

# --- delta (git pager) -------------------------------------------------------
if command -v delta >/dev/null; then
  export GIT_PAGER="delta"
fi

# --- bat ---------------------------------------------------------------------
if command -v bat >/dev/null; then
  export BAT_STYLE="numbers,changes,header"
fi

# --- gh (GitHub CLI) ---------------------------------------------------------
if command -v gh >/dev/null; then
  export GH_CONFIG_DIR="$XDG_CONFIG_HOME/gh"
fi

# --- language versions -------------------------------------------------------
# mise handles these, but keep nvm's dir discoverable if nvm is installed.
[[ -d $HOME/.nvm ]] && export NVM_DIR="$HOME/.nvm"

# --- dev quickies ------------------------------------------------------------
export WORKON_HOME="$HOME/.virtualenvs"
export PROJECT_HOME="$HOME/projects"
export PYTHONUNBUFFERED=1
export PIP_REQUIRE_VIRTUALENV=1
