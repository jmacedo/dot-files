# Load only in interactive shell.
[[ $- != *i* ]] && return

# Default lang utf-8, respecting previous configured lang.
# Utf-8 is necessary to render symbols in terminal.
case "${LC_ALL:-${LC_CTYPE:-${LANG:-"utf8"}}}" in
  *UTF-8*|*UTF8*|*utf8*|*utf-8*) ;;
  *) export LANG=C.UTF-8 LC_ALL=C.UTF-8 ;;
esac

# Custom bash configurations.

BASH_CONFIG_DIR="$HOME/.config/bash"

# External .bashrc configs: "~/.config/bash/<name>.bashrc".
# Pay attention to the order to load each one.
bashrc_list=(
  "aliases"
  "completion"
  "params"
  "ps1"
  "exports"
  "integrations"
)

for bashrc_config in ${bashrc_list[@]}; do
  [[ -r "$BASH_CONFIG_DIR/$bashrc_config.bashrc" ]] && source "$BASH_CONFIG_DIR/$bashrc_config.bashrc"
done