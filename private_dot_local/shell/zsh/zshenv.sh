. "$HOME/.local/shell/shared/env.sh"

H="${HOST%%.*}"
for _l in "os/$SHELL_OS" "os/$SHELL_DISTRO" "hosts/$H"; do
  [ -r "$HOME/.local/shell/shared/$_l.env.sh" ] && . "$HOME/.local/shell/shared/$_l.env.sh"
done
unset _l
