#!/usr/bin/env bash

# Set up this personal desktop environment on Debian-based x86_64 Linux systems.
# Run from any directory: paths are resolved relative to this script.

set -euo pipefail

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

command_exists() { 
    command -v "$1" >/dev/null 2>&1 
}

# Check operational system requirements: Linux, x86_64, apt
validate_environment() {
    if [[ "$(uname -s)" != "Linux" ]]; then
        printf 'This setup supports Linux only.\n' >&2
        return 1
    fi

    if [[ "$(uname -m)" != "x86_64" ]]; then
        printf 'This setup supports x86_64 only.\n' >&2
        return 1
    fi
    
    command_exists apt || {
        printf 'This setup requires apt package manager (a Debian-based distribution).\n' >&2
        return 1
    }
}

install_apt_packages() {
    #imagemagick fd-find fontconfig jq poppler-utils
    local packages=(
        git
        curl
        unzip
        vim
        file
        ffmpeg
        fzf
        zoxide
        xclip
        wl-clipboard
        flatpak
    )

    sudo apt install -y "${packages[@]}"
}

# Perform a backup of given PATH. Include the suffix: ".<DATETIME>.<BACKUP-EXTENSION> - e.g. '.20261024120135.bkp'".
backup_path() {
    local destination="$1"

    if [[ -e "$destination" || -L "$destination" ]]; then
        mv -- "$destination" "${destination}.${START_DATE_TIME:-'old'}.${BACKUP_EXT:-'bkp'}"
    fi
}

# Overwrites given HOME config file or directory by an equivalent config of this repository.
install_config() {
    local relative_path="$1"
    local source="$SCRIPT_DIR/$relative_path"
    local destination="$HOME/$relative_path"

    if [[ ! -e "$source" ]]; then
        printf "Missing source file or directory: '%s'\n" "$source" >&2
        return 1
    fi

    mkdir -p -- "$(dirname -- "$destination")"
    backup_path "$destination"

    if [[ -f "$source" ]]; then
        cp -- "$source" "$destination"
        return 0
    fi

    if [[ -d "$source" ]]; then
        cp -r -- "$source" "$destination"
        return 0
    fi
}

# Install a font located in "$HOME/.local/share/fonts" or given by the second parameter.
install_local_font() {
    local font_name="$1"
    local font_path="${2:-'$SCRIPT_DIR/.local/share/fonts'}"
    local source="$font_path/$font_name"
    local destination="$HOME/.local/share/fonts/$font_name"

    if [[ ! -d "$source" ]]; then
        printf 'Missing local font: %s\n' "$source" >&2
        return 1
    fi

    mkdir -p -- "$(dirname -- "$destination")"
    backup_path "$destination"
    cp -a -- "$source" "$destination"
}

# Install a font from Nerd Fonts [https://github.com/ryanoasis/nerd-fonts].
install_web_font() {
    local file_name="$1"
    local source_url="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${file_name}.zip"
    local destination="$HOME/.local/share/fonts/$file_name"
    local download_path="$(mktemp)"
    local extraction_dir="$(mktemp -d)"

    curl --fail --location "$source_url" --output "$download_path"
    unzip -q -- "$download_path" -d "$extraction_dir"

    backup_path "$destination"
    mkdir -p -- "$destination"
    cp -a -- "$extraction_dir/." "$destination"

    rm -f -- "$download_path"
    rm -rf -- "$extraction_dir"
}

install_kitty() {
    local installer_path="$(mktemp)"
    
    curl --fail --location "https://sw.kovidgoyal.net/kitty/installer.sh" --output "$installer_path"
    sh "$installer_path" launch=n
    rm -f -- "$installer_path"

    ln -sfn -- "$HOME/.local/kitty.app/bin/kitty" "$LOCAL_BIN_DIR/kitty"
    ln -sfn -- "$HOME/.local/kitty.app/bin/kitten" "$LOCAL_BIN_DIR/kitten"

    cp -- "$HOME/.local/kitty.app/share/applications/kitty.desktop" \
        "$HOME/.local/share/applications/kitty.desktop"

    cp -- "$HOME/.local/kitty.app/share/applications/kitty-open.desktop" \
        "$HOME/.local/share/applications/kitty-open.desktop"

    sed -i \
        -e "s|^Icon=kitty$|Icon=$HOME/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png|" \
        "$HOME/.local/share/applications/kitty.desktop" \
        "$HOME/.local/share/applications/kitty-open.desktop"
}

install_neovim() {
    local source_url="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz"
    local install_dir="$HOME/Apps/nvim"
    local download_path="$(mktemp)"
    
    curl --fail --location "$source_url" --output "$download_path"

    backup_path "$install_dir"
    mkdir -p -- "$install_dir"
    tar --extract --gzip --file "$download_path" --strip-components=1 --directory "$install_dir"
    
    ln -sfn -- "$install_dir/bin/nvim" "$LOCAL_BIN_DIR/nvim"

    rm -f -- "$download_path"
}

install_flatpak_packages() {
    local app
    local apps=(
        com.dropbox.Client
        com.google.Chrome
        com.valvesoftware.Steam
        com.visualstudio.code
        dev.edfloreshz.Calculator
        io.github.kolunmi.Bazaar
        me.proton.Pass
        org.onlyoffice.desktopeditors
    )

    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

    for app in "${apps[@]}"; do
        flatpak install --user --noninteractive --or-update flathub "$app"
    done
}

main() {
    print_ascii_art
    validate_environment
    printf 'Installing base packages and dotfiles...\n'

    # Runtime variables.
    START_DATE_TIME="$(date '+%Y%m%d%H%M%S')"
    BACKUP_EXT="bkp"
    SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
    LOCAL_BIN_DIR="$HOME/.local/bin"

    # Create custom home directories.
    mkdir -p -- "$HOME/Apps" "$HOME/Dev" "$HOME/Temp"
    
    # Ensure local bin and desktop launchers folders.
    mkdir -p -- "$LOCAL_BIN_DIR" "$HOME/.local/share/applications"

    # Apt packages.
    install_apt_packages
        
    # Custom fonts.
    install_web_font "SourceCodePro"
    install_web_font "NerdFontsSymbolsOnly"
    fc-cache --force

    # Apps.
    install_kitty
    install_neovim
    install_flatpak_packages

    # Configs.
    install_config ".config/bash"
    install_config ".config/kitty"
    install_config ".config/nvim"
    install_config ".bashrc"
    install_config ".gitconfig"
    install_config ".hidden"

    printf 'Setup finished. Open a new shell to load the Bash configuration.\n'
}

main "$@"