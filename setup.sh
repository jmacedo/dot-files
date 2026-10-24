#!/usr/bin/env bash

# Set up this personal desktop environment on Debian-based x86_64 Linux systems.
# Run from any directory: paths are resolved relative to this script.

set -euo pipefail

readonly KITTY_VERSION="0.49.2"
readonly NEOVIM_VERSION="0.12.6"

initialize_script() {
    declare -gr START_DATE_TIME="$(date '+%Y%m%d%H%M%S')"
    declare -gr BACKUP_EXT="bkp"
    declare -gr SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
    declare -gr LOCAL_BIN_DIR="$HOME/.local/bin"
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

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

backup_path() {
    local destination="$1"

    if [[ -e "$destination" || -L "$destination" ]]; then
        mv -- "$destination" "${destination}.${START_DATE_TIME}.${BACKUP_EXT}"
    fi
}

install_file() {
    local relative_path="$1"
    local source="$SCRIPT_DIR/$relative_path"
    local destination="$HOME/$relative_path"

    [[ -f "$source" ]] || {
        printf 'Missing source file: %s\n' "$source" >&2
        return 1
    }

    mkdir -p -- "$(dirname -- "$destination")"
    backup_path "$destination"
    cp -- "$source" "$destination"
}

install_directory() {
    local relative_path="$1"
    local source="$SCRIPT_DIR/$relative_path"
    local destination="$HOME/$relative_path"

    [[ -d "$source" ]] || {
        printf 'Missing source directory: %s\n' "$source" >&2
        return 1
    }

    mkdir -p -- "$(dirname -- "$destination")"
    backup_path "$destination"
    cp -a -- "$source" "$destination"
}

install_local_font() {
    local font_name="$1"
    local source="$SCRIPT_DIR/.local/share/fonts/$font_name"
    local destination="$HOME/.local/share/fonts/$font_name"

    [[ -d "$source" ]] || {
        printf 'Missing bundled font: %s\n' "$source" >&2
        return 1
    }

    mkdir -p -- "$(dirname -- "$destination")"
    backup_path "$destination"
    cp -a -- "$source" "$destination"
}

install_web_font() {
    local archive_name="$2"
    local source_url="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${archive_name}.zip"
    local destination="$HOME/.local/share/fonts/$archive_name"
    local download_path extraction_dir

    download_path="$(mktemp)"
    extraction_dir="$(mktemp -d)"
    trap 'rm -f -- "$download_path"; rm -rf -- "$extraction_dir"' RETURN

    curl --fail --location "$source_url" --output "$download_path"
    unzip -q -- "$download_path" -d "$extraction_dir"

    backup_path "$destination"
    mkdir -p -- "$destination"
    cp -a -- "$extraction_dir/." "$destination"

    trap - RETURN
    rm -f -- "$download_path"
    rm -rf -- "$extraction_dir"
}

validate_environment() {
    [[ "$(uname -s)" == "Linux" ]] || {
        printf 'This setup supports Linux only.\n' >&2
        return 1
    }

    [[ "$(uname -m)" == "x86_64" ]] || {
        printf 'This setup supports x86_64 only.\n' >&2
        return 1
    }

    command_exists apt || {
        printf 'This setup requires apt (a Debian-based distribution).\n' >&2
        return 1
    }
}

install_apt_packages() {
    local packages=(
        git curl unzip vim file ffmpeg 7zip jq poppler-utils fd-find fontconfig
        fzf zoxide imagemagick xclip wl-clipboard xsel flatpak
    )

    sudo apt install -y "${packages[@]}"
}

install_kitty() {
    local installer_path

    installer_path="$(mktemp)"
    trap 'rm -f -- "$installer_path"' RETURN
    curl --fail --location "https://sw.kovidgoyal.net/kitty/installer.sh" --output "$installer_path"
    sh "$installer_path" launch=n "installer=version-${KITTY_VERSION}"
    trap - RETURN
    rm -f -- "$installer_path"

    mkdir -p -- "$LOCAL_BIN_DIR" "$HOME/.local/share/applications"
    ln -sfn -- "$HOME/.local/kitty.app/bin/kitty" "$LOCAL_BIN_DIR/kitty"
    ln -sfn -- "$HOME/.local/kitty.app/bin/kitten" "$LOCAL_BIN_DIR/kitten"

    cp -- "$HOME/.local/kitty.app/share/applications/kitty.desktop" \
        "$HOME/.local/share/applications/kitty.desktop"
    cp -- "$HOME/.local/kitty.app/share/applications/kitty-open.desktop" \
        "$HOME/.local/share/applications/kitty-open.desktop"

    sed -i \
        -e "s|^Icon=kitty$|Icon=$HOME/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png|" \
        -e "s|^Exec=kitty|Exec=$HOME/.local/kitty.app/bin/kitty|" \
        "$HOME/.local/share/applications/kitty.desktop" \
        "$HOME/.local/share/applications/kitty-open.desktop"
}

install_neovim() {
    local archive="nvim-linux-x86_64.tar.gz"
    local source_url="https://github.com/neovim/neovim/releases/download/v${NEOVIM_VERSION}/${archive}"
    local install_dir="$HOME/Apps/nvim-${NEOVIM_VERSION}"
    local download_path

    download_path="$(mktemp)"
    trap 'rm -f -- "$download_path"' RETURN
    curl --fail --location "$source_url" --output "$download_path"

    backup_path "$install_dir"
    mkdir -p -- "$install_dir"
    tar --extract --gzip --file "$download_path" --strip-components=1 --directory "$install_dir"
    mkdir -p -- "$LOCAL_BIN_DIR"
    ln -sfn -- "$install_dir/bin/nvim" "$LOCAL_BIN_DIR/nvim"
    trap - RETURN
    rm -f -- "$download_path"
}

install_flatpak_packages() {
    local app
    local apps=(
        com.dropbox.Client com.google.Chrome com.valvesoftware.Steam
        com.visualstudio.code dev.edfloreshz.Calculator io.github.kolunmi.Bazaar
        me.proton.Pass org.onlyoffice.desktopeditors
    )

    sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    for app in "${apps[@]}"; do
        sudo flatpak install --system --noninteractive flathub "$app"
    done
}

install_dotfiles() {
    install_directory ".config/bash"
    install_directory ".config/kitty"
    install_directory ".config/nvim"
    install_web_font "SauceCodePro" "SourceCodePro"
    install_web_font "Symbols" "NerdFontsSymbolsOnly"
    install_file ".bashrc"
    install_file ".gitconfig"
    install_file ".hidden"
}

main() {
    local install_flatpaks=false

    case "${1:-}" in
        "") ;;
        --flatpaks) install_flatpaks=true ;;
        -h|--help)
            printf 'Usage: %s [--flatpaks]\n' "${0##*/}"
            return 0
            ;;
        *)
            printf 'Unknown option: %s\n' "$1" >&2
            return 2
            ;;
    esac

    initialize_script
    validate_environment
    print_ascii_art
    printf 'Installing base packages and dotfiles...\n'

    install_apt_packages
    mkdir -p -- "$HOME/Apps" "$HOME/Dev" "$HOME/Temp"
    install_dotfiles
    install_kitty
    install_neovim
    fc-cache --force

    if [[ "$install_flatpaks" == true ]]; then
        install_flatpak_packages
    fi

    printf 'Setup finished. Open a new shell to load the Bash configuration.\n'
}

main "$@"
