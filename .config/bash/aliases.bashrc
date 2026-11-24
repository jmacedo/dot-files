alias ..="cd .."

alias ls="ls --color=auto"
alias grep="grep --color=auto"
alias egrep="egrep --color=auto"

alias ll='ls -Blh --time=mtime --time-style="+%d/%m/%Y %H:%M" --file-type --group-directories-first --hyperlink=auto --quoting-style=shell-escape -p --classify'
alias lldotfiles='ll -A'
alias llrecursive="ll -R"
alias llfilesize="ll -S"
alias llfilesizeinverted="ll -Sr"

# Study and customize some aliases with specific model, etc.
alias ai="sbx run opencode ~/Temp"

function cd() {
    local new_directory="$*"

    if [ $# -eq 0]; then
        new_directory=${HOME:-}
    fi

    builtin cd "$new_directory" && ll
}