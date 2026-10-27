export XDG_DATA_HOME="$HOME/.local/share"

# User binaries
export PATH="$HOME/.local/bin:$PATH"

# Open Code Cli Harness
export PATH="$HOME/.opencode/bin:$PATH"

# Editor
export EDITOR="nvim"
export VISUAL="nvim"

# Go, cargo, npm, fnm, composer
export PATH="$HOME/Apps/fnm:$PATH"
export PATH="$HOME/Apps/npm-tools/node_modules/.bin:$PATH"
export PATH="$HOME/Apps/go/bin:$PATH"
export PATH="$HOME/Apps/cargo/bin:$PATH"
export PATH="$HOME/Apps/composer/vendor/bin:$PATH"

# Go, rustup, cargo
export GOPATH="$HOME/Apps/go"
export CARGO_HOME="$HOME/Apps/cargo"
export RUSTUP_HOME="$HOME/Apps/rustup"

# Zoxide
export _ZO_DATA_DIR="$XDG_DATA_HOME/zoxide"

# BASH THEME (`~/.config/bash/themes/<name>.theme.bashrc`)
export THEME_CURRENT="catppuccin-frappe"

# Fzf theme
export FZF_THEME="catppuccin-frappe"