#!/usr/bin/env bash

# Install and configure some apps and tools for a personal dev, gamer, general PC setup.
# It is build based on a linux bash environment, debian based distros with apt packages in x86 64 bit architectures.
#
# >> CAUTION <<
#   Run this script from its own directory. Paths are build relative to its folder.
# >> CAUTION <<
#
# Instalation summary:
# APT:
#   - git, curl, unzip, vim, file, ffmpeg, 7zip, jq, poppler-utils, fdutils, fzf, zoxide, imagemagick, xclip, wl-clipboard, xsel, flatpak
# DIRECT INSTALL:
#   - kitty 0.74.1, fzf 0.74.1, zoxide, yazi 26.5.6, tree-sitter 0.26.11, neovim 0.12.4, custom fonts from Nerd Fonts
# FLATPAK:
#   - Arduino IDE V2, Dropbox, Android Studio, Chrome, Steam, VS Code, Calculator, Cosmic Tweaks, Cedilla, Bazaar, Obsidian, Proton Pass, Gnome Boxes, OnlyOffice

set -euo pipefail

# To preach the word of the Tux!
print_ascii_art() {
    cat <<'EOF'
    .--.
   |o_o |
   |:_/ |
  //   \ \
 (|     | )
/'\_   _/`\
\___)=(___/
EOF
}

# Define shared values.
initialize_script() {
    declare -gr START_DATE_TIME="$(date '+%Y%m%d%H%M%S')"
    declare -gr BACKUP_EXT="bkp"
    declare -gr SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
    declare -gr SCRIPT_NAME="$(basename -- "${BASH_SOURCE[0]}")"
    declare -gr SCRIPT_PATH="$SCRIPT_DIR/$SCRIPT_NAME"
    declare -gr WORKING_DIR="$(pwd)"
}

# Verify if a command is available in PATH.
command_exists() {
    command -v "$1" > /dev/null 2>&1
}

# Download and install one font from Nerd Fonts [https://www.nerdfonts.com], version 3.4.0.
# Fonts directory: ~/.local/share/fonts
# Requires:
#   - curl, unzip
# References:
#   - https://www.nerdfonts.com
#   - https://github.com/ryanoasis/nerd-fonts
install_nerdfont() {
    local font_name="$1"
    local fonts_path="$HOME/.local/share/fonts"
    local font_path="$fonts_path/$font_name"
    local nerd_fonts_url="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0"
    local archive_path="$(mktemp)"

    if ! command_exists unzip || ! command_exists curl; then
        printf '%s\n' "The packages 'unzip' and 'curl' must be installed."
        return 1
    fi

    if [[ ! -d "$font_path" ]]; then
        mkdir -p "$font_path"
    fi
    
    curl -fL "$nerd_fonts_url/$font_name.zip" -o "$archive_path" > /dev/null 2>&1
    unzip -oq "$archive_path" -d "$font_path" > /dev/null 2>&1
    rm -f "$archive_path"
}

# Overwirtes a .dotfile in HOME directory. If it already exists, make a backup with ".AAAAMMDDHHMMSS.bkp" suffix.
overwrite_dot_file() {
    local dot_file="$1"
    local dot_file_path="$HOME/$dot_file"

    if [[ -e $dot_file_path ]]; then
        mv "$dot_file_path" "$HOME/$dot_file.$START_DATE_TIME.$BACKUP_EXT"
    fi

    cp -f "$SCRIPT_DIR/$dot_file" "$dot_file_path"
}

# Create some custom directories in HOME folder.
create_custom_dirs() {
    local dir_list=(
        "$HOME/Apps"
        "$HOME/Dev"
        "$HOME/Temp"
    )

    mkdir -p "${dir_list[@]}"
}

# Install Kitty. It is a modern terminal emulator with tabs, panels, gpu aceleration, image view and extremely customizable.
# Requires:
#   - install_nerdfont 
# References:
#   - https://sw.kovidgoyal.net/kitty
install_kitty_terminal() {
    install_nerdfont "NerdFontsSymbolsOnly"
    install_nerdfont "Ubuntu"
    install_nerdfont "UbuntuMono"

    curl -fL "https://sw.kovidgoyal.net/kitty/installer.sh" | sh /dev/stdin launch="n" > /dev/null 2>&1

    cp -rf "$SCRIPT_DIR/.config/kitty" "$HOME/.config/"

    sudo ln -sf "$HOME/.local/kitty.app/bin/kitty" "/usr/bin/kitty"
    sudo ln -sf "$HOME/.local/kitty.app/bin/kitten" "/usr/bin/kitten"
    
    local shared_apps="$HOME/.local/share/applications"
    local kitty_shared_apps="$HOME/.local/kitty.app/share/applications"
    if [[ ! -d $shared_apps ]];then
        mkdir -p "$shared_apps"
    fi

    cp -f "$kitty_shared_apps/kitty.desktop" "$shared_apps"
    cp -f "$kitty_shared_apps/kitty-open.desktop" "$shared_apps"
    
    # Update the paths to the kitty and its icon in the kitty desktop file(s)
    sed -i "s|Icon=kitty|Icon=$(readlink -f ~)/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png|g" ~/.local/share/applications/kitty*.desktop
    sed -i "s|Exec=kitty|Exec=$(readlink -f ~)/.local/kitty.app/bin/kitty|g" ~/.local/share/applications/kitty*.desktop
}

# Install fzf fuzzy finder, version 0.74.1. It is an aproximate search, typing just part of the string or not necessarily the same character order.
# Requires:
#   - curl
# References:
#   - https://github.com/junegunn/fzf
install_fzf() {
    local fzf_installer="fzf_0.74.1_amd64.deb"
    curl -LO "https://github.com/junegunn/fzf/releases/download/v0.74.1/$fzf_installer" > /dev/null 2>&1
    chmod +x "./$fzf_installer"
    sudo apt install -y "./$fzf_installer" > /dev/null 2>&1
    rm -f "./$fzf_installer"
}

# "zoxide is a smarter cd command, inspired by z and autojump.
# It remembers which directories you use most frequently, so you can "jump" to them in just a few keystrokes." (directly from oficial site)
# Requires:
#   - curl
#   - fzf
# References:
#   - https://github.com/ajeetdsouza/zoxide
install_zoxide() {
    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh > /dev/null 2>&1
    find "$HOME" -type d -print0 | xargs -0 zoxide add > /dev/null 2>&1
}

# "Yazi is a terminal file manager written in Rust, based on non-blocking async I/O. It aims to provide an efficient, user-friendly, and customizable file management experience." (directly from site)
# Version: 26.5.6
# Plugins:
#   - full-border, diff, catppuccin-mocha, git, mount, smart-enter
# Requires:
#   - curl
# References:
#   - https://yazi-rs.github.io/
#   - https://github.com/sxyazi/yazi
install_yazi() {
    local yazi_installer="yazi-x86_64-unknown-linux-gnu.deb"
    local yazi_plugins=(
        "full-border"
        "diff"
        "catppuccin-mocha"
        "git"
        "mount"
        "smart-enter"        
    )

    curl -LO "https://github.com/sxyazi/yazi/releases/download/v26.5.6/$yazi_installer" > /dev/null 2>&1
    chmod +x "./$yazi_installer"

    sudo apt install  -y "./$yazi_installer" > /dev/null 2>&1
    rm -f "./$yazi_installer"

    for plugin in "${yazi_plugins[@]}";do
        ya pkg add "yazi-rs/plugins:$plugin" > "yazi-plugin-$plugin.log" 2>&1
    done
}

# "Tree-sitter is a parser generator tool and an incremental parsing library. It can build a concrete syntax tree for a source file and efficiently update the syntax tree as the source file is edited." (directly from site)
# Version: 0.26.11
# Requires:
#   - curl, unzip
# References:
#   - https://github.com/tree-sitter/tree-sitter
install_tree_sitter() {
    local tree_sitter_cli_dirname="tree-sitter-cli-linux-x64"
    local tree_sitter_cli_path="$HOME/Apps/$tree_sitter_cli_dirname"

    mkdir -p "$tree_sitter_cli_path"

    (
        cd -- "$tree_sitter_cli_path"
        curl -LO "https://github.com/tree-sitter/tree-sitter/releases/download/v0.26.11/$tree_sitter_cli_dirname.zip" > /dev/null 2>&1
        unzip "$tree_sitter_cli_dirname.zip" > /dev/null 2>&1
        rm -f "$tree_sitter_cli_dirname.zip"
        sudo ln -sf "$tree_sitter_cli_path/tree-sitter" "/usr/bin/tree-sitter"
        cd -- "$WORKING_DIR"
    )
}

# Install NeoVim, a terminal text editor based on Vim.
# Requires:
#   - curl, tar
# References:
#   - https://neovim.io/
#   - https://github.com/neovim/neovim
install_nvim() {
    local nvim_dir="$HOME/Apps/nvim"
    mkdir -p "$nvim_dir"

    (
        cd -- "$nvim_dir"
        curl -LO https://github.com/neovim/neovim/releases/download/v0.12.4/nvim-linux-x86_64.tar.gz > /dev/null 2>&1
        tar xzvf nvim-linux-x86_64.tar.gz > /dev/null 2>&1
        rm -f nvim-linux-x86_64.tar.gz
        sudo ln -sf "$nvim_dir/nvim-linux-x86_64/bin/nvim" "/usr/bin/nvim"
        cd -- "$WORKING_DIR"
    )

    if [[ -d "$HOME/.config/nvim" ]]; then
        mv "$HOME/.config/nvim" "$HOME/.config/nvim.$START_DATE_TIME.$BACKUP_EXT"
    fi

    cp -rf "$SCRIPT_DIR/.config/nvim" "$HOME/.config/nvim"
}

# Install the applications below from flathub.
# Apps:
#   - Arduino IDE V2, Dropbox, Android Studio, Chrome, Steam, VS Code, Calculator, Cosmic Tweaks, Cedilla, Bazaar, Obsidian, Proton Pass, Gnome Boxes, OnlyOffice
install_flatpak_packages() {
  local app
  local apps=(
    "cc.arduino.IDE2"
    "com.dropbox.Client"
    "com.google.AndroidStudio"
    "com.google.Chrome"
    "com.valvesoftware.Steam"
    "com.visualstudio.code"
    "dev.edfloreshz.Calculator"
    "dev.edfloreshz.CosmicTweaks"
    "dev.mariinkys.Cedilla"
    "io.github.kolunmi.Bazaar"
    "md.obsidian.Obsidian"
    "me.proton.Pass"
    "org.gnome.Boxes"
    "org.onlyoffice.desktopeditors"
  )

  for app in "${apps[@]}"; do
    sudo flatpak install --system --noninteractive flathub "$app" > "flatpak-$app.log" 2>&1
  done
}

main() {
    clear
    print_ascii_art
    echo ">> Running setup.sh"
    initialize_script
    create_custom_dirs

    echo "> Upgrade packages"
    #sudo apt update -y > "apt-upgrade.log" 2>&1
    #sudo apt upgrade -y >> "apt-upgrade.log" 2>&1
    #sudo apt autoremove -y >> "apt-upgrade.log" 2>&1
    #sudo apt autoclean -y >> "apt-upgrade.log" 2>&1

    local packages=(
        "git"
        "curl"
        "unzip"
        "vim"
        "file" 
        "ffmpeg"
        "7zip"
        "jq"
        "poppler-utils"
        "fdutils"
        "fzf"
        "zoxide"
        "imagemagick"
        "xclip"
        "wl-clipboard"
        "xsel"
        "flatpak"
    )

    echo "> Install new packages"
    sudo apt install -y "${packages[@]}" > "packages-install.log" 2>&1

    overwrite_dot_file ".bash_aliases" > "dot-files.log"2>&1
    overwrite_dot_file ".bash_export_vars" >> "dot-files.log"2>&1
    overwrite_dot_file ".bashrc" >> "dot-files.log"2>&1
    overwrite_dot_file ".gitconfig" >> "dot-files.log"2>&1
    overwrite_dot_file ".hidden" >> "dot-files.log"2>&1

    sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo > "flathub-add.log" 2>&1

    echo "> Install Kitty"
    install_kitty_terminal
    echo "> Install fzf"
    install_fzf
    echo "> Install zoxide"
    install_zoxide
    echo "> Install tree-sitter"
    install_tree_sitter
    echo "> Install yazi"
    install_yazi
    echo "> Install nvim"
    install_nvim
    echo "> Install flatpak apps"
    install_flatpak_packages

    echo ">> setup.sh finished."
}

main "$@"
