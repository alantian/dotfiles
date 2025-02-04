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

function brew_install() {
  info "brew install"
  validate_dependency brew
  brew install -q "$@"
}

function vim_install_plugins() {
  echo "vim install plugins"
  vim +PluginInstall +qall
  info " > Done"
}

function main() {
  if [ $(uname) = "Linux" ] || [ $(uname) = "Darwin" ] ; then
    info "Linux/MacOS detected"
    vim_install_plugins
    ~/.local/bin/oh-my-posh-update.sh
    ~/.local/bin/proto-update.sh
  else
    error "WARNING: cannot determine the OS."
  fi
}

main
