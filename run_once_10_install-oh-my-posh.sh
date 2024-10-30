#!/bin/bash

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

if [ `uname` = "Linux" -o `uname` = "Darwin" ]; then
  curl -s https://ohmyposh.dev/install.sh | bash -s -- -d ~/.local/bin -t ~/.poshthemes
else
  warn "WARNING: cannot determine the OS."
fi