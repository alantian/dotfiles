# Shared, non-secret environment. Keep POSIX-ish and fast.

path_prepend() {
  [ -d "$1" ] || return 0
  case ":$PATH:" in
    *":$1:"*) : ;;
    *) PATH="$1${PATH:+:$PATH}" ;;
  esac
}

export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export PROTO_HOME="${PROTO_HOME:-$HOME/.proto}"

path_prepend "$HOME/.local/bin"
path_prepend "$HOME/bin"

## proto launcher + tool shims/bins
## Keep shims before bin on PATH so runtime version detection works.
path_prepend "$PROTO_HOME/bin"
path_prepend "$PROTO_HOME/shims"

## Homebrew common paths
path_prepend /opt/homebrew/bin

## npm global bins 
path_prepend "$HOME/.npm-global/bin"

## fzf bins 
path_prepend "$HOME/.fzf/bin"

## opencode bins
path_prepend "$HOME/.opencode/bin"

export PATH


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
