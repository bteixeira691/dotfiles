# ===== Aliases =====
# (kept short, intentional, and predictable)

# --- ls / tree / file ops ----------------------------------------------------
if command -v eza >/dev/null; then
  alias ls="eza --icons --group-directories-first"
  alias ll="eza -alF --icons --group-directories-first"
  alias la="eza -a --icons --group-directories-first"
  alias lt="eza --tree --level=2 --icons"
  alias lta="eza --tree --level=2 -a --icons"
else
  alias ls="ls --color=auto --group-directories-first"
  alias ll="ls -alF"
  alias la="ls -A"
fi
alias l="ls -CF"

# --- nav (zoxide replaces cd for visited dirs) -------------------------------
alias cd="z"   # zoxide handles `cd` so we get `z foo` and `zi` (interactive)

# --- git ---------------------------------------------------------------------
alias g="git"
alias gs="git status"
alias gd="git diff"
alias gds="git diff --staged"
alias ga="git add"
alias gaa="git add --all"
alias gc="git commit"
alias gcm="git commit -m"
alias gp="git push"
alias gpl="git pull"
alias gb="git branch"
alias gco="git checkout"
alias gcb="git checkout -b"
alias gl="git log --oneline --graph --decorate -20"
alias glg="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
alias lg="lazygit"

# --- docker ------------------------------------------------------------------
alias d="docker"
alias dc="docker compose"
alias dcu="docker compose up -d"
alias dcd="docker compose down"
alias dps="docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'"

# --- nvim --------------------------------------------------------------------
alias v="nvim"
alias vi="nvim"
alias vim="nvim"
alias nvimcfg="nvim $XDG_CONFIG_HOME/nvim"

# --- tmux --------------------------------------------------------------------
alias t="tmux"
alias ta="tmux attach"
alias tl="tmux list-sessions"
alias tn="tmux new -s"
alias tk="tmux kill-session -t"

# --- misc --------------------------------------------------------------------
alias cat="bat --paging=auto --style=plain"
alias grep="rg"
alias find="fd"
alias mkdir="mkdir -pv"
alias cp="cp -iv"
alias mv="mv -iv"
alias rm="rm -Iv"   # prompts only on >3 files
alias df="df -h"
alias du="du -h"
alias free="free -h"
alias top="btop"
alias ps="ps auxf"
alias ping="ping -c 5"
alias serve="python3 -m http.server 0.0.0.0"
alias http="xh"   # httpie alternative, faster

# --- python / uv -------------------------------------------------------------
alias py="uv run python"
alias pyi="uv run ipython"
alias pyr="uv run"
alias pyenv="uv python list --only-installed"
alias pip="uv pip"
alias venv="uv venv"
alias venvrm="rm -rf .venv"

# --- node / bun --------------------------------------------------------------
alias n="node"
alias nb="node --enable-source-maps --watch"
alias bunx="bun x"
# Note: pnpm is NOT aliased. If you install pnpm later, it will be used directly.

# --- direnv ------------------------------------------------------------------
alias da="direnv allow"
alias dr="direnv reload"
alias dst="direnv status"

# --- atuin -------------------------------------------------------------------
alias ah="atuin search"
alias al="atuin search --limit 10"
alias ast="atuin stats"

# --- just --------------------------------------------------------------------
alias j="just"
alias jl="just --list"

# --- mprocs / act ------------------------------------------------------------
alias mp="mprocs"
alias arun="act"

# --- gas town / beads --------------------------------------------------------
# https://github.com/gastownhall/gastown
if command -v gt >/dev/null; then
  alias gts="gt status"
  alias gtn="gt nudge"
  alias gtr="gt rig"
  alias gtp="gt prime"
  alias gtd="gt doctor"
  alias gtc="gt convoy"
  alias gtt="gt town"
fi

if command -v bd >/dev/null; then
  alias bdr="bd ready"
  alias bdl="bd list"
  alias bdc="bd close"
  alias bds="bd show"
  alias bdu="bd update"
  alias bdx="bd sync"
fi

if command -v bv >/dev/null; then
  alias bvt="bv --robot-triage"
  alias bvn="bv --robot-next"
  alias bvp="bv --robot-plan"
  alias bva="bv --robot-alerts"
  alias bvi="bv --robot-insights"
fi

# --- lazydocker / dive -------------------------------------------------------
alias lzd="lazydocker"
alias dimg="dive"

# --- hyperfine / bench -------------------------------------------------------
alias bench="hyperfine --warmup 1 --runs 5"

# --- trash (safer rm) --------------------------------------------------------
if command -v trash >/dev/null; then
  alias rmt="trash"
fi

# Quick reload
alias reload="source $ZDOTDIR/.zshrc && echo 'zsh reloaded'"

# --- safety ------------------------------------------------------------------
alias chmod="chmod --preserve-root -v"
alias chown="chown --preserve-root"

# --- sudo preserve path ------------------------------------------------------
alias sudo="sudo -E "
