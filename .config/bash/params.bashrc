HISTSIZE=20000
HISTFILESIZE=50000
HISTCONTROL=ignoreboth:erasedups
HISTIGNORE='ls:ll:la:pwd:exit:clear:history'
HISTTIMEFORMAT='%F %T  ' # "AAAA-MM-DD HH:MM:SS  "

set -o notify
shopt -s histappend
shopt -s cmdhist # Multiple lines commands are saved as one history entry
shopt -s lithist # Besides "cmdhist", preserves break lines in history entries
shopt -s checkwinsize
shopt -s cdspell # Better spelling tolerance in "cd" commands
shopt -s dirspell 2>/dev/null || true # Try to fix directory names ignoring errors
shopt -s nocaseglob # Ignore case on wild cards expansion
shopt -s autocd # Change to directory with out "cd"
shopt -u failglob # No errors in wild cards expansions with no correspondence