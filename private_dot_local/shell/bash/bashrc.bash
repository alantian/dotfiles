shopt -s histappend
PROMPT_COMMAND='history -a; history -n'
PS1='\u@\h:\w\$ '

if [ -r /etc/bash_completion ]; then
  . /etc/bash_completion
elif [ -r /usr/local/etc/bash_completion ]; then
  . /usr/local/etc/bash_completion
fi
