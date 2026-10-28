# macOS login-only: full Homebrew environment (MANPATH, INFOPATH, ...)
if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# macOS /etc/zprofile runs path_helper *after* ~/.zshenv and rebuilds PATH with
# the system dirs first. Put Homebrew back ahead of the system dirs, then our
# own dirs ahead of Homebrew (user_path_setup comes from env.zsh).
_hb="${HOMEBREW_PREFIX:-/opt/homebrew}"
path_force_prepend "$_hb/sbin"
path_force_prepend "$_hb/bin"
unset _hb
user_path_setup
