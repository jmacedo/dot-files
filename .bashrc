# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

HISTCONTROL=ignoreboth
HISTSIZE=5000
HISTFILESIZE=10000

shopt -s histappend
shopt -s checkwinsize

export GIT_PS1_SHOWDIRTYSTATE=1
export GIT_PS1_SHOWSTASHSTATE=1
export GIT_PS1_SHOWUNTRACKEDFILES=1
export GIT_PS1_SHOWUPSTREAM=auto
export GIT_PS1_SHOWCOLORHINTS=1

PS1='\[\e[2m\]$(date +%d/%m/%Y) [$(date +%H:%M)]\[\e[0m\] - \u@\h: \[\e[1m\]\w\[\e[0m\]\n$(__git_ps1 "\[\e[33m\]\[\e[2m\]\[\e[3m\]( %s\[\e[33m\]\[\e[2m\]\[\e[3m\])")\[\e[35m\]\[\e[1m\] \$ \[\e[0m\]'

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

if [ -f ~/.bash_export_vars ]; then
    . ~/.bash_export_vars
fi

eval "$(zoxide init bash)"