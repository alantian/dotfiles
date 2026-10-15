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

# Machine-local zsh config, deliberately outside chezmoi. Loaded last so it can
# override everything above. On Arch with grml-zsh-config, /etc/zsh/zshrc has
# already sourced it before ~/.zshrc; the file sets _ZSHRC_LOCAL_LOADED so this
# second load is skipped. Elsewhere this is the only load.
if [ -z "${_ZSHRC_LOCAL_LOADED-}" ] && [ -r "$HOME/.zshrc.local" ]; then
  . "$HOME/.zshrc.local"
fi
