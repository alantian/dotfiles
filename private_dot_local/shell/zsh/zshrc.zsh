bindkey -A emacs main # use emacs keybinding

HISTFILE="$HOME/.zsh_history"
SAVEHIST=1000000
HISTSIZE=1000000

setopt HIST_IGNORE_ALL_DUPS
setopt SHARE_HISTORY

# zsh-history-substring-search config (zsh-only, interactive)
if (( $+functions[history-substring-search-up] )); then
  bindkey "$terminfo[kcuu1]" history-substring-search-up
  bindkey "$terminfo[kcud1]" history-substring-search-down

  bindkey -M emacs '^P' history-substring-search-up
  bindkey -M emacs '^N' history-substring-search-down

  bindkey -M vicmd 'k' history-substring-search-up
  bindkey -M vicmd 'j' history-substring-search-down

  export HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE=1
  export HISTORY_SUBSTRING_SEARCH_FUZZY=1
fi

