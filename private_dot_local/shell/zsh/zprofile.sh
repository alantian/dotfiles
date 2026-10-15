for _l in "os/$SHELL_OS" "os/$SHELL_DISTRO" "hosts/${HOST%%.*}"; do
  [ -r "$HOME/.local/shell/shared/$_l.profile.sh" ] && . "$HOME/.local/shell/shared/$_l.profile.sh"
done
unset _l
