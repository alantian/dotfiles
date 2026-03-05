H="${HOST%%.*}"

. "$HOME/.local/shell/shared/interactive.sh"
. "$HOME/.local/shell/shared/aliases.sh"
[ -r "$HOME/.local/shell/shared/hosts/$H.interactive.sh" ] && . "$HOME/.local/shell/shared/hosts/$H.interactive.sh"

[ -r "$HOME/.local/shell/zsh/zshrc.zsh" ] && . "$HOME/.local/shell/zsh/zshrc.zsh"
[ -r "$HOME/.local/shell/zsh/hooks.zsh" ] && . "$HOME/.local/shell/zsh/hooks.zsh"
[ -r "$HOME/.local/shell/zsh/hosts/$H.zsh" ] && . "$HOME/.local/shell/zsh/hosts/$H.zsh"
