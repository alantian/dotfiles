#!/bin/bash

# References:
#  - https://unix.stackexchange.com/questions/46081/identifying-the-system-package-manager
#  - https://jvns.ca/blog/2022/04/12/a-list-of-new-ish--command-line-tools/


RED='\033[0;31m'
NC='\033[0m' # No Color
bold=$(tput bold)
normal=$(tput sgr0)

function info() {
    echo -e "${bold}$*${normal}"
}

function warning() {
    echo -e "${RED}${bold}$*${normal}${NC}" 
}

if [ `uname` = "Linux" ]; then
  if [ -f /etc/arch-release ] ; then # Arch linux
    info "Arch Linux detected"
    info "Install yay for AUR if it's not installed"
    if [ ! -f /usr/bin/yay ] ; then
      (
        sudo pacman -Syu --noconfirm --needed git base-devel &&\
        cd /tmp&&\
        git clone https://aur.archlinux.org/yay.git &&\
        cd yay && makepkg -si --noconfirm && cd /tmp && rm -rf yay ;
      )
    fi
    info "Install packages using yay"
    yay -Syu --noconfirm --needed \
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
    info "Run \`apt-get update\`"
    sudo apt-get update
    info "Install packages"
    # many packages avaiable for Arch are missing here (especially for debian)..
    sudo apt-get install -y \
      build-essential \
      ripgrep \
      bat \
      fd-find \
      fzf \
      entr \
      tig \
      thefuck \
    ;
    sudo apt-get install ctop || warning "ctop failed to install"
    sudo apt-get install exa || warning "exa failed to install"
    sudo apt-get install duf || warning "duf failed to install"

    # some manual install
    ( 
      # btop
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
    )
    # some fixes
    mkdir -p ~/.local/bin
    ln -s /usr/bin/batcat ~/.local/bin/bat

    info "Change shell to zsh"
    sudo chsh -s /usr/bin/zsh $(whoami)
    info "Done"
  fi
elif [ `uname` = "Darwin" ]; then # macOS
  info "Mac OS detected"

  info "Install packages using homebrew"
  brew install \
      grep ripgrep `# grep` \
      exa `# ls` \
      bat `# cat` \
      git-delta `# a pager for git` \
      fd `# find` \
      duf `# df` \
      dust `# du` \
      bottom `#btop #(need gcc...)` glances gtop zenith `# top` \
      sd `# sed` \
      difftastic `# df` \
      `#plocate #no equivalent`  `# locate` \
      hexyl `# hexdump` \
      `# new inventions` \
      zoxide `# tools to make it easier to find files / change directories`\
      broot `# file manager` \
      direnv `# load environment variables depending on the current directory` \
      fzf `# fuzzy finder` \
      croc `# send files from one computer to another` \
      hyperfine `#benchmarking` \
      tldr `#man, sort of` \
      xh `# make HTTP requests` \
      entr `# run arbitrary commands when files change` \
      tig lazygit `# interactive interfaces for git` \
      lazydocker `#interactive interface for docker` \
      ctop `# top for containers` \
      thefuck `# autocorrect command line errors` \
  ;
else
  warning "cannot determine the OS. Skip."
fi
