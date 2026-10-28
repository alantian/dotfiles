# macOS: Tailscale app CLI, only if the app exists and tailscale isn't already on PATH
if [ -x "/Applications/Tailscale.app/Contents/MacOS/Tailscale" ] \
  && ! command -v tailscale >/dev/null 2>&1; then
  alias tailscale="/Applications/Tailscale.app/Contents/MacOS/Tailscale"
fi

# macOS: Google Cloud SDK from Homebrew (Apple Silicon or Intel prefix)
_hb="${HOMEBREW_PREFIX:-/opt/homebrew}"
if [[ -r "$_hb/share/google-cloud-sdk/path.zsh.inc" ]]; then
  source "$_hb/share/google-cloud-sdk/path.zsh.inc"
fi
if [[ -r "$_hb/share/google-cloud-sdk/completion.zsh.inc" ]]; then
  source "$_hb/share/google-cloud-sdk/completion.zsh.inc"
fi
unset _hb
