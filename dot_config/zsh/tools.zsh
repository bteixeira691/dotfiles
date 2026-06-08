# ===== Tool integrations =====
# Load order matters. Heavy/early stuff first.

# --- mise: auto-use project-local versions ----------------------------------
if command -v mise >/dev/null; then
  eval "$(mise activate zsh)"
fi

# --- fzf-git: show git objects in fzf ----------------------------------------
# https://github.com/junegunn/fzf-git
if command -v fzf >/dev/null && [[ -f $HOME/.fzf-git/fzf-git.sh ]]; then
  source $HOME/.fzf-git/fzf-git.sh
fi

# --- zsh-autosuggestions ----------------------------------------------------
# (Fish-like autosuggestions from history)
for plugin in \
  /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh \
  /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh \
  /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh \
  $HOME/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
do
  [[ -f $plugin ]] && source $plugin && break
done

# --- zsh-syntax-highlighting (must be LAST among the plugins) --------------
# After all the other plugins that modify widgets/keybinds
for plugin in \
  /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
  /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
  /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
  $HOME/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
do
  [[ -f $plugin ]] && source $plugin && break
done
