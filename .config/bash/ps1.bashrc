CUSTOM_USER_PS1="\u@\h - \w"

__ps1_get_git_branch() {
    command -v git >/dev/null 2>&1 || return 0
    git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return 0

    local git_branch
    git_branch=$(git symbolic-ref --quiet --short HEAD 2>/dev/null) ||
        git_branch=$(git rev-parse --short HEAD 2>/dev/null) || return 0

    printf "%s" "$git_branch"
}

__ps1_get_user_icon() {
    printf "%s" $'\uE36E' # 
}

# Raspberry PI arch, Pop OS, Ubuntu, Linux Mint, Zorin OS, Deepin, Bazzite/Fedora, Arch, Steam OS, Raspbian and Tux for others.
__ps1_get_os_icon() {
    local os_id=""

    case "$(uname -s)" in
        Darwin)
            printf "%s" $'\uF179' # 
            return 0
            ;;
        Linux)
            if [[ -r /proc/device-tree/model ]] && [[ $(</proc/device-tree/model) == *"Raspberry Pi"* ]]; then
                printf "%s" $'\uF315' # 
                return 0
            fi

            if [[ -r /etc/os-release ]]; then
                # shellcheck disable=SC1091
                source /etc/os-release
                os_id=${ID,,}
            fi
            ;;
        *)
            printf "%s" $'\uF31A' # 
            return 0
            ;;
    esac

    case "$os_id" in
        pop)
            printf "%s" $'\uF32A' # 
            ;;
        ubuntu)
            printf "%s" $'\uF31B' # 
            ;;
        linuxmint)
            printf "%s" $'\uF30E' # 
            ;;
        zorin)
            printf "%s" $'\uF32F' # 
            ;;
        deepin)
            printf "%s" $'\uF321' # 
            ;;
        debian)
            printf "%s" $'\uF306' # 
            ;;
        bazzite|fedora)
            printf "%s" $'\uF30A' # 
            ;;
        arch)
            printf "%s" $'\uF303' # 
            ;;
        steamos)
            printf "%s" $'\uF1B6' # 
            ;;
        kali)
            printf "%s" $'\uF327' # 
            ;;
        raspbian)
            printf "%s" $'\uF315' # 
            ;;
        *)
            printf "%s" $'\uF31A' # 
            ;;
    esac
}

__ps1_get_dir_icon() {
    printf "%s" $'\uF115' # 
}

__ps1_get_clock_icon() {
    printf "%s" $'\uF017' # 
}

__ps1_get_git_icon() {
    printf "%s" $'\uE725' # 
}

__ps1_get_git_modified_icon() {
    command -v git >/dev/null 2>&1 || return 0
    git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return 0

    if [[ -n $(git status --porcelain --untracked-files=normal 2>/dev/null) ]]; then
        printf "%s" $'\uF044' # 
    fi
}

__ps1_get_success_icon() {
    printf "%s" $'\uF00C' # 
}

__ps1_get_failure_icon() {
    printf "%s" $'\uF00D' # 
}

__ps1_get_prompt_icon() {
    printf "%s" $'\u276F' # ❯
}

__ps1_sty_reset() {
    printf "\\[\e[0m\\]"
}

__ps1_sty_color() {
    local red="$1"
    local green="$2"
    local blue="$3"

    printf "\\[\e[38;2;%s;%s;%sm\\]" "$red" "$green" "$blue"
}

__ps1_get_left_border_up() {
    printf "%s" $'\u256D\u2500' # ╭─
}

__ps1_get_left_border_down() {
    printf "%s" $'\u2570\u2500' # ╰─
}

__ps1_align_three_columns() {
    local left_visible="$1"
    local center_visible="$2"
    local right_visible="$3"
    local left_rendered="$4"
    local center_rendered="$5"
    local right_rendered="$6"
    local terminal_columns="${COLUMNS:-80}"
    local minimum_gap=1
    local left_width
    local center_width
    local right_width
    local center_start
    local right_start

    [[ "$terminal_columns" =~ ^[1-9][0-9]*$ ]] || terminal_columns=120

    # Measure only text without ANSI escape sequences.
    left_width=${#left_visible}
    center_width=${#center_visible}
    right_width=${#right_visible}

    # Terminal columns are zero-indexed for these position calculations.
    center_start=$(( (terminal_columns - center_width) / 2 ))
    right_start=$(( terminal_columns - right_width ))

    # Keep the sections readable when the terminal is too narrow.
    if (( center_start < left_width + minimum_gap )) ||
       (( right_start < center_start + center_width + minimum_gap )); then
        printf '%s %s %s' \
            "$left_rendered" \
            "$center_rendered" \
            "$right_rendered"
        return
    fi

    printf '%s%*s%s%*s%s' \
        "$left_rendered" \
        "$(( center_start - left_width ))" "" \
        "$center_rendered" \
        "$(( right_start - center_start - center_width ))" "" \
        "$right_rendered"
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
    local current_dir
    local short_hostname
    local git_visible=""
    local git_rendered=""
    local left_visible
    local center_visible
    local right_visible
    local left_rendered
    local center_rendered
    local right_rendered
    local top_line
    local last_exec_status=""
    local last_exec_status_color=""

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
    printf -v current_datetime "%(%d/%m/%Y %H:%M)T" -1
    current_datetime+="h"
    color_green=$(__ps1_sty_color 166 227 161)
    color_red=$(__ps1_sty_color 243 139 168)
    color_blue=$(__ps1_sty_color 137 180 250)
    color_purple=$(__ps1_sty_color 203 166 247)
    color_light_red=$(__ps1_sty_color 245 224 220)
    color_gray=$(__ps1_sty_color 108 112 134)
    color_yellow=$(__ps1_sty_color 249 226 175)
    style_reset=$(__ps1_sty_reset)

    # Convert $PWD to a short path equivalent to \w.
    if [[ "$PWD" == "$HOME" ]]; then
        current_dir="~"
    elif [[ "$PWD" == "$HOME/"* ]]; then
        current_dir="~/${PWD#"$HOME"/}"
    else
        current_dir=$PWD
    fi

    # Match the short host name displayed by \h.
    short_hostname="${HOSTNAME%%.*}"

    # Build Git sections without and with ANSI escape sequences.
    if [[ -n "$git_branch" ]]; then
        git_modified_icon=$(__ps1_get_git_modified_icon)
        git_visible="${git_icon} ${git_branch}"

        if [[ -n "$git_modified_icon" ]]; then
            git_visible+=" ${git_modified_icon}"
            git_rendered="${color_red}${git_visible}${style_reset}"
        else
            git_rendered="${color_yellow}${git_visible}${style_reset}"
        fi
    fi

    # Handle last command execution status.
    if (( last_exec_status_code == 0 )); then
        # Success.
        last_exec_status=$success_icon
        last_exec_status_color=$color_green
    else
        # Failure.
        last_exec_status="${last_exec_status_code} ${failure_icon}"
        last_exec_status_color=$color_light_red
    fi

    # Left section: border, current directory and Git state.
    left_visible="${left_border_up} ${dir_icon} ${current_dir}"
    left_rendered="${color_gray}${left_border_up}${style_reset} ${color_yellow}${dir_icon} ${current_dir}${style_reset}"

    if [[ -n "$git_visible" ]]; then
        left_visible+=" ${git_visible}"
        left_rendered+=" ${git_rendered}"
    fi

    # Center section: current date and time.
    center_visible="${clock_icon} ${current_datetime}"
    center_rendered="${color_gray}${center_visible}${style_reset}"

    # Right section: exit status, user, host and operating system.
    right_visible="[${last_exec_status}] ${user_icon} ${USER}@${short_hostname} ${os_icon}"
    right_rendered="${last_exec_status_color}[${last_exec_status}]${style_reset} ${color_purple}${user_icon} \u@\h ${os_icon}${style_reset}"

    # Calculate spacing from unstyled sections, then render their styled forms.
    top_line=$(
        __ps1_align_three_columns \
            "$left_visible" \
            "$center_visible" \
            "$right_visible" \
            "$left_rendered" \
            "$center_rendered" \
            "$right_rendered"
    )

    # Update PS1.
    CUSTOM_USER_PS1="${top_line}\n${color_gray}${left_border_down}${style_reset} ${color_blue}${prompt_icon}${style_reset} "
    PS1=$CUSTOM_USER_PS1

    # Maintain the history between terminals.
    builtin history -a
    builtin history -n
}

PROMPT_COMMAND="__ps1_prompt_command"
PS1=$CUSTOM_USER_PS1
