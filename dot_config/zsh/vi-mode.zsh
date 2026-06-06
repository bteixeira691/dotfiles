# ===== zsh-vi-mode =====
# Vim-style modal editing in the prompt.
# https://github.com/jeffreytse/zsh-vi-mode

# Install via package manager (zsh-vi-mode is in the package list)

# --- Keybindings (override the default vi-mode ones) ------------------------
# Use jj to leave insert mode (vim muscle memory)
ZVM_VI_INSERT_ESCAPE_BINDKEY=jj
ZVM_VI_ESCAPE_BINDKEY=jk

# Custom cursor shapes per mode
ZVM_NORMAL_MODE_CURSOR=$'\e[2 q'         # block
ZVM_INSERT_MODE_CURSOR=$'\e[6 q'         # bar
ZVM_VISUAL_MODE_CURSOR=$'\e[4 q'         # underline
ZVM_OPPEND_MODE_CURSOR=$'\e[6 q'

# --- Key bindings for history search -----------------------------------------
# In normal mode:
#   /   - search history (vim style)
#   n/N - next/prev match
#   .   - repeat last command (vim style)

# Initialize (sourced after compinit)
source /usr/share/zsh-vi-mode/zsh-vi-mode.zsh 2>/dev/null \
  || source /opt/homebrew/share/zsh-vi-mode/zsh-vi-mode.zsh 2>/dev/null \
  || source /usr/local/share/zsh-vi-mode/zsh-vi-mode.zsh 2>/dev/null

# After plugin loads, customize
function zvm_after_init() {
  zvm_bindkey vicmd '/' history-incremental-pattern-search-backward
  zvm_bindkey vicmd '?' history-incremental-pattern-search-forward
  zvm_bindkey vicmd 'gg' beginning-of-history
  zvm_bindkey vicmd 'G'  end-of-history
}
