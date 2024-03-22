#!/bin/bash

# References:
#  - https://unix.stackexchange.com/questions/46081/identifying-the-system-package-manager
#  - https://ohmyposh.dev/docs/installation/linux

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
  if [ ! -f ~/.local/bin/oh-my-posh ]; then
    mkdir -p ~/.local/bin
    wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64 -O ~/.local/bin/oh-my-posh
    chmod +x ~/.local/bin/oh-my-posh

    rm -rf ~/.poshthemes
    mkdir -p ~/.poshthemes
    wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/themes.zip -O ~/.poshthemes/themes.zip
    unzip ~/.poshthemes/themes.zip -d ~/.poshthemes
    chmod u+rw ~/.poshthemes/*.omp.*
    rm ~/.poshthemes/themes.zip
  fi
elif [ `uname` = "Darwin" ]; then # macOS
  warning "WARNING: Mac OS detectd, but not supported."
else
  warning "WARNING: cannot determine the OS."
fi


