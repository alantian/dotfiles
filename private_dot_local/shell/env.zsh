# Environment for every zsh (sourced by ~/.zshenv). Fast, no aliases, no secrets.

path_prepend() {
  [ -d "$1" ] || return 0
  case ":$PATH:" in
    *":$1:"*) : ;;
    *) PATH="$1${PATH:+:$PATH}" ;;
  esac
}

# Remove every occurrence of $1 from PATH. Pure shell, no forks.
path_remove() {
  _p=":$PATH:"
  while case $_p in *":$1:"*) true ;; *) false ;; esac; do
    _p="${_p%%":$1:"*}:${_p#*":$1:"}"
  done
  _p=${_p#:}; PATH=${_p%:}
  unset _p
}

# Prepend $1 even if it is already on PATH (moves it to the front).
path_force_prepend() {
  [ -d "$1" ] || return 0
  path_remove "$1"
  PATH="$1${PATH:+:$PATH}"
}

export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export PROTO_HOME="${PROTO_HOME:-$HOME/.proto}"

## OS / distro tags for the os/ layer (os/<tag>.{env,profile,rc}.zsh).
## SHELL_OS is darwin|linux|other; SHELL_DISTRO is the ID from /etc/os-release
## on Linux (arch, ubuntu, ...) or empty. Fork-free: uses $OSTYPE (set by
## zsh) and a builtin read of /etc/os-release; falls back to uname only if
## $OSTYPE is unset. Cost is ~10 microseconds.
case "${OSTYPE:-$(uname -s)}" in
  darwin*|Darwin) SHELL_OS=darwin ;;
  linux*|Linux)   SHELL_OS=linux ;;
  *)              SHELL_OS=other ;;
esac
SHELL_DISTRO=""
if [ "$SHELL_OS" = linux ] && [ -r /etc/os-release ]; then
  while IFS= read -r _l; do
    case $_l in
      ID=*) SHELL_DISTRO=${_l#ID=}; SHELL_DISTRO=${SHELL_DISTRO%\"}; SHELL_DISTRO=${SHELL_DISTRO#\"}; break ;;
    esac
  done < /etc/os-release
  unset _l
fi
export SHELL_OS SHELL_DISTRO

## Our user-owned bin dirs, in priority order (last call wins = first on PATH).
## Forced, so calling this again after something else prepended (Homebrew on
## macOS, macOS path_helper) restores this order. Idempotent and fork-free.
user_path_setup() {
  path_force_prepend "$HOME/.local/bin"
  path_force_prepend "$HOME/bin"
  ## proto launcher + tool shims/bins; shims before bin so version detection works
  path_force_prepend "$PROTO_HOME/bin"
  path_force_prepend "$PROTO_HOME/shims"
  ## npm global bins (prefix from ~/.npmrc)
  path_force_prepend "$HOME/.npm-global/bin"
  path_force_prepend "$HOME/.fzf/bin"
  path_force_prepend "$HOME/.opencode/bin"
  path_force_prepend "$HOME/.kimi-code/bin"
  export PATH
}
user_path_setup


export EDITOR="${EDITOR:-vim}"
export PAGER="${PAGER:-less}"
export LANG="${LANG:-en_US.UTF-8}"

## Load user-level env files if present. .env first (shared defaults),
## then .env.local (host-specific overrides / secrets). `set -a` auto-exports
## every assignment so child processes (e.g. `uv run`) inherit them.
for f in "$HOME/.env" "$HOME/.env.local"; do
  if [ -r "$f" ]; then
    set -a
    . "$f"
    set +a
  fi
done
unset f

## Layers: os/<os>, os/<distro>, hosts/<host>; later wins.
for _l in "os/$SHELL_OS" "os/$SHELL_DISTRO" "hosts/${HOST%%.*}"; do
  [ -r "$HOME/.local/shell/$_l.env.zsh" ] && . "$HOME/.local/shell/$_l.env.zsh"
done
unset _l
