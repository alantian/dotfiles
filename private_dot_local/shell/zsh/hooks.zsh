[ -r "$HOME/.local/shell/zsh/plugins.zsh" ] && . "$HOME/.local/shell/zsh/plugins.zsh"

autoload -Uz compinit
compinit

if [[ -r /opt/homebrew/share/google-cloud-sdk/path.zsh.inc ]]; then
  source /opt/homebrew/share/google-cloud-sdk/path.zsh.inc
fi
if [[ -r /opt/homebrew/share/google-cloud-sdk/completion.zsh.inc ]]; then
  source /opt/homebrew/share/google-cloud-sdk/completion.zsh.inc
fi

if command -v uv >/dev/null 2>&1; then
  eval "$(uv generate-shell-completion zsh)"
fi

if command -v uvx >/dev/null 2>&1; then
  eval "$(uvx --generate-shell-completion zsh)"
fi

if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

if command -v fzf >/dev/null 2>&1; then
  source <(fzf --zsh)
fi

if command -v oh-my-posh >/dev/null 2>&1; then
  OMP_CONFIG_FILE="$HOME/.config/oh-my-posh/themes/catppuccin_latte.omp.json"
  if [[ -r "$OMP_CONFIG_FILE" ]]; then
    eval "$(oh-my-posh init zsh --config "$OMP_CONFIG_FILE")"
  fi
fi


