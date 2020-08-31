if [ -f ~/.bash_functions ]; then 
	. ~/.bash_functions
fi

export PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[01;33m\]$(git_info)\[\033[01;34m\]\[\033[00m\]\n\$ '
