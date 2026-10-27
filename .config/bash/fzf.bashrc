# FZF interactive finder.
command -v fzf >/dev/null 2>&1 || return 0

# Use find because it is available in the base system. Ignore Git metadata.
export FZF_DEFAULT_COMMAND='find -L . -mindepth 1 -path "*/.git" -prune -o -print 2>/dev/null'

# Catppuccin Mocha theme and a compact, bottom-positioned layout.
export FZF_DEFAULT_OPTS="
    --height=60%
    --layout=reverse
    --border=rounded
    --margin=1
    --padding=1
    --info=inline
    --prompt=' '
    --pointer='▶'
    --marker='✓'
    --separator='─'
    --scrollbar='│'
    --color=bg:#1e1e2e,bg+:#313244
    --color=fg:#cdd6f4,fg+:#cdd6f4
    --color=hl:#f9e2af,hl+:#f9e2af
    --color=prompt:#cba6f7,pointer:#89b4fa,marker:#a6e3a1
    --color=border:#6c7086,spinner:#f5c2e7,header:#a6adc8
"

__fzf_list_paths() {
    find -L . -mindepth 1 -path '*/.git' -prune -o -print 2>/dev/null
}

__fzf_list_directories() {
    find -L . -mindepth 1 -path '*/.git' -prune -o -type d -print 2>/dev/null
}

__fzf_insert_selected_path() {
    local selection

    selection="$(__fzf_list_paths | fzf)" || return
    printf -v selection '%q' "$selection"

    READLINE_LINE="${READLINE_LINE:0:READLINE_POINT}${selection} ${READLINE_LINE:READLINE_POINT}"
    READLINE_POINT=$(( READLINE_POINT + ${#selection} + 1 ))
}

__fzf_change_directory() {
    local directory

    directory="$(__fzf_list_directories | fzf)" || return
    builtin cd -- "$directory" || return

    READLINE_LINE=""
    READLINE_POINT=0
}

__fzf_search_history() {
    local selected
    local command

    selected="$(HISTTIMEFORMAT= builtin history | fzf --tac --no-sort --nth=2.. --query="$READLINE_LINE")" || return

    if [[ "$selected" =~ ^[[:space:]]*[0-9]+[[:space:]]+(.*)$ ]]; then
        command="${BASH_REMATCH[1]}"
    else
        return
    fi

    READLINE_LINE=$command
    READLINE_POINT=${#READLINE_LINE}
}

# Define self-contained key bindings without distribution-specific scripts.
bind -x '"\C-t":__fzf_insert_selected_path'
bind -x '"\ec":__fzf_change_directory'
bind -x '"\C-r":__fzf_search_history'
