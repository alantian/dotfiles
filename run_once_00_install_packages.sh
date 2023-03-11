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
    echo -e "${bold}Install yay for AUR${normal} if it's not installed"
    if [ ! -f /usr/bin/yay ] ; then
      (sudo pacman -Syu --noconfirm --needed git base-devel &&\
      cd /tmp&&\
      git clone https://aur.archlinux.org/yay.git &&\
      cd yay && makepkg -si --noconfirm && cd /tmp && rm -rf yay ;)
    fi
    echo -e "${bold}Install packages using pacman${normal}"
    sudo pacman -Syu --noconfirm --needed \
      zsh git \
      `#replacements for standard tools` \
      grep ripgrep `# grep` \
      exa `# ls` \
      bat `# cat` \
      git-delta `# a pager for git` \
      fd `# find` \
      duf `# df` \
      dust `# du` \
      bottom btop glances gtop `# top` \
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
      xh `# make HTTP requests` \
      entr `# run arbitrary commands when files change` \
      tig lazygit `# interactive interfaces for git` \
      ctop `# top for containers` \
      thefuck `# autocorrect command line errors` \
    ;
    echo -e "${bold}Install packages using yay${normal}"
    yay -Syu --noconfirm --needed \
      zenith `# top` \
      nodejs-tldr `#man, sort of` \
      lazydocker `#interactive interface for docker` \
    ;
    echo -e "${bold}Change shell to zsh${normal}"
    sudo chsh -s /usr/bin/zsh $(whoami)
  fi
else
  echo -e "${RED}WARNING: cannot determine the OS.${NC}"
fi
