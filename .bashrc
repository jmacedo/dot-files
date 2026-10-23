# Load only in interactive shell
[[ $- != *i* ]] && return

# Default lang utf-8, respecting previous configured lang
# Utf-8 is necessary to render symbols in terminal.
case "${LC_ALL:-${LC_CTYPE:-${LANG:-"utf8"}}}" in
  *UTF-8*|*UTF8*|*utf8*|*utf-8*) ;;
  *) export LANG=C.UTF-8 LC_ALL=C.UTF-8 ;;
esac

# Custom bash configuration
BASH_CONFIG_DIR="$HOME/.config/bash"
export PATH="$HOME/.local/bin:$PATH"

for bash_module in aliases completion exports params ps1; do
  bash_module_path="$BASH_CONFIG_DIR/$bash_module.bashrc"
  [[ -r "$bash_module_path" ]] && source "$bash_module_path"
done

unset bash_module bash_module_path
