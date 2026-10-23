export XDG_DATA_HOME="$HOME/.local/share"
export EDITOR="nvim"
export VISUAL="nvim"

# Zoxide
zoxide_data_dir="$XDG_DATA_HOME/zoxide"
mkdir -p -- "$zoxide_data_dir"
export _ZO_DATA_DIR="$zoxide_data_dir"

command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init bash)"
