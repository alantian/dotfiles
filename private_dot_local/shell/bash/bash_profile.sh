[ -r "$HOME/.local/shell/bash/bashrc.sh" ] && . "$HOME/.local/shell/bash/bashrc.sh"
[ -r "$HOME/.secrets.sh" ] && . "$HOME/.secrets.sh"

if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi