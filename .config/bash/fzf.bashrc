# FZF interactive finder.
command -v fzf >/dev/null 2>&1 || return 0

# Use find because it is available in the base system. Ignore Git metadata.
export FZF_DEFAULT_COMMAND='find -L . -mindepth 1 -path "*/.git" -prune -o -print 2>/dev/null'

# Catppuccin Mocha theme and a compact, bottom-positioned layout.
export FZF_DEFAULT_OPTS="
    --height=60%
    --layout=reverse
    --style=full
    --border=rounded
    --margin=1
    --padding=1
    --info=right
    --border-label=' FZF '
    --input-label=' Search '
    --list-label=' Results '
    --prompt ' '
    --pointer '▶'
    --marker '✓'
    --separator '─'
    --scrollbar '│'
    --color=bg:#1e1e2e,bg+:#313244
    --color=fg:#cdd6f4,fg+:#cdd6f4
    --color=hl:#f9e2af,hl+:#f9e2af
    --color=prompt:#cba6f7,pointer:#89b4fa,marker:#a6e3a1
    --color=border:#6c7086,spinner:#f5c2e7,header:#a6adc8
"

# Load the official Bash key bindings and fuzzy completion.
eval "$(fzf --bash)"
