#!/usr/bin/env bash

# References:
#  - https://unix.stackexchange.com/questions/46081/identifying-the-system-package-manager
#  - https://jvns.ca/blog/2022/04/12/a-list-of-new-ish--command-line-tools/
#  - https://ohmyposh.dev/install.sh

error() {
    printf "\e[31m$1\e[0m\n"
    exit 1
}

info() {
    printf "$1\n"
}

warn() {
    printf "⚠️  \e[33m$1\e[0m\n"
}

validate_dependency() {
    if ! command -v $1 >/dev/null; then
        error "$1 is required. Please install $1 and try again.\n"
    fi
}

function brew_install() {
    validate_dependency brew
    brew install -q "$@"
}

function apt_install() {
    validate_dependency apt-get
    sudo apt-get update
    sudo apt-get install -y "$@"
}

function yay_install() {
    if [ ! -f /usr/bin/yay ] ; then
      (
        sudo pacman -Syu --noconfirm --needed git base-devel &&\
        cd /tmp&&\
        git clone https://aur.archlinux.org/yay.git &&\
        cd yay && makepkg -si --noconfirm && cd /tmp && rm -rf yay ;
      )
    fi
    validate_dependency yay
    yay -Syu --noconfirm "$@"
}

function linux_install_btop_x64() {
    if [ ! -f /usr/local/bin/btop ]; then
        cd /tmp ;
        rm -rf btop-x86_64-linux-musl
        wget https://github.com/aristocratos/btop/releases/download/v1.2.13/btop-x86_64-linux-musl.tbz \
            -O btop-x86_64-linux-musl.tbz
        tar xvf btop-x86_64-linux-musl.tbz
        cd btop
        sudo make install
        sudo make setuid
        cd /tmp
        rm -rf btop-x86_64-linux-musl
    fi
}

if [ `uname` = "Linux" ]; then
  if [ -f /etc/arch-release ] ; then # Arch linux
    info "Arch Linux detected"
    yay_install zsh git unzip wget curl tar bzip2
    sudo chsh -s /usr/bin/zsh $(whoami)
    yay_install \
      base-devel \
      `#replacements for standard tools` \
      grep ripgrep `# grep` \
      exa `# ls` \
      bat `# cat` \
      git-delta `# a pager for git` \
      fd `# find` \
      duf `# df` \
      dust `# du` \
      bottom btop glances gtop zenith `# top` \
      sd `# sed` \
      difftastic `# df` \
      plocate `# locate` \
      hexyl `# hexdump` \
      `# new inventions` \
      zoxide `# tools to make it easier to find files / change directories`\
      broot `# file manager` \
      direnv `# load environment variables depending on the current directory` \
      fzf `# fuzzy finder` \
      croc `# send files from one computer to another` \
      hyperfine `#benchmarking` \
      nodejs-tldr `#man, sort of` \
      xh `# make HTTP requests` \
      entr `# run arbitrary commands when files change` \
      tig lazygit `# interactive interfaces for git` \
      lazydocker `#interactive interface for docker` \
      ctop `# top for containers` \
      thefuck `# autocorrect command line errors` \
    ;
  elif [ -f /etc/debian_version ] ; then # Debian/Ubuntu
    info "Debian-baed Linux detected"
    apt_install zsh git unzip wget curl bzip2
    sudo chsh -s /usr/bin/zsh $(whoami)
    # many packages avaiable for Arch are missing here (especially for debian)..
    apt_install \
      build-essential \
      ripgrep \
      bat \
      fd-find \
      fzf \
      entr \
      tig \
      thefuck \
    ;

    # fix blow.
    sudo apt-get install ctop || warn "ctop failed to install"
    sudo apt-get install exa || warn "exa failed to install"
    sudo apt-get install duf || warn "duf failed to install"

    linux_install_btop_x64
    
    # some fixes
    mkdir -p ~/.local/bin
    ln -s /usr/bin/batcat ~/.local/bin/bat
  fi
elif [ `uname` = "Darwin" ]; then # macOS
  info "macOS detected"
  brew_install zsh git unzip wget curl bzip2
  # no need to change shell to zsh as it's already default.
else
  error "WARNING: cannot determine the OS."
fi