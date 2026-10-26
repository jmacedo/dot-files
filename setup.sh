#!/usr/bin/env bash

# Set up this personal desktop environment on Debian-based x86_64 Linux systems.
# Run from any directory: paths are resolved relative to this script.

set -euo pipefail

if [[ -t 1 && -n "${TERM:-}" ]] && command -v clear >/dev/null 2>&1; then
    clear || true
fi

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
    local font_path="${2:-$SCRIPT_DIR/.local/share/fonts}"
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
    local dest=${CUSTOM_USER_APPS_DIR:-$HOME/.local}
    local kitty_folder="$dest/kitty.app"
    
    backup_path "$kitty_folder"
    curl --fail --location "https://sw.kovidgoyal.net/kitty/installer.sh" --output "$installer_path"
    sh "$installer_path" launch=n dest="$dest"
    rm -f -- "$installer_path"
    
    backup_path "$LOCAL_BIN_DIR/kitty"
    backup_path "$LOCAL_BIN_DIR/kitten"
    ln -sfn -- "$kitty_folder/bin/kitty" "$LOCAL_BIN_DIR/kitty"
    ln -sfn -- "$kitty_folder/bin/kitten" "$LOCAL_BIN_DIR/kitten"

    backup_path "$HOME/.local/share/applications/kitty.desktop"
    cp -- "$kitty_folder/share/applications/kitty.desktop" \
        "$HOME/.local/share/applications/kitty.desktop"

    backup_path "$HOME/.local/share/applications/kitty-open.desktop"
    cp -- "$kitty_folder/share/applications/kitty-open.desktop" \
        "$HOME/.local/share/applications/kitty-open.desktop"

    sed -i \
        -e "s|^Icon=kitty$|Icon=$kitty_folder/share/icons/hicolor/256x256/apps/kitty.png|" \
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
        steam-devices
        # LSPs and runtimes available through apt
        clangd
        default-jdk
        golang-go
        pipx
        python3-venv
        php-cli
        composer
    )

    sudo apt install -y "${packages[@]}"
}

install_flatpak_packages() {
    local app
    local apps=(
        com.dropbox.Client
        com.google.Chrome
        com.valvesoftware.Steam
        com.visualstudio.code
        io.github.kolunmi.Bazaar
        me.proton.Pass
        org.onlyoffice.desktopeditors
        org.gnome.gedit
        de.swsnr.turnon
        org.videolan.VLC
    )

    # Apply overrides to the invoking user's Flatpak apps, not root's.
    # Keep access read-only because apps do not need to modify the installation.
    flatpak override --user --filesystem="$FLATPAK_INSTALLATIONS_D:ro"
    flatpak override --user --filesystem="$FLATPAK_CUSTOM_PATH:ro"
    
    # Inside flatpak/installations.d/custom.conf.
    # Change HOME alias in flatpak install path to use current HOME environment variable.
    sed "s|@HOME@|$HOME|g" \
        "$SCRIPT_DIR/etc/flatpak/installations.d/custom.conf" |
        sudo tee "$FLATPAK_INSTALLATIONS_D/custom.conf" >/dev/null

    # Adds flathub to custom installation.
    flatpak remote-add --installation=custom --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

    # Install all pre-defined flatpak apps in a custom path.
    for app in "${apps[@]}"; do
        flatpak install --installation=custom --noninteractive --or-update flathub "$app"
    done
}

# TODO: Verificar a remoção dessa função
install_php_lsp_tools() {
    local tools_dir="$CUSTOM_USER_APPS_DIR/npm-tools"

    mkdir -p -- "$tools_dir"

    npm install \
        --prefix "$tools_dir" \
        --save-exact \
        intelephense
}

install_laravel_lsp() {
    export COMPOSER_HOME="$CUSTOM_USER_APPS_DIR/composer"

    composer global require laravel/lsp

    ln -sfn -- "$COMPOSER_HOME/vendor/bin/laravel-lsp" \
        "$LOCAL_BIN_DIR/laravel-lsp"
}

# Install Node.js version manager.
install_fnm() {
    local installer_path="$(mktemp)"

    curl --fail --location "https://fnm.vercel.app/install" --output "$installer_path"
    bash "$installer_path" --install-dir "$CUSTOM_USER_APPS_DIR/fnm" --skip-shell

    rm -f -- "$installer_path"

    export PATH="$HOME/Apps/fnm:$PATH"
    eval "$(fnm env --use-on-cd --shell bash)"
    fnm install --lts # Node latest version
    fnm default "$(fnm current)" # Make node available by default
}

install_npm_lsp_tools() {
    local tools_dir="$CUSTOM_USER_APPS_DIR/npm-tools"

    mkdir -p -- "$tools_dir"

    npm install \
        --prefix "$tools_dir" \
        --save-exact \
        vscode-langservers-extracted \
        typescript-language-server \
        typescript \
        yaml-language-server \
        bash-language-server \
        vim-language-server \
        awk-language-server \
        dockerfile-language-server-nodejs \
        "@microsoft/compose-language-service" \
        intelephense
}

install_python_lsp_tools() {
    pipx ensurepath
    pipx install basedpyright
}

install_go_lsp_tools() {
    export GOPATH="$CUSTOM_USER_APPS_DIR/go"
    export PATH="$GOPATH/bin:$PATH"

    go install github.com/sqls-server/sqls@latest
}

install_rustup() {
    local installer_path="$(mktemp)"

    export CARGO_HOME="$CUSTOM_USER_APPS_DIR/cargo"
    export RUSTUP_HOME="$CUSTOM_USER_APPS_DIR/rustup"

    curl --fail --location https://sh.rustup.rs --output "$installer_path"
    sh "$installer_path" -y --no-modify-path

    rm -f -- "$installer_path"

    export PATH="$CARGO_HOME/bin:$PATH"
    rustup component add rust-analyzer
}

install_lua_language_server() {
    local release_info
    local archive
    local download_url
    local install_dir="$CUSTOM_USER_APPS_DIR/lua-language-server"
    local download_path
    local extraction_dir

    release_info="$(
        curl --fail --silent --show-error --location \
            "https://api.github.com/repos/LuaLS/lua-language-server/releases/latest" |
            python3 -c '
import json
import sys

release = json.load(sys.stdin)
asset = next(
    asset for asset in release["assets"]
    if asset["name"].endswith("-linux-x64.tar.gz")
)
print(asset["name"], asset["browser_download_url"])
'
    )"

    read -r archive download_url <<< "$release_info"
    download_path="$(mktemp)"
    extraction_dir="$(mktemp -d)"

    curl --fail --location "$download_url" --output "$download_path"
    tar --extract --gzip --file "$download_path" --directory "$extraction_dir"

    backup_path "$install_dir"
    mkdir -p -- "$install_dir"
    cp -a -- "$extraction_dir/." "$install_dir/"
    ln -sfn -- "$install_dir/bin/lua-language-server" \
        "$LOCAL_BIN_DIR/lua-language-server"

    rm -f -- "$download_path"
    rm -rf -- "$extraction_dir"
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
    CUSTOM_USER_APPS_DIR="$HOME/Apps"
    FLATPAK_INSTALLATIONS_D="/etc/flatpak/installations.d"
    FLATPAK_CUSTOM_PATH="$CUSTOM_USER_APPS_DIR/flatpak"

    # Create custom home directories.
    mkdir -p -- "$CUSTOM_USER_APPS_DIR" \
        "$FLATPAK_CUSTOM_PATH" \
        "$LOCAL_BIN_DIR" \
        "$HOME/.local/share/applications" \
        "$HOME/.local/share/zoxide" \
        "$HOME/Dev" \
        "$HOME/Temp"

    sudo mkdir -p -- "$FLATPAK_INSTALLATIONS_D"

    # Apt packages.
    install_apt_packages
    
    # Fnm nodejs version manager
    install_fnm
    install_npm_lsp_tools
    install_python_lsp_tools
    install_go_lsp_tools
    install_rustup
    install_php_lsp_tools # TODO: Excluir?
    install_laravel_lsp
    install_lua_language_server

    # Custom fonts.
    install_web_font "SauceCodePro"
    install_web_font "NerdFontsSymbolsOnly"
    fc-cache --force

    # Apps.
    install_kitty
    install_neovim

    # Configs.
    install_config ".config/bash"
    install_config ".config/kitty"
    install_config ".config/nvim"
    install_config ".bashrc"
    install_config ".gitconfig"
    install_config ".hidden"

    # Conditionally install flatpaks.
    if [[ "${1:-}" != "--no-flatpaks" ]]; then
        install_flatpak_packages
    fi

    printf 'Setup finished. Open a new shell to load the Bash configuration.\n'
}

main "$@"