# LOAD ONLY IN INTERACTIVE SHELL
[[ $- != *i* ]] && return

# PS1 CHARACTER
# Optional separator icons
#__icon_separator=$'\u2758' # ❘
#__icon_separator=$'\uEA9F' # 
#__icon_separator=$'\uEAB6' # 
#__icon_separator=$'\uF105' # 
#__icon_separator=$'\uEB04' # 
#__icon_separator=$'\uEB10' # 

# Optional user icon
#__icon_user=$'\uEB99' # 
#__icon_user=$'\uF007' # 

# Optional folder icon
#__icon_folder=$'\uF0A4' #  

# Optional prompt icon
#__icon_prompt=$'\uF120' # 

__icon_user=$'\uE36E'            # 
__icon_prompt=$'\u276F'          # ❯
__icon_folder=$'\uF115'          # 
__icon_separator=$'\uF0DA'       # 
__icon_top_left=$'\u256D'        # ╭
__icon_horizontal_line=$'\u2500' # ─
__icon_top_right=$'\u256E'       # ╮
__icon_bottom_left=$'\u2570'     # ╰
__icon_os=$'\uF32A'              # 
__icon_at=$'\uF1FA'              #  
__icon_clock=$'\uF017'           # 
__icon_git=$'\uE725'             # 
__icon_success=$'\u2713'         # ✓
__icon_failure=$'\u2717'         # ✗
__last_status=''
__prompt_status=''
__git_info_branch_name=''
__is_git_directory=false

# HISTORY
HISTSIZE=20000
HISTFILESIZE=50000
HISTCONTROL=ignoreboth:erasedups
HISTIGNORE='ls:ll:la:pwd:exit:clear:history'
HISTTIMEFORMAT='%F %T  ' # "AAAA-MM-DD HH:MM:SS  "

# SHELL PARAMETERS
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

# BASH COMPLETION
if [[ -r /usr/share/bash-completion/bash_completion ]]; then
    source /usr/share/bash-completion/bash_completion
elif [[ -r /etc/bash_completion ]]; then
    source /etc/bash_completion
fi

# Completion behavior: ignore case, show both on ambiguous and keeps the prefix that has already been typed. 
bind 'set completion-ignore-case on'
bind 'set show-all-if-ambiguous on'
bind 'set menu-complete-display-prefix on'

# CUSTOM ALIASES AND VAR EXPORTS
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

if [ -f ~/.bash_export_vars ]; then
    . ~/.bash_export_vars
fi

# PS1 DEFINITION
__git_info_load_branch_name() {
    command -v git >/dev/null 2>&1 || return 0
    #git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return 0

    if [[ $(git rev-parse --is-inside-work-tree 2>&1) ]];then
        __git_info_branch_name=$(git symbolic-ref --quiet --short HEAD 2>/dev/null) ||
            __git_info_branch_name=$(git rev-parse --short HEAD 2>/dev/null) || return 0

        __is_git_directory=true
    else
        __git_info_branch_name=""
        __is_git_directory=false
    fi
}

__git_info_text() {
    __git_info_load_branch_name

    if [[ -n $(git status --porcelain --untracked-files=normal 2>/dev/null) ]]; then
        printf '%s %s* ' "$__icon_git" "$__git_info_branch_name"
    elif [[ "$__git_info_branch_name" != "" ]]; then
        printf '%s %s ' "$__icon_git" "$__git_info_branch_name"
    else
        printf ''
    fi
}

__git_info_color() {
    __git_info_load_branch_name
    local color_text=""

    if [[ -n $(git status --porcelain --untracked-files=normal 2>/dev/null) ]]; then
        color_text='243;139;168'
    else
        color_text='249;226;175'
    fi

    if [[ $__is_git_directory ]]; then
        printf '%s' $color_text
    else
        printf ''
    fi
}

__prompt_command() {
    __last_status=$?

    if (( __last_status == 0 )); then
        __prompt_status="${__icon_success}"
    else
        __prompt_status="${__icon_failure} ${__last_status}"
    fi

    # Maintain the history between terminals
    builtin history -a
    builtin history -n
}

PROMPT_COMMAND='__prompt_command'
PS1='\[\e[38;2;108;112;134m\]${__icon_top_left}${__icon_horizontal_line}\[\e[0m\] \[\e[38;2;137;180;250m\]${__icon_user}\[\e[0m\] \[\e[38;2;108;112;134m\]\u${__icon_at} \h\[\e[0m\] \[\e[38;2;137;180;250m\]${__icon_os}  ${__icon_separator}\[\e[0m\] \[\e[38;2;249;226;175m\]${__icon_folder}  \w\[\e[0m\] \[\e[38;2;203;166;247m\]${__icon_clock} \D{%d/%m/%Y %H:%M}h\[\e[0m\] \[\e[38;2;$(__git_info_color)m\]$(__git_info_text)\[\e[0m\]\[\e[38;2;108;112;134m\]${__icon_top_right}\[\e[0m\]\n\[\e[38;2;108;112;134m\]${__icon_bottom_left}${__icon_horizontal_line}\[\e[0m\] \[$( [[ ${__last_status:-0} -eq 0 ]] && printf "\e[38;2;166;227;161m" || printf "\e[38;2;243;139;168m" )\]${__prompt_status}\[\e[0m\] \[\e[38;2;137;180;250m\]${__icon_prompt}\[\e[0m\] '

# DOCS FOR CONFIGURATION DETAILS

# Color scheme
# GREEN       (rgb 166,227,161)
# RED         (rgb 243,139,168)
# BLUE        (rgb 137,180,250)
# PURPLE      (rgb 203,166,247)
# LIGHT RED   (rgb 245,224,220) 
# GRAY        (rgb 108,112,134) 
# YELLOW      (rgb 249,226,175)

# PS1
# \[\e[38;2;108;112;134m\] # GRAY
# ${__icon_top_left}${__icon_horizontal_line} # BORDER ICONS
# \[\e[0m\] # RESET
# \[\e[38;2;137;180;250m\] # BLUE
# ${__icon_user} # USER ICON
# \[\e[0m\]  # RESET
# \[\e[38;2;108;112;134m\] # GRAY
# \u # USER NAME
# ${__icon_at} # "AT" SYMBOL
# \h # HOST NAME
# \[\e[0m\] # RESET
# \[\e[38;2;137;180;250m\] # BLUE
# ${__icon_os} # OS ICON
# ${__icon_separator} # SEPARATOR ICON
# \[\e[0m\] \[\e[38;2;249;226;175m\] # YELLOW
# ${__icon_folder} # FOLDER ICON
# \w # WORKING DIR
# \[\e[0m\] # RESET
# \[\e[38;2;203;166;247m\] # PURPLE
# ${__icon_clock} # CLOCK ICON
# \D{%d/%m/%Y %H:%M}h # DATETIME FORMATED IN STRFTIME
# \[\e[0m\] # RESET
# \[\e[38;2;$(__git_info_color)m\] # GIT BRANCH COLOR: RED OR GREEN
# $(__git_info_text) # GIT BRANCH NAME
# \[\e[0m\] # RESET
# \[\e[38;2;108;112;134m\] # GRAY
# ${__icon_top_right} # BORDER ICON
# \[\e[0m\] # RESET
# \n # NEW LINE
# \[\e[38;2;108;112;134m\] # GRAY
# ${__icon_bottom_left} ${__icon_horizontal_line} # BORDER ICONS
# \[\e[0m\] # RESET
# \[$( [[ ${__last_status:-0} -eq 0 ]] && printf "\e[38;2;166;227;161m" || printf "\e[38;2;243;139;168m" )\] # LAST EXECUTION STATUS COLOR
# ${__prompt_status} # LAST EXECUTION STATUS CODE
# \[\e[0m\] # RESET
# \[\e[38;2;137;180;250m\] # BLUE
# ${__icon_prompt} # CURRENT PROMPT ICON
# \[\e[0m\] # RESET