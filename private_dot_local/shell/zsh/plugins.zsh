ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d "$ZINIT_HOME" ] && mkdir -p "$(dirname "$ZINIT_HOME")"

# Intentional fallback: bootstrap installs zinit, but interactive zsh keeps a
# self-healing path if a machine is only partially bootstrapped.
if [ ! -d "$ZINIT_HOME/.git" ]; then
  if ! git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"; then
    echo "WARNING: failed to clone zinit; continuing without zinit plugins" >&2
  fi
fi

if [ ! -r "${ZINIT_HOME}/zinit.zsh" ]; then
  echo "WARNING: zinit is unavailable; continuing without zinit plugins" >&2
else
  source "${ZINIT_HOME}/zinit.zsh"

  zinit load zdharma-continuum/history-search-multi-word
  zinit light zsh-users/zsh-autosuggestions
  zinit light zsh-users/zsh-history-substring-search

  zinit ice blockf
  zinit light zsh-users/zsh-completions

  zinit light egorlem/ultima.zsh-theme

  zinit light zsh-users/zsh-syntax-highlighting # load late
fi
