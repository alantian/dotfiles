H="${HOSTNAME%%.*}"

. "$HOME/.local/shell/shared/env.sh"
[ -r "$HOME/.local/shell/shared/hosts/$H.env.sh" ] && . "$HOME/.local/shell/shared/hosts/$H.env.sh"

. "$HOME/.local/shell/shared/interactive.sh"
. "$HOME/.local/shell/shared/aliases.sh"
[ -r "$HOME/.local/shell/shared/hosts/$H.interactive.sh" ] && . "$HOME/.local/shell/shared/hosts/$H.interactive.sh"

[ -r "$HOME/.local/shell/bash/bashrc.bash" ] && . "$HOME/.local/shell/bash/bashrc.bash"
[ -r "$HOME/.local/shell/bash/hooks.bash" ] && . "$HOME/.local/shell/bash/hooks.bash"
[ -r "$HOME/.local/shell/bash/hosts/$H.bash" ] && . "$HOME/.local/shell/bash/hosts/$H.bash"

command -v direnv >/dev/null 2>&1 && eval "$(direnv hook bash)"
