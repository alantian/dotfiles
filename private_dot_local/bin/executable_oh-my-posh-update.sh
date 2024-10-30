#!/bin/bash

if [ `uname` = "Linux" -o `uname` = "Darwin"]; then
  curl -s https://ohmyposh.dev/install.sh | bash -s -- -d ~/.local/bin -t ~/.poshthemes
else
  warning "WARNING: cannot determine the OS."
fi