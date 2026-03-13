#!/usr/bin/env bash
set -euo pipefail

# Bootstrap script for alantian/dotfiles
# Usage: curl https://raw.githubusercontent.com/alantian/dotfiles/main/bootstrap.sh | bash

# ---------------------------------------------------------------------------
# Sudo helper
# ---------------------------------------------------------------------------
SUDO=""
SKIP_SYSTEM_PKGS=false
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
      brew install git curl wget
      ;;
    ubuntu)
      $SUDO apt-get update -y
      $SUDO apt-get install -y git curl wget zsh
      ;;
    arch)
      $SUDO pacman -S --needed --noconfirm git curl wget zsh
      ;;
  esac
}

# ---------------------------------------------------------------------------
# zsh as default shell
# ---------------------------------------------------------------------------
ensure_zsh_default() {
  step "Ensuring zsh is the default shell"

  local zsh_path
  zsh_path="$(command -v zsh 2>/dev/null || true)"

  if [ -z "$zsh_path" ]; then
    echo "WARNING: zsh not found on PATH, skipping chsh"
    return
  fi

  if [ "${SHELL:-}" = "$zsh_path" ]; then
    echo "zsh is already the default shell ($SHELL)"
    return
  fi

  echo "Setting default shell to $zsh_path"
  case "$OS_TYPE" in
    macos)
      # /bin/zsh is already in /etc/shells on macOS
      chsh -s "$zsh_path"
      ;;
    ubuntu|arch)
      # Use usermod to avoid interactive password prompt from chsh
      $SUDO usermod -s "$zsh_path" "$(id -un)"
      ;;
  esac
}

# ---------------------------------------------------------------------------
# proto
# ---------------------------------------------------------------------------
install_proto() {
  step "Installing/upgrading proto"

  if [ -x "$HOME/.proto/bin/proto" ]; then
    echo "proto already installed, upgrading..."
    "$HOME/.proto/bin/proto" upgrade || true
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
  step "Installing proto tools (uv)"

  local proto="$HOME/.proto/bin/proto"
  if [ ! -x "$proto" ]; then
    echo "ERROR: proto not found at $proto" >&2
    exit 1
  fi

  echo "  proto install uv"
  "$proto" install uv
}

# ---------------------------------------------------------------------------
# python (via uv)
# ---------------------------------------------------------------------------
install_python() {
  step "Installing Python via uv"

  local proto="$HOME/.proto/bin/proto"
  local uv
  uv="$("$proto" bin uv 2>/dev/null)" || true
  if [ -z "$uv" ] || [ ! -x "$uv" ]; then
    echo "ERROR: uv not found via proto bin uv" >&2
    exit 1
  fi

  echo "  uv python install"
  "$uv" python install
}

# ---------------------------------------------------------------------------
# oh-my-posh
# ---------------------------------------------------------------------------
install_oh_my_posh() {
  step "Installing/upgrading oh-my-posh"
  if [ -x "$HOME/.local/bin/oh-my-posh" ]; then
    echo "oh-my-posh already installed, upgrading..."
  else
    echo "Installing oh-my-posh..."
  fi
  curl -s https://ohmyposh.dev/install.sh | bash -s -- -d ~/.local/bin
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
  curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh -s -- --bin-dir "$HOME/.local/bin"
}

# ---------------------------------------------------------------------------
# thefuck
# ---------------------------------------------------------------------------
install_thefuck() {
  step "Installing/upgrading thefuck"

  local proto="$HOME/.proto/bin/proto"
  local uv
  uv="$("$proto" bin uv 2>/dev/null)" || true
  if [ -z "$uv" ] || [ ! -x "$uv" ]; then
    echo "ERROR: uv not found via proto bin uv" >&2
    exit 1
  fi

  "$uv" tool install thefuck --python 3.11
}

# ---------------------------------------------------------------------------
# chezmoi
# ---------------------------------------------------------------------------
install_chezmoi() {
  step "Installing/applying chezmoi dotfiles"

  if [ -d "$HOME/.local/share/chezmoi/.git" ]; then
    echo "chezmoi repo already present, applying..."
    "$HOME/.local/bin/chezmoi" apply
  else
    echo "Initialising chezmoi from alantian/dotfiles..."
    sh -c "$(curl -fsLS get.chezmoi.io/lb)" -- init --apply alantian
  fi
}

# ---------------------------------------------------------------------------
# main
# ---------------------------------------------------------------------------
main() {
  echo "========================================"
  echo " alantian/dotfiles bootstrap"
  echo "========================================"

  detect_os
  install_system_pkgs
  ensure_zsh_default
  install_proto
  install_proto_tools
  install_python
  install_oh_my_posh
  install_fzf
  install_zoxide
  install_thefuck
  install_chezmoi

  echo
  echo "========================================"
  echo " Bootstrap complete!"
  echo "========================================"
  echo
  echo "Verification:"
  echo "  zsh:      $(zsh --version 2>/dev/null || echo 'NOT FOUND')"
  echo "  git:      $(git --version 2>/dev/null || echo 'NOT FOUND')"
  echo "  proto:    $($HOME/.proto/bin/proto --version 2>/dev/null || echo 'NOT FOUND')"
  echo "  chezmoi:    $($HOME/.local/bin/chezmoi --version 2>/dev/null || echo 'NOT FOUND')"
  echo "  oh-my-posh: $($HOME/.local/bin/oh-my-posh --version 2>/dev/null || echo 'NOT FOUND')"
  echo "  fzf:        $($HOME/.fzf/bin/fzf --version 2>/dev/null || echo 'NOT FOUND')"
  echo "  zoxide:     $($HOME/.local/bin/zoxide --version 2>/dev/null || echo 'NOT FOUND')"
  echo "  thefuck:    $($HOME/.local/bin/thefuck --version 2>/dev/null || echo 'NOT FOUND')"
  echo
  echo "Restart your shell (or open a new terminal) to pick up the new configuration."
}

main "$@"
