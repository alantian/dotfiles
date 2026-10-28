# macOS: Tailscale app CLI, only if the app exists and tailscale isn't already on PATH
if [ -x "/Applications/Tailscale.app/Contents/MacOS/Tailscale" ] \
  && ! command -v tailscale >/dev/null 2>&1; then
  alias tailscale="/Applications/Tailscale.app/Contents/MacOS/Tailscale"
fi

# macOS: Google Cloud SDK from Homebrew
if [[ -r /opt/homebrew/share/google-cloud-sdk/path.zsh.inc ]]; then
  source /opt/homebrew/share/google-cloud-sdk/path.zsh.inc
fi
if [[ -r /opt/homebrew/share/google-cloud-sdk/completion.zsh.inc ]]; then
  source /opt/homebrew/share/google-cloud-sdk/completion.zsh.inc
fi
