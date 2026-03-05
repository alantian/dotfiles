[ -r "$HOME/.secrets.sh" ] && . "$HOME/.secrets.sh"
command -v direnv >/dev/null 2>&1 && eval "$(direnv hook zsh)"

if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi