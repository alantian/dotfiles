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


function main() {
  ask_system_wide

  if [ $(uname) = "Linux" ]; then
    if [ -f /etc/arch-release ]; then # Arch linux
      info "Arch Linux detected"

      # Minimal required packages for dotfiles.
      yay_packages=(
        base-devel
        zsh git unzip wget curl rsync tar bzip2
        zsh-completions # for zsh-users/zsh-completions
        #replacements for standard tools
      )
      yay_install "${yay_packages[@]}"

      linux_change_shell_to_zsh

      # replacements for standard tools
      yay_packages=(      
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
				ttf-meslo-nerd `# some nerd fonts`
      )
      yay_install "${yay_packages[@]}"
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
      linux_change_shell_to_zsh

      apt_packages=(
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
    fi
  elif [ $(uname) = "Darwin" ]; then # macOS
    info "macOS detected. do nothing"
  else
    error "WARNING: cannot determine the OS."
  fi
}

main
