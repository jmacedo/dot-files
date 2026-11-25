alias ..="cd .."
alias grep="grep --color=auto"
alias egrep="egrep --color=auto"
alias eza='eza --oneline --long --icons=always --color=always --hyperlink=always --absolute=off --group-directories-first --git-ignore --show-symlinks --smart-group --header --grid --mounts --modified --extended --git --git-repos-no-status --time-style="+%d/%m/%Y [%H:%M]"'
# Study and customize some aliases with specific model, etc.
alias ai="sbx run opencode ~/Temp"

function __ls_validate_param() {
    case "${1:-}" in
        all)
            extra_params="$extra_params -A"
            ;;
        size)
            extra_params="$extra_params -S"
            ;;
        invert)
            extra_params="$extra_params -r"
            ;;
        *)
            extra_params="$extra_params ${1:-}"
            ;;
    esac

    return 0
}

function ls() {
    local extra_params=""

    if [[ -n "${1:-}" ]]; then
        __ls_validate_param "$1"
    fi

    if [[ -n "${2:-}" ]]; then
        __ls_validate_param "$2"
    fi

    if [[ -n "${3:-}" ]]; then
        extra_params="$extra_params ${3:-}"
    fi

    command -p ls -Blh --color=auto --time=mtime --time-style="+%d/%m/%Y %H:%M" --file-type --group-directories-first --hyperlink=auto --quoting-style=shell-escape -p --classify $extra_params

    return 0
}

function __ll_validate_param() {
    case "${1:-}" in
        all)
            extra_params_ll="${extra_params_ll:-} --all"
            ;;
        size)
            extra_params_ll="${extra_params_ll:-} --total-size"
            ;;
        invert)
            extra_params_ll="${extra_params_ll:-} --reverse"
            ;;
        *)
            extra_params_ll="${extra_params_ll:-} ${1:-}"
            ;;
    esac

    return 0
}

function ll() {
    local extra_params_ll=""

    if [[ -n "${1:-}" ]]; then
        __ll_validate_param "${1:-}"
    fi

    if [[ -n "${2:-}" ]]; then
        __ll_validate_param "${2:-}"
    fi

    if [[ -n "${3:-}" ]]; then
        extra_params_ll="${extra_params_ll:-} ${3:-}"
    fi

    eza --oneline --long --icons=always --color=always --hyperlink=always --absolute=off --group-directories-first --git-ignore --show-symlinks --smart-group --header --grid --mounts --modified --extended --git --git-repos-no-status --time-style="+%d/%m/%Y [%H:%M]" $extra_params_ll

    return 0
}

function cd() {
    local path="${1:-"${HOME:-'/'}"}"

    printf '\033[H\033[2J' # Clear
    builtin cd "$path"
    ll

    return 0
}
