#!/usr/bin/env bash
set -euo pipefail

# Bootstrap script for alantian/dotfiles
# Usage (fresh host or rerun; idempotent):
#   bash <(curl -fsSL https://raw.githubusercontent.com/alantian/dotfiles/main/bootstrap.sh)
# Not `curl ... | bash`: with the script on stdin, any step that reads stdin
# (interactive zsh, brew) would swallow the rest of the script.
# Prerequisites: curl, sudo (or root) for system packages; an SSH key for GitHub
# if the dotfiles clone should be pushable (otherwise HTTPS, read-only).
# Scope: only what the dotfiles themselves need (zsh, prompt, fzf, zoxide,
# zinit, chezmoi) plus the proto toolchain. zsh is the only supported shell;
# bootstrap aborts if zsh cannot be made the login shell. Applications (npm globals such as
# gemini-cli/codex, uv tools, editors) are installed by hand afterwards.

# ---------------------------------------------------------------------------
# Sudo helper
# ---------------------------------------------------------------------------
SUDO=""
SKIP_SYSTEM_PKGS=false
PROTO_HOME="${PROTO_HOME:-$HOME/.proto}"
export PROTO_HOME
if [ "$(id -u)" -ne 0 ]; then
  if command -v sudo >/dev/null 2>&1; then
    SUDO="sudo"
  else
    echo "WARNING: not root and sudo not available — skipping system package installs"
    SKIP_SYSTEM_PKGS=true
  fi
fi

# ---------------------------------------------------------------------------
# Logging
# ---------------------------------------------------------------------------
step() { echo; echo "==> $*"; }

# ---------------------------------------------------------------------------
# OS detection
# ---------------------------------------------------------------------------
OS_TYPE=""
detect_os() {
  step "Detecting OS"
  local os arch
  os="$(uname -s)"
  arch="$(uname -m)"
  case "$os" in
    Darwin)
      OS_TYPE="macos"
      ;;
    Linux)
      if [ -f /etc/os-release ]; then
        # shellcheck source=/dev/null
        . /etc/os-release
        case "${ID:-}" in
          ubuntu|debian)
            OS_TYPE="ubuntu"
            ;;
          arch|manjaro)
            OS_TYPE="arch"
            ;;
          *)
            echo "ERROR: Unsupported Linux distro: ${ID:-unknown}" >&2
            exit 1
            ;;
        esac
      else
        echo "ERROR: Cannot determine Linux distro (no /etc/os-release)" >&2
        exit 1
      fi
      ;;
    *)
      echo "ERROR: Unsupported OS: $os ($arch)" >&2
      exit 1
      ;;
  esac
  echo "Detected OS: $OS_TYPE (arch: $arch)"
}

# ---------------------------------------------------------------------------
# System packages
# ---------------------------------------------------------------------------
install_system_pkgs() {
  step "Installing system packages"

  if [ "$SKIP_SYSTEM_PKGS" = true ]; then
    echo "Skipping system package installs (no sudo/root)"
    return
  fi

  case "$OS_TYPE" in
    macos)
      if ! command -v brew >/dev/null 2>&1; then
        echo "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        # Add brew to PATH for the rest of this script (installer doesn't modify current session)
        if [ -x /opt/homebrew/bin/brew ]; then
          eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [ -x /usr/local/bin/brew ]; then
          eval "$(/usr/local/bin/brew shellenv)"
        fi
      else
        echo "Homebrew already installed"
      fi
      brew install git curl wget tmux </dev/null
      ;;
    ubuntu)
      $SUDO apt-get update -y
      $SUDO apt-get install -y git curl wget zsh ca-certificates xz-utils unzip vim tmux
      ;;
    arch)
      # Full sync+upgrade first: a fresh image has a stale db and -S alone 404s.
      $SUDO pacman -Syu --needed --noconfirm git curl wget zsh unzip vim tmux
      ;;
  esac
}

# ---------------------------------------------------------------------------
# zsh as default shell (REQUIRED: these dotfiles support zsh only)
# ---------------------------------------------------------------------------
login_shell() {  # prints the current login shell of this user, or nothing
  case "$OS_TYPE" in
    macos) dscl . -read "/Users/$(id -un)" UserShell 2>/dev/null | awk '{print $2}' ;;
    *)     getent passwd "$(id -un)" 2>/dev/null | cut -d: -f7 ;;
  esac
}

ensure_zsh_default() {
  step "Ensuring zsh is the login shell (required)"

  local zsh_path current_shell
  zsh_path="$(command -v zsh 2>/dev/null || true)"

  if [ -z "$zsh_path" ]; then
    echo "ERROR: zsh is not installed and could not be installed. These dotfiles support zsh only." >&2
    echo "       Install zsh (e.g. apt/pacman/brew install zsh) and rerun." >&2
    exit 1
  fi

  current_shell="$(login_shell)"
  [ -n "$current_shell" ] || current_shell="${SHELL:-}"

  if [ "${current_shell##*/}" = "zsh" ]; then
    echo "zsh is already the login shell ($current_shell)"
    return
  fi

  echo "Login shell is '${current_shell:-unknown}'; setting it to $zsh_path"
  case "$OS_TYPE" in
    macos)
      # /bin/zsh is already in /etc/shells on macOS
      chsh -s "$zsh_path" </dev/null || true
      ;;
    ubuntu|arch)
      if [ "$SKIP_SYSTEM_PKGS" = true ]; then
        # No sudo: chsh needs the user's password; it cannot be done unattended.
        echo "ERROR: cannot change the login shell without sudo." >&2
        echo "       Run: chsh -s $zsh_path   (enter your password), then rerun bootstrap." >&2
        exit 1
      fi
      # usermod avoids chsh's interactive password prompt
      $SUDO usermod -s "$zsh_path" "$(id -un)" || true
      ;;
  esac

  # Verify, do not assume. The dotfiles only make sense under zsh.
  current_shell="$(login_shell)"
  if [ "${current_shell##*/}" != "zsh" ]; then
    echo "ERROR: login shell is still '${current_shell:-unknown}', not zsh. Aborting." >&2
    echo "       Set it by hand (chsh -s $zsh_path) and rerun bootstrap." >&2
    exit 1
  fi
  echo "Login shell is now $current_shell"
}

# ---------------------------------------------------------------------------
# proto
# ---------------------------------------------------------------------------
install_proto() {
  step "Installing/upgrading proto"

  if [ -x "$PROTO_HOME/bin/proto" ]; then
    # proto itself is pinned in ~/.proto/.prototools (`proto = "x.y.z"`); only
    # move when the installed version differs from the pin. Never float.
    local pin have
    pin="$(sed -n 's/^proto = "\(.*\)"/\1/p' "$PROTO_HOME/.prototools" 2>/dev/null || true)"
    have="$("$PROTO_HOME/bin/proto" --version 2>/dev/null | awk '{print $2}')"
    if [ -n "$pin" ] && [ "$pin" = "$have" ]; then
      echo "proto $have already installed and matches the pin"
    elif [ -n "$pin" ]; then
      echo "proto $have installed, pin is $pin; upgrading to the pin..."
      "$PROTO_HOME/bin/proto" upgrade "$pin" || true
    else
      echo "proto $have installed, no pin found; leaving as is"
    fi
  else
    echo "Installing proto..."
    local proto_installer
    proto_installer="$(mktemp)"
    curl -fsSL https://moonrepo.dev/install/proto.sh -o "$proto_installer"
    bash "$proto_installer" --no-profile --yes
    rm -f "$proto_installer"
  fi
}

# ---------------------------------------------------------------------------
# proto tools
# ---------------------------------------------------------------------------
install_proto_tools() {
  step "Installing proto tools pinned in ~/.proto/.prototools"

  local proto="$PROTO_HOME/bin/proto"
  if [ ! -x "$proto" ]; then
    echo "ERROR: proto not found at $proto" >&2
    exit 1
  fi
  if [ ! -f "$PROTO_HOME/.prototools" ]; then
    echo "ERROR: $PROTO_HOME/.prototools missing; it is managed by chezmoi and should have been applied" >&2
    exit 1
  fi

  # Versions are pinned explicitly in the chezmoi-managed .prototools (node,
  # npm, pnpm, uv, python). Nothing floats; rerunning bootstrap is reproducible.
  echo "  proto install --config-mode global   # all tools from $PROTO_HOME/.prototools"
  "$proto" install --config-mode global -y

  # Extra, unpinned versions kept installed alongside the pins (Tian updates
  # this list by hand, like the pins). The global `python` stays the pinned 3.13;
  # a project can select 3.14 with its own .prototools or `uv run --python 3.14`.
  local spec
  for spec in "${PROTO_EXTRA_VERSIONS[@]}"; do
    echo "  proto install ${spec%@*} ${spec#*@}"
    "$proto" install "${spec%@*}" "${spec#*@}" -y
  done
}
PROTO_EXTRA_VERSIONS=(python@3.14.8)

# ---------------------------------------------------------------------------
# proto shims
# ---------------------------------------------------------------------------
regen_proto_shims() {
  step "Regenerating proto shims"

  local proto="$PROTO_HOME/bin/proto"
  if [ ! -x "$proto" ]; then
    echo "ERROR: proto not found at $proto" >&2
    exit 1
  fi

  "$proto" regen
}

# ---------------------------------------------------------------------------
# oh-my-posh
# ---------------------------------------------------------------------------
install_oh_my_posh() {
  step "Installing/upgrading oh-my-posh"
  if [ -x "$HOME/.local/bin/oh-my-posh" ]; then
    echo "oh-my-posh already installed, upgrading..."
    "$HOME/.local/bin/oh-my-posh" upgrade
  else
    echo "Installing oh-my-posh..."
    curl -s https://ohmyposh.dev/install.sh | bash -s -- -d ~/.local/bin
  fi
}

# ---------------------------------------------------------------------------
# fzf
# ---------------------------------------------------------------------------
install_fzf() {
  step "Installing/upgrading fzf"
  if [ -d "$HOME/.fzf/.git" ]; then
    echo "fzf already installed, upgrading..."
    git -C "$HOME/.fzf" pull --ff-only
  else
    echo "Installing fzf..."
    git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
  fi
  "$HOME/.fzf/install" --bin --no-bash --no-zsh --no-fish
}

# ---------------------------------------------------------------------------
# zoxide
# ---------------------------------------------------------------------------
install_zoxide() {
  step "Installing/upgrading zoxide"
  if command -v zoxide >/dev/null 2>&1; then
    echo "zoxide already installed ($(zoxide --version 2>/dev/null || echo 'version unknown'))"
    return
  fi
  curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh -s -- --bin-dir "$HOME/.local/bin"
}

# ---------------------------------------------------------------------------
# zinit
# ---------------------------------------------------------------------------
install_zinit() {
  step "Installing zinit and zsh plugins"
  ZINIT_HOME="${HOME}/.local/share/zinit/zinit.git"
  if [ ! -d "$ZINIT_HOME/.git" ]; then
    echo "Cloning zinit..."
    mkdir -p "$(dirname "$ZINIT_HOME")"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
  else
    echo "zinit already present"
  fi
  echo "Running zsh interactively to install plugins..."
  # Intentional best-effort step: bootstrap keeps going if plugin hydration
  # fails, but we warn so the non-zero exit is not silent.
  if ! zsh -i -c "exit" </dev/null; then
    echo "WARNING: zinit/plugin bootstrap reported a non-zero exit status; continuing" >&2
  fi
}

# ---------------------------------------------------------------------------
# chezmoi
# ---------------------------------------------------------------------------
install_chezmoi() {
  step "Installing/applying chezmoi dotfiles"
  local chezmoi="$HOME/.local/bin/chezmoi"

  if [ ! -x "$chezmoi" ]; then
    echo "Installing chezmoi..."
    sh -c "$(curl -fsLS get.chezmoi.io/lb)" -- -b "$HOME/.local/bin"
  fi

  if [ -d "$HOME/.local/share/chezmoi/.git" ]; then
    echo "chezmoi repo already present: pulling what other hosts pushed, then applying..."
    "$chezmoi" update
  else
    # Prefer the SSH remote so later `chezmoi git -- push` works; fall back to
    # HTTPS (public repo, read-only) when no GitHub key is available yet.
    local repo="https://github.com/alantian/dotfiles.git"
    if ssh -T -o BatchMode=yes -o ConnectTimeout=10 -o StrictHostKeyChecking=accept-new git@github.com 2>&1 | grep -q "successfully authenticated"; then
      repo="git@github.com:alantian/dotfiles.git"
    else
      echo "WARNING: no GitHub SSH access; cloning over HTTPS. Pushes will not work until you run:"
      echo "         chezmoi git -- remote set-url origin git@github.com:alantian/dotfiles.git"
    fi
    echo "Initialising chezmoi from $repo..."
    "$chezmoi" init --apply "$repo"
  fi
}

# ---------------------------------------------------------------------------
# Host-local files that live outside the dotfiles: ~/.env.local (secrets) and
# ~/.zshrc.local (host-only zsh). Created empty-with-a-header only when absent;
# an existing file is never touched, so rerunning on a configured host is safe.
# ---------------------------------------------------------------------------
ensure_local_files() {
  step "Ensuring ~/.env.local and ~/.zshrc.local exist (never overwritten)"

  if [ -e "$HOME/.env.local" ]; then
    echo "$HOME/.env.local present, left as is"
  else
    umask 077
    cat > "$HOME/.env.local" <<'EOT'
# Host-local secrets and overrides, KEY=value, one per line. Sourced with
# `set -a` by ~/.local/shell/env.zsh in every shell. Never committed
# (it is in chezmoi's ignore list). Add API keys etc. here.
EOT
    umask 022
    echo "created empty ~/.env.local (mode 600); add your API keys there"
  fi

  if [ -e "$HOME/.zshrc.local" ]; then
    echo "$HOME/.zshrc.local present, left as is"
  else
    cat > "$HOME/.zshrc.local" <<'EOT'
# Host-local zsh config, outside chezmoi (it is in the ignore list). Loaded
# last by ~/.local/shell/rc.zsh, after the os/host layers. The
# guard below makes any other loader (e.g. Arch's grml /etc/zsh/zshrc, which
# sources this file early) a no-op. Keep the file idempotent.
[[ -n ${_ZSHRC_LOCAL_FROM_DOTFILES-} ]] || return
[[ -n ${_ZSHRC_LOCAL_LOADED-} ]] && return
_ZSHRC_LOCAL_LOADED=1

EOT
    echo "created ~/.zshrc.local with the loader guard; add host-only zsh config below it"
  fi
}

# ---------------------------------------------------------------------------
# main
# ---------------------------------------------------------------------------
main() {
  echo "========================================"
  echo " alantian/dotfiles bootstrap"
  echo "========================================"

  # Core machine prerequisites.
  detect_os
  install_system_pkgs
  ensure_zsh_default

  # Managed dotfiles first: they carry ~/.proto/.prototools (tool pins) and
  # ~/.npmrc (npm prefix) that the toolchain steps below depend on.
  install_chezmoi

  # Language/runtime toolchain, pinned by ~/.proto/.prototools.
  install_proto
  install_proto_tools
  regen_proto_shims
  ensure_local_files

  # Interactive shell and terminal tooling.
  install_oh_my_posh
  install_fzf
  install_zoxide
  install_zinit

  echo
  echo "========================================"
  echo " Bootstrap complete!"
  echo "========================================"
  echo
  echo "Verification:"
  echo "  login shell: $(login_shell)"
  echo "  zsh:      $(zsh --version 2>/dev/null || echo 'NOT FOUND')"
  echo "  git:      $(git --version 2>/dev/null || echo 'NOT FOUND')"
  echo "  proto:    $("${PROTO_HOME}/bin/proto" --version 2>/dev/null || echo 'NOT FOUND')"
  echo "  chezmoi:    $("${HOME}/.local/bin/chezmoi" --version 2>/dev/null || echo 'NOT FOUND')"
  echo "  oh-my-posh: $("${HOME}/.local/bin/oh-my-posh" --version 2>/dev/null || echo 'NOT FOUND')"
  echo "  fzf:        $("${HOME}/.fzf/bin/fzf" --version 2>/dev/null || echo 'NOT FOUND')"
  echo "  zoxide:     $("${HOME}/.local/bin/zoxide" --version 2>/dev/null || echo 'NOT FOUND')"
  echo "  node:       $("${PROTO_HOME}/shims/node" --version 2>/dev/null || echo 'NOT FOUND')"
  echo "  npm:        $("${PROTO_HOME}/shims/npm" --version 2>/dev/null || echo 'NOT FOUND')"
  echo "  pnpm:       $("${PROTO_HOME}/shims/pnpm" --version 2>/dev/null || echo 'NOT FOUND')"
  echo "  uv:         $("${PROTO_HOME}/shims/uv" --version 2>/dev/null || echo 'NOT FOUND')"
  echo "  python:     $("${PROTO_HOME}/shims/python" --version 2>/dev/null || echo 'NOT FOUND')"
  echo
  echo "Open a new terminal (or run: exec zsh) to pick up the new configuration."
  echo "Then put your secrets in ~/.env.local and host-only zsh config in ~/.zshrc.local."
}

main "$@"
