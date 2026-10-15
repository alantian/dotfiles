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

# Host-local zsh config, deliberately outside chezmoi. Loaded last so it can
# override everything above. This is the ONLY sanctioned loader: the file must
# start with `[[ -n ${_ZSHRC_LOCAL_FROM_DOTFILES-} ]] || return`, so any other
# loader (Arch's grml /etc/zsh/zshrc sources it early) is a no-op.
if [ -r "$HOME/.zshrc.local" ]; then
  _ZSHRC_LOCAL_FROM_DOTFILES=1
  . "$HOME/.zshrc.local"
  unset _ZSHRC_LOCAL_FROM_DOTFILES
fi
