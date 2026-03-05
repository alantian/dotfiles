# Shared, non-secret environment. Keep POSIX-ish and fast.

path_prepend() {
  [ -d "$1" ] || return 0
  case ":$PATH:" in
    *":$1:"*) : ;;
    *) PATH="$1${PATH:+:$PATH}" ;;
  esac
}

path_prepend "$HOME/.local/bin"
path_prepend "$HOME/bin"

## proto shims/bins (uv installed via proto)
path_prepend "$HOME/.proto/shims"
path_prepend "$HOME/.proto/bin"

## Homebrew common paths
path_prepend /opt/homebrew/bin

## npm global bins 
path_prepend "$HOME/.npm-global/bin"

## fzf bins 
path_prepend "$HOME/.fzf/bin"

## opencode bins
path_prepend "$HOME/.opencode/bin"

export PATH


export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"


export EDITOR="${EDITOR:-vim}"
export PAGER="${PAGER:-less}"
export LANG="${LANG:-en_US.UTF-8}"