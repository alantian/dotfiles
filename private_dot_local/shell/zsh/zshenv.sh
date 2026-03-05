. "$HOME/.local/shell/shared/env.sh"

H="${HOST%%.*}"
[ -r "$HOME/.local/shell/shared/hosts/$H.env.sh" ] && . "$HOME/.local/shell/shared/hosts/$H.env.sh"
