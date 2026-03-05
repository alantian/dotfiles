export LESS="-FRX"
export LESSHISTFILE="-"

mkcd() { mkdir -p "$1" && cd "$1" || return; }

# Only on macOS, only if the app exists, and only if tailscale isn't already on PATH
if [ "$(uname -s)" = "Darwin" ] \
  && [ -x "/Applications/Tailscale.app/Contents/MacOS/Tailscale" ] \
  && ! command -v tailscale >/dev/null 2>&1; then
  alias tailscale="/Applications/Tailscale.app/Contents/MacOS/Tailscale"
fi

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
          thefuck THEFUCK_ARGUMENT_PLACEHOLDER $@
      ) && eval $TF_CMD;
      unset TF_HISTORY;
      export PYTHONIOENCODING=$TF_PYTHONIOENCODING;
      test -n "$TF_CMD" && print -s $TF_CMD
  }
fi