#!/bin/bash

echo "Install/upgrade oh-my-posh"

OMP="$HOME/.local/bin/oh-my-posh"

if [ -f $OMP ] ; then
  $OMP upgrade
else
  curl -s https://ohmyposh.dev/install.sh | bash -s -- -d ~/.local/bin -t ~/.poshthemes
fi