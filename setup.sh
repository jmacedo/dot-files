#!/usr/bin/env bash

# Set up desktop environment and base apps/packages installations.
# Run from any directory: paths are resolved relative to this script.

# `-u`: nounset - Unset variables raises error. Misspeling variables will not be treated as empty values.
# `-e`: errexit - Exit script on errors.
# `-o pipefail` - Raise errors inside a chain of commands (`cmdA | cmdB | cmdC`) instead of by default use the last command status code.
set -euo pipefail

###

install_kitty() {
    local installer_path="$(mktemp)"
    exclude_temp_path "$installer_path"
    local dest=${CUSTOM_USER_APPS_DIR:-$HOME/.local}
    local kitty_folder="$dest/kitty.app"
    
    backup_path "$kitty_folder"
    backup_path "$LOCAL_BIN_DIR/kitty"
    backup_path "$LOCAL_BIN_DIR/kitten"
    backup_path "$HOME/.local/share/applications/kitty.desktop"
    backup_path "$HOME/.local/share/applications/kitty-open.desktop"

    curl --fail --location "https://sw.kovidgoyal.net/kitty/installer.sh" --output "$installer_path"
    sh "$installer_path" launch=n dest="$dest"
    
    ln -sfn -- "$kitty_folder/bin/kitty" "$LOCAL_BIN_DIR/kitty"
    ln -sfn -- "$kitty_folder/bin/kitten" "$LOCAL_BIN_DIR/kitten"
    
    cp -f -- "$kitty_folder/share/applications/kitty.desktop" "$HOME/.local/share/applications/kitty.desktop"
    cp -f -- "$kitty_folder/share/applications/kitty-open.desktop" "$HOME/.local/share/applications/kitty-open.desktop"

    sed -i \
        -e "s|^Icon=kitty$|Icon=$kitty_folder/share/icons/hicolor/256x256/apps/kitty.png|" \
        "$HOME/.local/share/applications/kitty.desktop" \
        "$HOME/.local/share/applications/kitty-open.desktop"

    return 0
}

install_neovim() {
    local source_url="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz"
    local install_dir="${CUSTOM_USER_APPS_DIR:-}/nvim"
    local download_path="$(mktemp)"
    exclude_temp_path "$download_path"

    backup_path "$install_dir"
    mkdir -p -- "$install_dir"

    curl --fail --location "$source_url" --output "$download_path"

    tar --extract --gzip --file "$download_path" --strip-components=1 --directory "$install_dir"

    ln -sfn -- "$install_dir/bin/nvim" "$LOCAL_BIN_DIR/nvim"

    return 0
}

install_fzf() {
    local release_api_url="https://api.github.com/repos/junegunn/fzf/releases/latest"
    local download_url=""
    local install_dir="$CUSTOM_USER_APPS_DIR/fzf"
    local download_path="$(mktemp)"
    exclude_temp_path "$download_path"
    local extraction_dir="$(mktemp -d)"
    exclude_temp_path "$extraction_dir"

    backup_path "$LOCAL_BIN_DIR/fzf"
    backup_path "$install_dir"
    mkdir -p -- "$install_dir"

    download_url="$(
        curl --fail --silent --show-error --location --header "Accept: application/vnd.github+json" \
            "$release_api_url" | jq -r '.assets[].browser_download_url | select(endswith("linux_amd64.tar.gz"))'
    )"

    curl --fail --location "$download_url" --output "$download_path"
    tar --extract --gzip --file "$download_path" --directory "$extraction_dir"

    if [[ ! -x "$extraction_dir/fzf" ]]; then
        printf 'Missing fzf binary in release asset: %s\n' "$download_url" >&2
        return 1
    fi

    install --mode=0755 -- "$extraction_dir/fzf" "$install_dir/fzf"

    ln -sfn -- "$install_dir/fzf" "$LOCAL_BIN_DIR/fzf"

    return 0
}

install_lazygit() {
    local release_api_url="https://api.github.com/repos/jesseduffield/lazygit/releases/latest"
    local install_dir="$CUSTOM_USER_APPS_DIR/lazygit"
    local download_url=""
    local download_path="$(mktemp)"
    exclude_temp_path "$download_path"
    local extraction_dir="$(mktemp -d)"
    exclude_temp_path "$extraction_dir"

    backup_path "$LOCAL_BIN_DIR/lazygit"
    backup_path "$install_dir"
    mkdir -p -- "$install_dir"

    download_url="$(
        curl --fail --silent --show-error --location --header "Accept: application/vnd.github+json" \
            "$release_api_url" | jq -r '.assets[].browser_download_url | select(endswith("linux_x86_64.tar.gz"))'
    )"

    curl --fail --location "$download_url" --output "$download_path"
    tar --extract --gzip --file "$download_path" --directory "$extraction_dir"

    if [[ ! -x "$extraction_dir/lazygit" ]]; then
        printf 'Missing lazygit binary in release asset: %s\n' "$download_url" >&2
        return 1
    fi

    install --mode=0755 -- "$extraction_dir/lazygit" "$install_dir/lazygit"

    ln -sfn -- "$install_dir/lazygit" "$LOCAL_BIN_DIR/lazygit"

    return 0
}

install_yazi() {
    local release_api_url="https://api.github.com/repos/sxyazi/yazi/releases/latest"
    local install_dir="$CUSTOM_USER_APPS_DIR/yazi"
    local download_url=""
    local download_path="$(mktemp)"
    exclude_temp_path "$download_path"
    local extraction_dir="$(mktemp -d)"
    exclude_temp_path "$extraction_dir"

    backup_path "$LOCAL_BIN_DIR/yazi"
    backup_path "$install_dir"
    mkdir -p -- "$install_dir"

    download_url="$(
        curl --fail --silent --show-error --location --header "Accept: application/vnd.github+json" \
            "$release_api_url" | jq -r '.assets[].browser_download_url | select(test("x86_64-.*linux-gnu\\.zip$"))'
    )"

    curl --fail --location "$download_url" --output "$download_path"

    unzip -q "$download_path" -d "$extraction_dir"
    
    cp -a -- "$extraction_dir"/yazi-*/. "$install_dir"

    ln -sfn -- "$install_dir/yazi" "$LOCAL_BIN_DIR/yazi"

    return 0
}

install_treesitter() {
    local release_api_url="https://api.github.com/repos/tree-sitter/tree-sitter/releases/latest"
    local install_dir="$CUSTOM_USER_APPS_DIR/tree-sitter"
    local download_url
    local download_path="$(mktemp)"
    exclude_temp_path "$download_path"
    local extraction_dir="$(mktemp -d)"
    exclude_temp_path "$extraction_dir"

    backup_path "$LOCAL_BIN_DIR/tree-sitter"
    backup_path "$install_dir"
    mkdir -p -- "$install_dir"

    download_url="$(
        curl --fail --silent --show-error --location --header "Accept: application/vnd.github+json" \
            "$release_api_url" | jq -r '.assets[].browser_download_url | select(endswith("linux-x64.zip"))'
    )"

    curl --fail --location "$download_url" --output "$download_path"
    unzip -q -- "$download_path" -d "$extraction_dir"

    if [[ ! -x "$extraction_dir/tree-sitter" ]]; then
        printf 'Missing tree-sitter binary in release asset: %s\n' "$download_url" >&2
        return 1
    fi

    install --mode=0755 -- "$extraction_dir/tree-sitter" "$install_dir/tree-sitter"

    ln -sfn -- "$install_dir/tree-sitter" "$LOCAL_BIN_DIR/tree-sitter"

    return 0
}

install_zoxide() {
    local install_url="https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh"
    local install_dir="$CUSTOM_USER_APPS_DIR/zoxide"
    local installer_path="$(mktemp)"
    exclude_temp_path "$installer_path"

    backup_path "$install_dir"
    mkdir -p -- "$install_dir"

    curl --fail --location "$install_url" --output "$installer_path"
    bash "$installer_path" --bin-dir "$install_dir"

    ln -sf -- "$install_dir/zoxide" "$LOCAL_BIN_DIR/zoxide"

    return 0
}

install_superfile() {
    local release_api_url="https://api.github.com/repos/yorukot/superfile/releases/latest"
    local install_dir="$CUSTOM_USER_APPS_DIR/superfile"
    local download_url=""
    local download_path="$(mktemp)"
    exclude_temp_path "$download_path"
    local extraction_dir="$(mktemp -d)"
    exclude_temp_path "$extraction_dir"
    local binary_path=""

    backup_path "$LOCAL_BIN_DIR/spf"
    backup_path "$install_dir"
    mkdir -p -- "$install_dir"

    download_url="$(
        curl --fail --silent --show-error --location --header "Accept: application/vnd.github+json" \
            "$release_api_url" | jq -r '.assets[].browser_download_url | select(test("superfile-linux-.*-amd64\\.tar\\.gz$"))'
    )"

    curl --fail --location "$download_url" --output "$download_path"

    tar --extract --gzip --file "$download_path" --directory "$extraction_dir"
    binary_path="$(find "$extraction_dir" -type f -name spf -print -quit)"
    
    if [[ -z "$binary_path" || ! -f "$binary_path" ]]; then
        printf 'Missing spf binary in release asset: %s\n' "$download_url" >&2
        return 1
    fi

    install --mode=0755 -- "$binary_path" "$install_dir/spf"

    ln -sfn -- "$install_dir/spf" "$LOCAL_BIN_DIR/spf"

    return 0
}

install_fnm() {
    local install_dir="$CUSTOM_USER_APPS_DIR/fnm"
    local installer_path="$(mktemp)"
    exclude_temp_path "$installer_path"

    backup_path "$install_dir"
    mkdir -p -- "$install_dir"

    curl --fail --location "https://fnm.vercel.app/install" --output "$installer_path"
    bash "$installer_path" --install-dir "$install_dir" --skip-shell

    # Configure fnm just for now and install NODEJS.
    export PATH="$HOME/Apps/fnm:$PATH"
    eval "$(fnm env --use-on-cd --shell bash)"
    fnm install --latest # Node LATEST version. (Long Term Support: `--lts` or, Latest release: `--latest`)
    fnm default "$(fnm current)" # Make node available by default.

    return 0
}

install_python_lsp_tools() {
    pipx ensurepath
    pipx install basedpyright

    return 0
}

install_go_lsp_tools() {
    export GOPATH="$CUSTOM_USER_APPS_DIR/go"
    export PATH="$GOPATH/bin:$PATH"

    go install github.com/sqls-server/sqls@latest

    return 0
}

install_rustup() {
    local installer_path="$(mktemp)"
    exclude_temp_path "$installer_path"

    backup_path "$CUSTOM_USER_APPS_DIR/cargo"
    backup_path "$CUSTOM_USER_APPS_DIR/rustup"
    mkdir -p -- "$CUSTOM_USER_APPS_DIR/cargo" "$CUSTOM_USER_APPS_DIR/rustup"

    export CARGO_HOME="$CUSTOM_USER_APPS_DIR/cargo"
    export RUSTUP_HOME="$CUSTOM_USER_APPS_DIR/rustup"
    curl --fail --location https://sh.rustup.rs --output "$installer_path"
    sh "$installer_path" -y --no-modify-path

    export PATH="$CARGO_HOME/bin:$PATH"
    rustup component add rust-analyzer

    return 0
}

install_laravel_lsp() {
    export COMPOSER_HOME="$CUSTOM_USER_APPS_DIR/composer"

    composer global require laravel/lsp

    ln -sfn -- "$COMPOSER_HOME/vendor/bin/laravel-lsp" \
        "$LOCAL_BIN_DIR/laravel-lsp"

    return 0
}

###

handle_parameters() {
    #if [[ $# -eq 0 ]]; then ### fi

    for parameter in "$@"; do
        case "$parameter" in
            --no-flatpaks)
                ;;
            --update|--upgrade)
                ;;
            --reset-dot-files|--reset)
                ;;
            --remove-installations-backups|--remove-backups)
                ;;
            --help|--h|-h|help)
                local option_help_text=""
                for i in {1..5}; do
                    option_help_text="$option_help_text%s:\n%s\n\n"
                done

                printf "Usage: %s [options]\nAvailable options:\n$option_help_text" \
                    $0 \
                    "--no-flatpaks" \
                    "Do not install any flatpak app." \
                    "--update|--upgrade" \
                    "Only install softwares overriding existing and do not write any configuration." \
                    "--reset-dot-files|--reset" \
                    "Just overrides the dot files and configurations" \
                    "--remove-installations-backup|--remove-backups" \
                    "Removes all \`<DATETIME>.bkp\` created by this script during installations." \
                    "--help|--h|-h|help" \
                    "Show this help and exit."
                exit 0
                ;;
            *)
                printf "Unknown parameter: %s" $parameter >&2
                printf "Use '%s --help'." $0 >&2
                exit 1
                ;;
        esac
    done

    return 0
}

main_install() {
    local apt_packages=(
        "git"
        "curl"
        "unzip"
        "vim"
        "file"
        "ffmpeg"
        "xclip"
        "wl-clipboard"
        "flatpak"
        "steam-devices"
        "build-essential"
        "gparted"
        "ca-certificates"
        "jq"
        "ripgrep"
        # LSPs and runtimes available through apt
        "clangd"
        "default-jdk"
        "golang-go"
        "pipx"
        "python3-venv"
        "php-cli"
        "composer"
    )
    install_apt_packages apt_packages
    
    # Nodejs and npm packages.
    #POST_GITHUB_INSTALL_COMMANDS=()
    #POST_GITHUB_INSTALL_COMMANDS+=("export PATH='$HOME/Apps/fnm:$PATH'")
    #POST_GITHUB_INSTALL_COMMANDS+=("eval '$(fnm env --use-on-cd --shell bash)'")
    #POST_GITHUB_INSTALL_COMMANDS+=("fnm install --latest") # Node LATEST version. (Long Term Support: `--lts` or, Latest release: `--latest`)
    #POST_GITHUB_INSTALL_COMMANDS+=("fnm default '$(fnm current)'") # Make node available by default.
    #POST_GITHUB_INSTALL_COMMANDS+=("backup_path '$CUSTOM_USER_APPS_DIR/npm-tools'")
    #POST_GITHUB_INSTALL_COMMANDS+=("mkdir -p -- '$CUSTOM_USER_APPS_DIR/npm-tools'")
    #POST_GITHUB_INSTALL_COMMANDS+=("npm install --prefix '$CUSTOM_USER_APPS_DIR/npm-tools' --save-exact vscode-langservers-extracted typescript-language-server typescript yaml-language-server bash-language-server vim-language-server awk-language-server dockerfile-language-server-nodejs '@microsoft/compose-language-service' intelephense")
    #install_bin_from_github "fnm" "Schniz/fnm"
    
    # Python LSP tools.
    #install_python_lsp_tools

    # Go LSP tools.
    #install_go_lsp_tools

    # Rustup and rust analyzer.
    #install_rustup

    # Laravel LSP.
    #install_laravel_lsp

    # Lua LSP.
    #POST_GITHUB_INSTALL_COMMANDS=()
    #install_bin_from_github "lua-language-server" "LuaLS/lua-language-server"

    # Kitty terminal.
    POST_GITHUB_INSTALL_COMMANDS=()
    POST_GITHUB_INSTALL_COMMANDS=("cp -f -- '$kitty_folder/share/applications/kitty.desktop' '$HOME/.local/share/applications/kitty.desktop'")
    POST_GITHUB_INSTALL_COMMANDS=("cp -f -- '$kitty_folder/share/applications/kitty-open.desktop' '$HOME/.local/share/applications/kitty-open.desktop'")
    POST_GITHUB_INSTALL_COMMANDS=('sed -i -e "s|^Icon=kitty$|Icon=$kitty_folder/share/icons/hicolor/256x256/apps/kitty.png|" "$HOME/.local/share/applications/kitty.desktop" "$HOME/.local/share/applications/kitty-open.desktop"')
    install_bin_from_github "kitty" "kovidgoyal/kitty"

    # NeoVim editor.
    POST_GITHUB_INSTALL_COMMANDS=()
    install_bin_from_github "neovim" "neovim/neovim"

    # fzf: Fuzzy finder.
    POST_GITHUB_INSTALL_COMMANDS=()
    install_bin_from_github "fzf" "junegunn/fzf"

    # Lazy git.
    POST_GITHUB_INSTALL_COMMANDS=()
    install_bin_from_github "lazygit" "jesseduffield/lazygit"

    # Tree-sitter cli.
    POST_GITHUB_INSTALL_COMMANDS=()
    install_bin_from_github "tree-sitter" "tree-sitter/tree-sitter"

    # Zoxide navigator.
    POST_GITHUB_INSTALL_COMMANDS=()
    install_bin_from_github "zoxide" "ajeetdsouza/zoxide"

    # Yazi file explorer.
    POST_GITHUB_INSTALL_COMMANDS=()
    install_bin_from_github "yazi" "sxyazi/yazi"

    # Superfile file explorer.
    POST_GITHUB_INSTALL_COMMANDS=()
    install_bin_from_github "spf" "yorukot/superfile"

    # Docker.
    install_docker

    # Custom fonts.
    install_web_font "SourceCodePro"
    install_web_font "NerdFontsSymbolsOnly"
    fc-cache --force
    
    return 0
}

install_docker() {
    local apt_source_template="${SCRIPT_DIR:-$HOME}/.config/docker/docker.sources"
    local apt_source_temp="$(mktemp)"
    exclude_temp_path "$apt_source_temp"

    sudo apt remove $(dpkg --get-selections docker.io docker-compose docker-compose-v2 docker-doc docker-buildx podman-docker containerd runc | cut -f1)
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    sed -e "s|@@CODE_NAME@@|$(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")|g" \
        -e "s|@@ARCHITECTURE@@|$(dpkg --print-architecture)|g" \
        "$apt_source_template" > "$apt_source_temp"
    
    sudo cp -f -- "$apt_source_temp" /etc/apt/sources.list.d/docker.sources
    
    sudo apt update
    sudo apt install -y \
        docker-ce \
        docker-ce-cli \
        containerd.io \
        docker-buildx-plugin \
        docker-compose-plugin \
        docker-sbx

    sudo groupadd docker
    sudo usermod -aG docker $USER
    newgrp docker
    sudo chown "$USER":"$USER" /home/"$USER"/.docker -R
    sudo chmod g+rwx "$HOME/.docker" -R

    docker run hello-world

    sudo systemctl enable docker.service
    sudo systemctl enable containerd.service

    # Verify KVM for docker sandboxes for AI
    if ! has_kvm; then
        printf "Docker needs KVM to be loaded to build AI sandboxes.\n See %s --help\n" "$0"
        return 1
    fi
    sudo usermod -aG kvm $USER
    newgrp kvm

    # Authenticate docker
    sbx login

    return 0
}

main_configs() {
    install_config ".config/bash"
    install_config ".config/kitty"
    install_config ".config/nvim"
    install_config ".config/fzf"
    install_config ".config/lazygit"
    install_config ".config/yazi"
    install_config ".config/superfile"
    install_config ".bashrc"
    install_config ".gitconfig"
    install_config ".gitconfig.local.example"
    install_config ".gitignore"
    install_config ".hidden"

    return 0
}

main_flatpaks() {
    local apps=(
        "com.dropbox.Client"
        "com.google.Chrome"
        "com.valvesoftware.Steam"
        "com.visualstudio.code"
        "io.github.kolunmi.Bazaar"
        "org.onlyoffice.desktopeditors"
        "org.gnome.gedit"
        "de.swsnr.turnon"
        "org.videolan.VLC"
    )

    install_flatpak_remote_flathub
    install_flatpak_packages apps
    override_pop_os_flatpak_launchers

    return 0
}

# On PopOS 24.04, some flatpak apps bugged to launch.
# This function configure a work-around to fix it.
override_pop_os_flatpak_launchers() {
    # Google Chrome launcher (run as X11).
    cp -f -- "$SCRIPT_DIR/.config/desktop-launchers/com.google.Chrome.desktop" "$HOME/.local/share/applications"

    # VS Code launcher (run without gpu aceleration).
    cp -f -- "$SCRIPT_DIR/.config/desktop-launchers/com.visualstudio.code.desktop" "$HOME/.local/share/applications"

    return 0
}

main() {
    # Runtime variables.
    local START_DATE_TIME="$(date '+%Y%m%d%H%M%S')" # AAAAMMDDHHMMSS
    local BACKUP_EXT="bkp"
    local SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)" # Absolute path
    local LOCAL_BIN_DIR="$HOME/.local/bin"
    local CUSTOM_USER_APPS_DIR="$HOME/Apps"
    local LOCAL_SHARE="$HOME/.local/share"
    
    source "$SCRIPT_DIR/src/bash-lib.sh"

    handle_parameters "$@"

    command clear

    mkdir -p -- "$CUSTOM_USER_APPS_DIR" \
        "$LOCAL_BIN_DIR" \
        "$LOCAL_SHARE" \
        "$LOCAL_SHARE/flatpak" \
        "$LOCAL_SHARE/applications" \
        "$LOCAL_SHARE/zoxide" \
        "$HOME/Dev" \
        "$HOME/Temp" \
        "$HOME/.docker"

    main_install
    main_configs
    main_flatpaks

    echo "Finish!"
}

CLEANUP_PATHS=()
POST_GITHUB_INSTALL_COMMANDS=()
trap cleanup_temp_paths EXIT
main "$@"