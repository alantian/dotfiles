#!/usr/bin/env bash

# References:
#  - https://unix.stackexchange.com/questions/46081/identifying-the-system-package-manager
#  - https://jvns.ca/blog/2022/04/12/a-list-of-new-ish--command-line-tools/
#  - https://ohmyposh.dev/install.sh

function error() {
  printf "\e[31m$1\e[0m\n"
  exit 1
}

function info() {
  printf "$1\n"
}

function warn() {
  printf "⚠️  \e[33m$1\e[0m\n"
}

validate_dependency() {
  if ! command -v $1 >/dev/null; then
    error "$1 is required. Please install $1 and try again.\n"
  fi
}

global_var_system_wide="false"

function ask_system_wide() {
  # ref: https://stackoverflow.com/questions/226703/how-do-i-prompt-for-yes-no-cancel-input-in-a-linux-shell-script
  echo "Do you want to make system wide modification (requiring sudo)?"
  select yn in "Yes" "No"; do
    case $yn in
    "Yes")
      global_var_system_wide="true"
      break
      ;;
    "No")
      global_var_system_wide="false"
      break
      ;;
    esac
  done
}

function do_system_wide() {
  [ "${global_var_system_wide}" = "true" ]
  return
}

function brew_install() {
  validate_dependency brew
  brew install -q "$@"
}

function apt_install() {
  info "apt install"
  do_system_wide || {
    info " > Skip to NOT make system wide modificaiton"
    return
  }
  validate_dependency apt-get
  sudo apt-get update -qq
  sudo apt-get install -qq -y "$@"
  info " > Done"
}

function yay_install() {
  info "yay install"
  do_system_wide || {
    info " > Skip to NOT make system wide modificaiton"
    return
  }

  if [ ! -f /usr/bin/yay ]; then
    (
      sudo pacman -Syu --noconfirm --needed -q git base-devel &&
        cd /tmp &&
        git clone https://aur.archlinux.org/yay.git &&
        cd yay && makepkg -si --noconfirm && cd /tmp && rm -rf yay
    )
  fi
  validate_dependency yay
  yay -Syu --noconfirm --needed -q "$@" &>/dev/null
  info " > Done"
}

function linux_change_shell_to_zsh() {
  info "change shell to zsh"
  do_system_wide || {
    info " > Skip to NOT make system wide modificaiton"
    return
  }
  sudo chsh -s /usr/bin/zsh $(whoami) &>/dev/null
  info " > Done"
}

function btop_install_linux_x64() {
  if [ ! -f /usr/local/bin/btop ]; then
    (
      cd /tmp
      rm -rf btop-x86_64-linux-musl
      wget https://github.com/aristocratos/btop/releases/download/v1.2.13/btop-x86_64-linux-musl.tbz \
        -O btop-x86_64-linux-musl.tbz
      tar xvf btop-x86_64-linux-musl.tbz
      cd btop
      sudo make install
      sudo make setuid
      cd /tmp
      rm -rf btop-x86_64-linux-musl
    ) &>/dev/null
  fi
}

function ffmpeg_install_linux_x64_local_static() {

  info "ffmpeg: install locally."

  URL=https://www.johnvansickle.com/ffmpeg/releases/ffmpeg-7.0.2-amd64-static.tar.xz
  ARCHIVE="ffmpeg-7.0.2-amd64-static.tar.xz"
  OPT_DIR="$HOME/opt"
  STATIC_DIR="$OPT_DIR/static"
  EXTRACTED_DIR="$STATIC_DIR/ffmpeg-7.0.2-amd64-static"

  SIMLINK_NAME="ffmpeg"
  SIMLINK_TARGET="./static/ffmpeg-7.0.2-amd64-static"

  if [ ! -d "${EXTRACTED_DIR}" ]; then
    (
      mkdir -p "${STATIC_DIR}"
      cd "${STATIC_DIR}"
      wget "${URL}" -O "${ARCHIVE}"
      tar xvf "${ARCHIVE}"
      rm -rf "${ARCHIVE}"
    )
  fi
  (
    cd "$OPT_DIR"
    rm -rf "${SIMLINK_NAME}"
    ln -s "${SIMLINK_TARGET}" "${SIMLINK_NAME}"
  )

  info " > Done"
  info " > Add ${OPT_DIR}/${SIMLINK_NAME} to \$PATH if you need to use"
}

function vim_install_plugins() {
  echo "vim install plugins"
  vim +PluginInstall +qall
  info " > Done"
}

function main() {
  ask_system_wide

  if [ $(uname) = "Linux" ]; then
    if [ -f /etc/arch-release ]; then # Arch linux
      info "Arch Linux detected"

      yay_packages=(
        # standard tools
        base-devel
        zsh git unzip wget curl tar bzip2
        zsh-completions # for zsh-users/zsh-completions
        #replacements for standard tools

        grep ripgrep `# grep`
        exa `# ls`
        bat `# cat`
        git-delta `# a pager for git`
        fd `# find`
        duf `# df`
        dust `# du`
        bottom btop glances gtop zenith `# top`
        sd `# sed`
        difftastic `# df`
        plocate `# locate`
        hexyl `# hexdump`
        `# new inventions`
        zoxide `# tools to make it easier to find files / change directories`
        broot `# file manager`
        direnv `# load environment variables depending on the current directory`
        fzf `# fuzzy finder`
        croc `# send files from one computer to another`
        hyperfine `#benchmarking`
        nodejs-tldr `#man, sort of`
        xh `# make HTTP requests`
        entr `# run arbitrary commands when files change`
        tig lazygit `# interactive interfaces for git`
        lazydocker `#interactive interface for docker`
        thefuck `# autocorrect command line errors`
        ctop `# top for containers`
      )
      yay_install "${yay_packages[@]}"

      linux_change_shell_to_zsh
      ffmpeg_install_linux_x64_local_static
      vim_install_plugins
    elif [ -f /etc/debian_version ]; then # Debian/Ubuntu
      info "Debian-based Linux detected"

      apt_packages=(
        zsh git unzip wget curl bzip2
        vim byobu
        build-essential
        `#replacements for standard tools`
        ripgrep
        bat
        fd-find
        fzf
        entr
        tig
        duf
      )
      apt_install "${apt_packages[@]}"
      btop_install_linux_x64

      linux_change_shell_to_zsh
      ffmpeg_install_linux_x64_local_static
      vim_install_plugins
    fi
  elif [ $(uname) = "Darwin" ]; then # macOS
    info "macOS detected"
    brew_install zsh git unzip wget curl bzip2
    # no need to change shell to zsh as it's already default.
    vim_install_plugins
  else
    error "WARNING: cannot determine the OS."
  fi
}

main
