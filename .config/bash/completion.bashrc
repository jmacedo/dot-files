# Bash completion - Behavior: ignore case, show both on ambiguous and keeps prefix already typed.
bind "set completion-ignore-case on"
bind "set completion-map-case on"
bind "set show-all-if-ambiguous on"
bind "set show-all-if-unmodified on"
bind "set menu-complete-display-prefix on"
bind "set page-completions off"
bind "set completion-query-items 100"
bind "set visible-stats on"
bind "set colored-stats on"
bind "set colored-completion-prefix on"
bind '"\C-i": menu-complete'
bind '"\e[Z": reverse-menu-complete'

[[ -r "/usr/share/bash-completion/bash_completion" ]] && source "/usr/share/bash-completion/bash_completion"
[[ -r "/etc/bash_completion" ]] && source "/etc/bash_completion"

# Programmable completions locais.
completions_dir="$HOME/.config/bash/completions"
if [[ -d "$completions_dir" ]]; then
    for completion_file in "$completions_dir"/*.bashrc; do
        [[ -r "$completion_file" ]] && source "$completion_file"
    done
fi
