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
      zsh git unzip \
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
  fi
else
  warning "WARNING: cannot determine the OS."
fi
