# Bash colors
eval "$(dircolors -b)"

# Zoxide.
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init bash)"

# Fzf.
command -v fzf >/dev/null 2>&1 || return 0
eval "$(fzf --bash)"