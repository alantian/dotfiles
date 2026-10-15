[ -r "$HOME/.local/shell/bash/bashrc.sh" ] && . "$HOME/.local/shell/bash/bashrc.sh"

for _l in "os/$SHELL_OS" "os/$SHELL_DISTRO" "hosts/${HOSTNAME%%.*}"; do
  [ -r "$HOME/.local/shell/shared/$_l.profile.sh" ] && . "$HOME/.local/shell/shared/$_l.profile.sh"
done
unset _l
