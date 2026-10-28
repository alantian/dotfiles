# Interactive shell (sourced by ~/.zshrc): env tweaks, aliases, zsh options,
# then hooks.zsh (plugins, completions, prompt), the os/distro/host layers,
# and last ~/.zshrc.local.

export LESS="-FRX"
export LESSHISTFILE="-"

mkcd() { mkdir -p "$1" && cd "$1" || return; }

if command -v thefuck >/dev/null 2>&1; then
  # This is the output of:
  #    eval "$(thefuck --alias)"
  # Update as they are changed.
  # Doing so to accelerate the shell startup
  fuck () {
      TF_PYTHONIOENCODING=$PYTHONIOENCODING;
      export TF_SHELL=zsh;
      export TF_ALIAS=fuck;
      TF_SHELL_ALIASES=$(alias);
      export TF_SHELL_ALIASES;
      TF_HISTORY="$(fc -ln -10)";
      export TF_HISTORY;
      export PYTHONIOENCODING=utf-8;
      TF_CMD=$(
          thefuck THEFUCK_ARGUMENT_PLACEHOLDER "$@"
      ) && eval "$TF_CMD";
      unset TF_HISTORY;
      export PYTHONIOENCODING=$TF_PYTHONIOENCODING;
      test -n "$TF_CMD" && print -s "$TF_CMD"
  }
fi

alias ll='ls -alF'
alias la='ls -A'
alias gs='git status'
alias gd='git diff'

alias gssh='gcloud compute ssh'
alias gscp='gcloud compute scp'

# Run with a system-ish PATH
sys() { command env PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" "$@"; }


bindkey -A emacs main # use emacs keybinding

HISTFILE="$HOME/.zsh_history"
SAVEHIST=1000000
HISTSIZE=1000000

setopt HIST_IGNORE_ALL_DUPS
setopt SHARE_HISTORY

[ -r "$HOME/.local/shell/hooks.zsh" ] && . "$HOME/.local/shell/hooks.zsh"

# zsh-history-substring-search config; must come after hooks.zsh loads the plugin
if (( $+functions[history-substring-search-up] )); then
  [[ -n $terminfo[kcuu1] ]] && bindkey "$terminfo[kcuu1]" history-substring-search-up
  [[ -n $terminfo[kcud1] ]] && bindkey "$terminfo[kcud1]" history-substring-search-down

  bindkey -M emacs '^P' history-substring-search-up
  bindkey -M emacs '^N' history-substring-search-down

  bindkey -M vicmd 'k' history-substring-search-up
  bindkey -M vicmd 'j' history-substring-search-down

  export HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE=1
  export HISTORY_SUBSTRING_SEARCH_FUZZY=1
fi

for _l in "os/$SHELL_OS" "os/$SHELL_DISTRO" "hosts/${HOST%%.*}"; do
  [ -r "$HOME/.local/shell/$_l.rc.zsh" ] && . "$HOME/.local/shell/$_l.rc.zsh"
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
