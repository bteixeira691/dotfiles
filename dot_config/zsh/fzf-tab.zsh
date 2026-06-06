# =================== fzf-tab ===================
# https://github.com/Aloxaf/fzf-tab
# Replaces zsh's default tab completion with fzf.

# Enable fzf-tab
# (loaded by tools.zsh after compinit, before fzf key-bindings)

# Use fzf's --tmux if available (better in tmux)
zstyle ':fzf-tab:*' switch-group ',' '|' ' '

# Show group index when multiple groups match
zstyle ':fzf-tab:*' group-indices '①②③④⑤⑥⑦⑧⑨⑩'

# Default preview: show file content
zstyle ':fzf-tab:complete:*:*' fzf-preview 'cat ${realpath} 2>/dev/null | head -200'
zstyle ':fzf-tab:complete:*:*' popup-min-size 50  # 50% width

# Git-related completions
zstyle ':fzf-tab:complete:git-(add|diff|restore):*' fzf-preview 'git diff --color=always -- $word'
zstyle ':fzf-tab:complete:git-log:*' fzf-preview 'git log --color=always --pretty=format:"%h %s" $word'
zstyle ':fzf-tab:complete:git-checkout:*' fzf-preview 'git log --color=always -n 20 --pretty=format:"%h %s" $word'
zstyle ':fzf-tab:complete:git-show:*' fzf-preview 'git show --color=always $word'
zstyle ':fzf-tab:complete:git-status:*' fzf-preview 'git status --short'

# Process completion
zstyle ':completion:*:*:killall:*' fzf-preview 'ps -p $word 2>/dev/null'
zstyle ':completion:*:*:kill:*' fzf-preview 'ps -p $word 2>/dev/null'

# SSH
zstyle ':fzf-tab:complete:ssh:*:' fzf-preview 'cat ~/.ssh/config 2>/dev/null | grep -i "host " | head -50'

# File: show file info
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath 2>/dev/null | head -100'
zstyle ':fzf-tab:complete:ls:*' fzf-preview 'eza -1 --color=always $realpath 2>/dev/null | head -100'

# Tailwind: show color for color completions (if available)
zstyle ':fzf-tab:complete:tailwind:*' fzf-preview 'echo "$word" | head -1'

# Disable sort for completion groups (preserve order)
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':fzf-tab:*' show-group default

# Single tab to expand groups, double tab to enter fzf
zstyle ':fzf-tab:*' single-group color
zstyle ':fzf-tab:*' prefix-hidden true
zstyle ':fzf-tab:*' hide-groups ''
zstyle ':fzf-tab:*' fzf-flags --height=60% --layout=reverse --border=rounded

# Insert single completion
zstyle ':fzf-tab:*' insert-space false
