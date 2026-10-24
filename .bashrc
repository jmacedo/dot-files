# Load only in interactive shell
[[ $- != *i* ]] && return

# Default lang utf-8, respecting previous configured lang
# Utf-8 is necessary to render symbols in terminal.
case "${LC_ALL:-${LC_CTYPE:-${LANG:-"utf8"}}}" in
  *UTF-8*|*UTF8*|*utf8*|*utf-8*) ;;
  *) export LANG=C.UTF-8 LC_ALL=C.UTF-8 ;;
esac

# Custom bash configurations.
# All files under BASH_CONFIG_DIR with ".bashrc" suffix will be included.
BASH_CONFIG_DIR="$HOME/.config/bash"

for bashrc_config in `find -L "$BASH_CONFIG_DIR" -type f -name "*.bashrc"`; do
  [[ -r "$bashrc_config" ]] && source "$bashrc_config"
done