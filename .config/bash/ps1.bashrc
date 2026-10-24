CUSTOM_USER_PS1="\u@\h - \w"

__ps1_get_git_branch() {
    command -v git >/dev/null 2>&1 || return 0
    git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return 0

    local git_branch
    git_branch=$(git symbolic-ref --quiet --short HEAD 2>/dev/null) ||
        git_branch=$(git rev-parse --short HEAD 2>/dev/null) || return 0

    printf '%s' "$git_branch"
}

__ps1_get_user_icon() {
    printf '%s' $'\uE36E' # 
}

__ps1_get_os_icon() {
    local os_id=''

    case "$(uname -s)" in
        Darwin)
            printf '%s' $'\uF179' # 
            return 0
            ;;
        Linux)
            if [[ -r /proc/device-tree/model ]] && [[ $(</proc/device-tree/model) == *'Raspberry Pi'* ]]; then
                printf '%s' $'\uF315' # 
                return 0
            fi

            if [[ -r /etc/os-release ]]; then
                # shellcheck disable=SC1091
                source /etc/os-release
                os_id=${ID,,}
            fi
            ;;
        *)
            printf '%s' $'\uF31A' # 
            return 0
            ;;
    esac

    case "$os_id" in
        pop)
            printf '%s' $'\uF32A' # 
            ;;
        ubuntu)
            printf '%s' $'\uF31B' # 
            ;;
        linuxmint)
            printf '%s' $'\uF30E' # 
            ;;
        zorin)
            printf '%s' $'\uF32F' # 
            ;;
        deepin)
            printf '%s' $'\uF321' # 
            ;;
        debian)
            printf '%s' $'\uF306' # 
            ;;
        bazzite|fedora)
            printf '%s' $'\uF30A' # 
            ;;
        arch)
            printf '%s' $'\uF303' # 
            ;;
        steamos)
            printf '%s' $'\uF1B6' # 
            ;;
        kali)
            printf '%s' $'\uF327' # 
            ;;
        raspbian)
            printf '%s' $'\uF315' # 
            ;;
        *)
            printf '%s' $'\uF31A' # 
            ;;
    esac
}

__ps1_get_dir_icon() {
    printf '%s' $'\uF115' # 
}

__ps1_get_clock_icon() {
    printf '%s' $'\uF017' # 
}

__ps1_get_git_icon() {
    printf '%s' $'\uE725' # 
}

__ps1_get_git_modified_icon() {
    command -v git >/dev/null 2>&1 || return 0
    git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return 0

    if [[ -n $(git status --porcelain --untracked-files=normal 2>/dev/null) ]]; then
        printf '%s' $'\uF044' # 
    fi
}

__ps1_get_success_icon() {
    printf '%s' $'\uF00C' # 
}

__ps1_get_failure_icon() {
    printf '%s' $'\uF00D' # 
}

__ps1_get_prompt_icon() {
    printf '%s' $'\u276F' # ❯
}

__ps1_sty_reset() {
    printf '\\[\e[0m\\]'
}

__ps1_sty_color() {
    local red="$1"
    local green="$2"
    local blue="$3"

    printf '\\[\e[38;2;%s;%s;%sm\\]' "$red" "$green" "$blue"
}

__ps1_get_left_border_up() {
    printf '%s' $'\u256D\u2500' # ╭─
}

__ps1_get_left_border_down() {
    printf '%s' $'\u2570\u2500' # ╰─
}

__ps1_prompt_command() {
    local last_exec_status_code=$?
    local git_branch
    local user_icon
    local os_icon
    local dir_icon
    local clock_icon
    local git_icon
    local git_modified_icon
    local success_icon
    local failure_icon
    local prompt_icon
    local left_border_up
    local left_border_down
    local current_datetime
    local color_green
    local color_red
    local color_blue
    local color_purple
    local color_light_red
    local color_gray
    local color_yellow
    local style_reset
    local git_section=''
    local last_exec_status=''
    local last_exec_status_color=''

    git_branch=$(__ps1_get_git_branch)
    user_icon=$(__ps1_get_user_icon)
    os_icon=$(__ps1_get_os_icon)
    dir_icon=$(__ps1_get_dir_icon)
    clock_icon=$(__ps1_get_clock_icon)
    git_icon=$(__ps1_get_git_icon)
    success_icon=$(__ps1_get_success_icon)
    failure_icon=$(__ps1_get_failure_icon)
    prompt_icon=$(__ps1_get_prompt_icon)
    left_border_up=$(__ps1_get_left_border_up)
    left_border_down=$(__ps1_get_left_border_down)
    printf -v current_datetime '%(%d/%m/%Y %H:%M)T' -1
    current_datetime+='h'

    color_green=$(__ps1_sty_color 166 227 161)
    color_red=$(__ps1_sty_color 243 139 168)
    color_blue=$(__ps1_sty_color 137 180 250)
    color_purple=$(__ps1_sty_color 203 166 247)
    color_light_red=$(__ps1_sty_color 245 224 220)
    color_gray=$(__ps1_sty_color 108 112 134)
    color_yellow=$(__ps1_sty_color 249 226 175)
    style_reset=$(__ps1_sty_reset)

    if [[ -n "$git_branch" ]]; then
        git_modified_icon=$(__ps1_get_git_modified_icon)

        if [[ -n "$git_modified_icon" ]]; then
            git_section="${color_red}${git_icon} ${git_branch} ${git_modified_icon}${style_reset} "
        else
            git_section="${color_yellow}${git_icon} ${git_branch}${style_reset} "
        fi
    fi

    if (( last_exec_status_code == 0 )); then
        last_exec_status=$success_icon
        last_exec_status_color=$color_green
    else
        last_exec_status="${last_exec_status_code} ${failure_icon}"
        last_exec_status_color=$color_light_red
    fi

    CUSTOM_USER_PS1="${color_gray}${left_border_up}${style_reset} ${color_yellow}${dir_icon} \w${style_reset} ${git_section}${color_gray}${clock_icon} ${current_datetime} ${last_exec_status_color}[${last_exec_status}]${style_reset} ${color_purple}${user_icon} \u@\h ${os_icon}${style_reset}\n${color_gray}${left_border_down}${style_reset} ${color_blue}${prompt_icon}${style_reset} "
    PS1=$CUSTOM_USER_PS1
}

PROMPT_COMMAND='__ps1_prompt_command'
PS1=$CUSTOM_USER_PS1
