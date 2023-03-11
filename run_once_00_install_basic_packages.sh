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
    info "Run \`pacman -Syu\`"
    sudo pacman -Syu --noconfirm
    info "Install packages using pacman"
    sudo pacman -Syu --noconfirm --needed \
      zsh git unzip \
    ;
    info "Change shell to zsh"
    sudo chsh -s /usr/bin/zsh $(whoami)
    info "Done"
  fi
else
  warning "WARNING: cannot determine the OS."
fi
