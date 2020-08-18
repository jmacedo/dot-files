[ -f ~/.bash_functions ] && . ~/.bash_functions

export PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[01;33m\]$(git_info)\[\033[01;34m\]\[\033[00m\]\n\$ '