#!/bin/bash

# References:
#  - https://unix.stackexchange.com/questions/46081/identifying-the-system-package-manager
#  - https://ohmyposh.dev/docs/installation/linux

if [ `uname` = "Darwin" ]; then
  	brew install jandedobbeleer/oh-my-posh/oh-my-posh
  	ln -s $(brew --prefix oh-my-posh)/themes ~/.poshthemes
elif [ `uname` = "Linux" ]; then
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


