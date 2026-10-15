H="${HOST%%.*}"

. "$HOME/.local/shell/shared/interactive.sh"
. "$HOME/.local/shell/shared/aliases.sh"
for _l in "os/$SHELL_OS" "os/$SHELL_DISTRO" "hosts/$H"; do
  [ -r "$HOME/.local/shell/shared/$_l.interactive.sh" ] && . "$HOME/.local/shell/shared/$_l.interactive.sh"
done

[ -r "$HOME/.local/shell/zsh/zshrc.zsh" ] && . "$HOME/.local/shell/zsh/zshrc.zsh"
[ -r "$HOME/.local/shell/zsh/hooks.zsh" ] && . "$HOME/.local/shell/zsh/hooks.zsh"
for _l in "os/$SHELL_OS" "os/$SHELL_DISTRO" "hosts/$H"; do
  [ -r "$HOME/.local/shell/zsh/$_l.zsh" ] && . "$HOME/.local/shell/zsh/$_l.zsh"
done
unset _l
