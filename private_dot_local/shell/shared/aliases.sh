alias ll='ls -alF'
alias la='ls -A'
alias gs='git status'
alias gd='git diff'

alias gssh='gcloud compute ssh'
alias gscp='gcloud compute scp'

# Run with a system-ish PATH
sys() { command env PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" "$@"; }

alias yay='sys yay'