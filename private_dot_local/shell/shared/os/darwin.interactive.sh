# macOS: Tailscale app CLI, only if the app exists and tailscale isn't already on PATH
if [ -x "/Applications/Tailscale.app/Contents/MacOS/Tailscale" ] \
  && ! command -v tailscale >/dev/null 2>&1; then
  alias tailscale="/Applications/Tailscale.app/Contents/MacOS/Tailscale"
fi
