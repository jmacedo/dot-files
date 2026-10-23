# Bash completion - Behavior: ignore case, show both on ambiguous and keeps prefix already typed.
bind 'set completion-ignore-case on'
bind 'set show-all-if-ambiguous on'
bind 'set menu-complete-display-prefix on'
[[ -r "/usr/share/bash-completion/bash_completion" ]] && source "/usr/share/bash-completion/bash_completion"
[[ -r "/etc/bash_completion" ]] && source "/etc/bash_completion"