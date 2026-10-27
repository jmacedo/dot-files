# Zoxide.
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init bash)"

# Fnm.
eval "$(fnm env --use-on-cd --shell bash)"

# Fzf.
command -v fzf >/dev/null 2>&1 || return 0
eval "$(fzf --bash)"