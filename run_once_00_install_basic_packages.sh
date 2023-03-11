#!/bin/bash

# References:
#  - https://unix.stackexchange.com/questions/46081/identifying-the-system-package-manager
#  - https://jvns.ca/blog/2022/04/12/a-list-of-new-ish--command-line-tools/


RED='\033[0;31m'
NC='\033[0m' # No Color
bold=$(tput bold)
normal=$(tput sgr0)

if [ `uname` = "Linux" ]; then
  if [ -f /etc/arch-release ] ; then # Arch linux
    echo -e "${bold}Arch Linux detected${normal}"
    echo -e "${bold}Run \`pacman -Syu\`${normal}"
    sudo pacman -Syu --noconfirm
    echo -e "${bold}Install packages using pacman${normal}"
    sudo pacman -Syu --noconfirm --needed \
      zsh git unzip \
    ;
    echo -e "${bold}Change shell to zsh${normal}"
    sudo chsh -s /usr/bin/zsh $(whoami)
  fi
else
  echo -e "${RED}${bold}WARNING: cannot determine the OS.${normal}${NC}"
fi
