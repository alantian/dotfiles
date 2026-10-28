# Login-only setup (sourced by ~/.zprofile). Base has nothing; the layers do
# (macOS: brew shellenv and the PATH re-assert after path_helper).
for _l in "os/$SHELL_OS" "os/$SHELL_DISTRO" "hosts/${HOST%%.*}"; do
  [ -r "$HOME/.local/shell/$_l.profile.zsh" ] && . "$HOME/.local/shell/$_l.profile.zsh"
done
unset _l
