#!/bin/bash

# ref
#  - https://unix.stackexchange.com/questions/46081/identifying-the-system-package-manager

RED='\033[0;31m'
NC='\033[0m' # No Color
bold=$(tput bold)
normal=$(tput sgr0)

if [ `uname` = "Linux" ]; then
  if [ -f /etc/arch-release ] ; then
    echo -e "${bold}Arch Linux detected${normal}"
    echo -e "${bold}Install packages${normal}"
    sudo pacman -S --noconfirm --needed \
     vim zsh git 
    echo -e "${bold}Change shell to zsh${normal}"
    sudo chsh -s /usr/bin/zsh $(whoami)
  fi
else
  echo -e "${RED}WARNING: cannot determine the OS.${NC}"
fi
