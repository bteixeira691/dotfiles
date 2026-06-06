# ===== Per-shell exports that depend on shell being interactive =====
# Most env vars are in .zshenv. This file is for things that need interactive shell.

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

# --- lazygit -----------------------------------------------------------------
export LG_CONFIG_FILE="$XDG_CONFIG_HOME/lazygit/config.yml"

# --- yazi (file manager) -----------------------------------------------------
export YAZI_CONFIG_HOME="$XDG_CONFIG_HOME/yazi"

# --- mise (when not activated as plugin) -------------------------------------
if ! command -v mise >/dev/null; then
  export PATH="$HOME/.local/share/mise/shims:$PATH"
fi

# --- language versions -------------------------------------------------------
# mise handles these, but fallback paths:
[[ -d $HOME/.nvm ]] && export NVM_DIR="$HOME/.nvm"

# --- dev quickies ------------------------------------------------------------
export WORKON_HOME="$HOME/.virtualenvs"
export PROJECT_HOME="$HOME/projects"
export PYTHONDONTWRITEBYTECODE=1
export PYTHONUNBUFFERED=1
export PIP_REQUIRE_VIRTUALENV=1
export NODE_OPTIONS="--max-old-space-size=4096"
