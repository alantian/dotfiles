if command -v uv >/dev/null 2>&1; then
  eval "$(uv generate-shell-completion bash)"
fi

if command -v uvx >/dev/null 2>&1; then
  eval "$(uvx --generate-shell-completion bash)"
fi

if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init bash)"
fi

if command -v fzf >/dev/null 2>&1; then
  source <(fzf --bash)
fi

if command -v oh-my-posh >/dev/null 2>&1; then
    OMP_CONFIG_FILE="$HOME/.config/oh-my-posh/themes/catppuccin_latte.omp.json"
    eval "$(oh-my-posh init bash --config "${OMP_CONFIG_FILE}")"
fi