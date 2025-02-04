#!/bin/bash

echo "Install/upgrade oh-my-posh"

if [ `uname` = "Linux" ] || [] `uname` = "Darwin" ] ; then
  curl -s https://ohmyposh.dev/install.sh | bash -s -- -d ~/.local/bin -t ~/.poshthemes
else
  warning "WARNING: cannot determine the OS."
fi