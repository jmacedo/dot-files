export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="agnoster-altered"
zstyle ':omz:update' mode reminder  # disabled, auto, reminder
HIST_STAMPS="dd.mm.yyyy" # "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd" / see 'man strftime' for details

# CASE_SENSITIVE="true"
# HYPHEN_INSENSITIVE="true"
# zstyle ':omz:update' frequency 13 # Number of days
# DISABLE_MAGIC_FUNCTIONS="true" # Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_AUTO_TITLE="true" # disable auto-setting terminal title.
# ENABLE_CORRECTION="true" # enable command auto-correction
# COMPLETION_WAITING_DOTS="true" # e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# ZSH_CUSTOM=/path/to/new-custom-folder

plugins=(git themes node pyenv aliases colored-man-pages copypath cp per-directory-history)

source "$ZSH/oh-my-zsh.sh"

#: USER CONFIGURATION
#:===================
export LANG="pt_BR.UTF-8"

# export MANPATH="/usr/local/man:$MANPATH"
# Preferred editor for local and remote sessions. TODO: Uncomment for NVIM
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='nano'
# else
#   export EDITOR='nvim'
# fi

source "$ZSH_CUSTOM/aliases.zsh"
source "$ZSH_CUSTOM/export_vars.zsh"

eval "$(zoxide init zsh)"