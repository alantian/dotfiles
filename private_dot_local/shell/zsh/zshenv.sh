. "$HOME/.local/shell/shared/env.sh"

H="$(hostname -s)"
[ -r "$HOME/.local/shell/shared/hosts/$H.env.sh" ] && . "$HOME/.local/shell/shared/hosts/$H.env.sh"
