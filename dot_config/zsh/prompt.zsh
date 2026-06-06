# ===== Prompt =====
# Starship on Linux/macOS, Oh-My-Posh on Windows (set in tools.zsh)

if command -v starship >/dev/null; then
  eval "$(starship init zsh)"
elif [[ "$OS" == "Windows_NT" ]] && command -v oh-my-posh >/dev/null; then
  eval "$(oh-my-posh init zsh --config $XDG_CONFIG_HOME/omp/omp.json)"
fi
