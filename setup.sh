#!/usr/bin/env bash

set -euo pipefail

initialize_script() {
    declare -gr START_DATE_TIME="$(date '+%Y%m%d%H%M%S')"
    declare -gr BACKUP_EXT="bkp"
    declare -gr SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
    declare -gr SCRIPT_NAME="$(basename -- "${BASH_SOURCE[0]}")"
    declare -gr SCRIPT_PATH="$SCRIPT_DIR/$SCRIPT_NAME"
    declare -gr WORKING_DIR="$(pwd)"
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

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
    
    curl -fL "$nerd_fonts_url/$font_name.zip" -o "$archive_path"
    unzip -oq "$archive_path" -d "$font_path"
    rm -f "$archive_path"
}

overwrite_dot_file() {
    local dot_file="$1"
    local dot_file_path="$HOME/$dot_file"

    if [[ -e $dot_file_path ]]; then
        mv "$dot_file_path" "$HOME/$dot_file.$START_DATE_TIME.$BACKUP_EXT"
    fi

    cp -f "$SCRIPT_DIR/$dot_file" "$dot_file_path"
}

create_custom_dirs() {
    local dir_list=(
        "$HOME/Apps"
        "$HOME/Dev"
        "$HOME/Temp"
    )

    mkdir -p "${dir_list[@]}"
}

install_kitty_terminal() {
    install_nerdfont "NerdFontsSymbolsOnly"
    install_nerdfont "Ubuntu"
    install_nerdfont "UbuntuMono"

    curl -fL "https://sw.kovidgoyal.net/kitty/installer.sh" |
        sh /dev/stdin launch="n"

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

install_fzf() {
    local fzf_installer="fzf_0.74.1_amd64.deb"
    curl -LO "https://github.com/junegunn/fzf/releases/download/v0.74.1/$fzf_installer"
    chmod +x "./$fzf_installer"
    sudo apt install -y "./$fzf_installer"
    rm -f "./$fzf_installer"
}

install_zoxide() {
    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
    find "$HOME" -type d -print0 | xargs -0 zoxide add
}

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

    curl -LO "https://github.com/sxyazi/yazi/releases/download/v26.5.6/$yazi_installer"
    chmod +x "./$yazi_installer"

    sudo apt install  -y "./$yazi_installer"
    rm -f "./$yazi_installer"

    for plugin in "${yazi_plugins[@]}";do
        ya pkg add "yazi-rs/plugins:$plugin"
    done
}

install_tree_sitter() {
    local tree_sitter_cli_dirname="tree-sitter-cli-linux-x64"
    local tree_sitter_cli_path="$HOME/Apps/$tree_sitter_cli_dirname"

    mkdir -p "$tree_sitter_cli_path"

    (
        cd -- "$tree_sitter_cli_path"
        curl -LO "https://github.com/tree-sitter/tree-sitter/releases/download/v0.26.11/$tree_sitter_cli_dirname.zip"
        unzip "$tree_sitter_cli_dirname.zip"
        rm -f "$tree_sitter_cli_dirname.zip"
        sudo ln -sf "$tree_sitter_cli_path/tree-sitter" "/usr/bin/tree-sitter"
        cd -- "$WORKING_DIR"
    )
}

install_nvim() {
    local nvim_dir="$HOME/Apps/nvim"
    mkdir -p "$nvim_dir"

    (
        cd -- "$nvim_dir"
        curl -LO https://github.com/neovim/neovim/releases/download/v0.12.4/nvim-linux-x86_64.tar.gz
        tar xzvf nvim-linux-x86_64.tar.gz
        rm -f nvim-linux-x86_64.tar.gz
        sudo ln -sf "$nvim_dir/nvim-linux-x86_64/bin/nvim" "/usr/bin/nvim"
        cd -- "$WORKING_DIR"
    )

    if [[ -d "$HOME/.config/nvim" ]]; then
        mv "$HOME/.config/nvim" "$HOME/.config/nvim.$START_DATE_TIME.$BACKUP_EXT"
    fi

    cp -rf "$SCRIPT_DIR/.config/nvim" "$HOME/.config/nvim"
}

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
    flatpak install flathub "$app"
  done
}

main() {
    echo ">> VARIÁVEIS DE AMBIENTE"
    initialize_script > "init.log"
    echo ">> CUSTOM DIRS"
    create_custom_dirs > "custom-dirs.log"

    echo ">> APT UPGRADE"
    sudo apt update -y &&
    sudo apt upgrade -y &&
    sudo apt autoremove -y &&
    sudo apt autoclean -y > "apt-upgrade.log"

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

    echo ">> PACKAGES INSTALL"
    sudo apt install -y "${packages[@]}" > "packages-install.log"

    echo ">> OVERWRITE DOT FILES"
    overwrite_dot_file ".bash_aliases" > "dot-files.log"
    overwrite_dot_file ".bash_export_vars" >> "dot-files.log"
    overwrite_dot_file ".bashrc" >> "dot-files.log"
    overwrite_dot_file ".gitconfig" >> "dot-files.log"
    overwrite_dot_file ".hidden" >> "dot-files.log"

    echo ">> CONFIGURANDO FLATHUB"
    sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo > "flathub.log"

    echo ">> FLATPAK PACKAGES"
    install_flatpak_packages > "flatpak.log"

    echo ">> KITTY"
    install_kitty_terminal > "kitty.log"
    
    echo ">> FZF"
    install_fzf > "fzf.log"
    
    echo ">> ZOXIDE"
    install_zoxide > "zoxide.log"
    
    echo ">> YAZI"
    install_yazi > "yazi.log"
    
    echo ">> TREE SITTER"
    install_tree_sitter > "tree-sitter.log"
    
    echo ">> NVIM"
    install_nvim > "nvim.log"
}

main "$@"

#TODO
#install_flatpak_packages() {
#  local app
#  local apps=(
#    cc.arduino.IDE2
#    com.dropbox.Client
#    com.google.AndroidStudio
#    com.google.Chrome
#    com.valvesoftware.Steam
#    com.visualstudio.code
#    dev.edfloreshz.Calculator
#    dev.edfloreshz.CosmicTweaks
#    dev.mariinkys.Cedilla
#    io.github.kolunmi.Bazaar
#    md.obsidian.Obsidian
#    me.proton.Pass
#    org.gnome.Boxes
#    org.onlyoffice.desktopeditors
#  )
#  for app in "${apps[@]}"; do
#    flatpak install flathub "$app"
#  done
#}