H="${HOSTNAME%%.*}"

. "$HOME/.local/shell/shared/env.sh"
for _l in "os/$SHELL_OS" "os/$SHELL_DISTRO" "hosts/$H"; do
  [ -r "$HOME/.local/shell/shared/$_l.env.sh" ] && . "$HOME/.local/shell/shared/$_l.env.sh"
done

. "$HOME/.local/shell/shared/interactive.sh"
. "$HOME/.local/shell/shared/aliases.sh"
for _l in "os/$SHELL_OS" "os/$SHELL_DISTRO" "hosts/$H"; do
  [ -r "$HOME/.local/shell/shared/$_l.interactive.sh" ] && . "$HOME/.local/shell/shared/$_l.interactive.sh"
done

[ -r "$HOME/.local/shell/bash/bashrc.bash" ] && . "$HOME/.local/shell/bash/bashrc.bash"
[ -r "$HOME/.local/shell/bash/hooks.bash" ] && . "$HOME/.local/shell/bash/hooks.bash"
for _l in "os/$SHELL_OS" "os/$SHELL_DISTRO" "hosts/$H"; do
  [ -r "$HOME/.local/shell/bash/$_l.bash" ] && . "$HOME/.local/shell/bash/$_l.bash"
done
unset _l
