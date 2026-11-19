#!/usr/bin/env bash

# Set up desktop environment and base apps/packages installations.
# Run from any directory: paths are resolved relative to this script.

# `-u`: nounset - Unset variables raises error. Misspeling variables will not be treated as empty values.
# `-e`: errexit - Exit script on errors.
# `-o pipefail` - Raise errors inside a chain of commands (`cmdA | cmdB | cmdC`) instead of by default use the last command status code.
set -euo pipefail

# Perform a backup of given PATH. Include the suffix `.<datetime>.<backup_extension>` - e.g. `~/custom_path` -> `~/custom_path.20261024120135.bkp`.
backup_path() {
    local destination="${1:-}"

    if [[ -e "$destination" || -L "$destination" ]]; then
        mv -f -- "$destination" "$destination.${START_DATE_TIME:-'old'}.bkp"
    fi
}

# Overwrites given HOME config file or directory by an equivalent config of this repository.
install_config() {
    local relative_path="${1:-}"
    local source="${SCRIPT_DIR:-$HOME}/$relative_path"
    local destination="$HOME/$relative_path"

    if [[ ! -e "$source" ]]; then
        printf "Missing source file or directory: '%s'\n" "$source" >&2
        return 1
    fi

    mkdir -p -- "$(dirname -- "$destination")"
    backup_path "$destination"

    if [[ -f "$source" ]]; then
        cp -f -- "$source" "$destination"
        return 0
    fi

    if [[ -d "$source" ]]; then
        cp -rf -- "$source" "$destination"
        return 0
    fi
}

# Install a font located in `dot-files/.local/share/fonts` or located in the path of second parameter.
# Default searches in `$SCRIPT_DIR/.local/share/fonts`
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
# Default installs into `$HOME/.local/share/fonts/$file_name`.
install_web_font() {
    local file_name="$1"
    local source_url="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${file_name}.zip"
    local destination="$HOME/.local/share/fonts/$file_name"
    local download_path="$(mktemp)"
    local extraction_dir="$(mktemp -d)"

    # Download and extract.
    curl --fail --location "$source_url" --output "$download_path"
    unzip -q -- "$download_path" -d "$extraction_dir"

    # Bakcup and copy
    backup_path "$destination"
    mkdir -p -- "$destination"
    cp -a -- "$extraction_dir/." "$destination"

    # Clean up
    rm -f -- "$download_path"
    rm -rf -- "$extraction_dir"
}

# Kitty terminal emulator.
install_kitty() {
    local installer_path="$(mktemp)"
    local dest=${CUSTOM_USER_APPS_DIR:-$HOME/.local}
    local kitty_folder="$dest/kitty.app"
    
    # Backup old, download and install.
    backup_path "$kitty_folder"
    curl --fail --location "https://sw.kovidgoyal.net/kitty/installer.sh" --output "$installer_path"
    sh "$installer_path" launch=n dest="$dest"
    rm -f -- "$installer_path"
    
    # Handle binaries
    backup_path "$LOCAL_BIN_DIR/kitty"
    backup_path "$LOCAL_BIN_DIR/kitten"
    ln -sfn -- "$kitty_folder/bin/kitty" "$LOCAL_BIN_DIR/kitty"
    ln -sfn -- "$kitty_folder/bin/kitten" "$LOCAL_BIN_DIR/kitten"

    # Desktop launcher integration.
    backup_path "$HOME/.local/share/applications/kitty.desktop"
    cp -f -- "$kitty_folder/share/applications/kitty.desktop" \
        "$HOME/.local/share/applications/kitty.desktop"

    backup_path "$HOME/.local/share/applications/kitty-open.desktop"
    cp -- "$kitty_folder/share/applications/kitty-open.desktop" \
        "$HOME/.local/share/applications/kitty-open.desktop"

    # Desktop launcher integration icon.
    sed -i \
        -e "s|^Icon=kitty$|Icon=$kitty_folder/share/icons/hicolor/256x256/apps/kitty.png|" \
        "$HOME/.local/share/applications/kitty.desktop" \
        "$HOME/.local/share/applications/kitty-open.desktop"
}

# Nvim text editor.
install_neovim() {
    local source_url="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz"
    local install_dir="${CUSTOM_USER_APPS_DIR:-}/nvim"
    local download_path="$(mktemp)"

    # Download and copy files.    
    curl --fail --location "$source_url" --output "$download_path"
    backup_path "$install_dir"
    mkdir -p -- "$install_dir"
    tar --extract --gzip --file "$download_path" --strip-components=1 --directory "$install_dir"
    rm -f -- "$download_path"

    # Handle binaries.
    ln -sfn -- "$install_dir/bin/nvim" "$LOCAL_BIN_DIR/nvim"
}

# FZF fuzzy finder from the latest stable official GitHub release.
install_fzf() {
    local release_api_url="https://api.github.com/repos/junegunn/fzf/releases/latest"
    local release_info
    local download_url
    local download_path
    local extraction_dir
    local install_dir="$CUSTOM_USER_APPS_DIR/fzf"

    # Download and extract.
    download_url="$(
        curl --fail --silent --show-error --location --header "Accept: application/vnd.github+json" \
            "$release_api_url" | jq -r '.assets[].browser_download_url | select(endswith("linux_amd64.tar.gz"))'
    )"

    download_path="$(mktemp)"
    extraction_dir="$(mktemp -d)"

    curl --fail --location "$download_url" --output "$download_path"
    tar --extract --gzip --file "$download_path" --directory "$extraction_dir"
    rm -f -- "$download_path" # Clean up

    if [[ ! -x "$extraction_dir/fzf" ]]; then
        printf 'Missing fzf binary in release asset: %s\n' "$download_url" >&2
        return 1
    fi

    # Handle binary.
    backup_path "$install_dir"
    mkdir -p -- "$install_dir"
    
    install --mode=0755 -- "$extraction_dir/fzf" "$install_dir/fzf"
    rm -rf -- "$extraction_dir" # Clean up

    backup_path "$LOCAL_BIN_DIR/fzf"
    ln -sfn -- "$install_dir/fzf" "$LOCAL_BIN_DIR/fzf"
}

install_lazygit() {
    local release_api_url="https://api.github.com/repos/jesseduffield/lazygit/releases/latest"
    local release_info
    local download_url
    local download_path
    local extraction_dir
    local install_dir="$CUSTOM_USER_APPS_DIR/lazygit"

    # Download and extract.
    download_url="$(
        curl --fail --silent --show-error --location --header "Accept: application/vnd.github+json" \
            "$release_api_url" | jq -r '.assets[].browser_download_url | select(endswith("linux_x86_64.tar.gz"))'
    )"

    download_path="$(mktemp)"
    extraction_dir="$(mktemp -d)"

    curl --fail --location "$download_url" --output "$download_path"
    tar --extract --gzip --file "$download_path" --directory "$extraction_dir"
    rm -f -- "$download_path" # Clean up

    if [[ ! -x "$extraction_dir/lazygit" ]]; then
        printf 'Missing lazygit binary in release asset: %s\n' "$download_url" >&2
        return 1
    fi

    # Handle binary.
    backup_path "$install_dir"
    mkdir -p -- "$install_dir"
    
    install --mode=0755 -- "$extraction_dir/lazygit" "$install_dir/lazygit"
    rm -rf -- "$extraction_dir" # Clean up

    backup_path "$LOCAL_BIN_DIR/lazygit"
    ln -sfn -- "$install_dir/lazygit" "$LOCAL_BIN_DIR/lazygit"
}

install_yazi() {
    local release_api_url="https://api.github.com/repos/sxyazi/yazi/releases/latest"
    local release_info
    local download_url
    local download_path
    local extraction_dir
    local install_dir="$CUSTOM_USER_APPS_DIR/yazi"

    # Download and extract.
    download_url="$(
        curl --fail --silent --show-error --location --header "Accept: application/vnd.github+json" \
            "$release_api_url" | jq -r '.assets[].browser_download_url | select(test("x86_64-.*linux-gnu\\.zip$"))'
    )"

    download_path="$(mktemp)"
    extraction_dir="$(mktemp -d)"

    curl --fail --location "$download_url" --output "$download_path"
    unzip -qj -- "$download_path" -d "$extraction_dir"
    rm -f -- "$download_path" # Clean up

    if [[ ! -x "$extraction_dir/yazi" ]]; then
        printf 'Missing yazi binary in release asset: %s\n' "$download_url" >&2
        return 1
    fi

    # Handle binary.
    backup_path "$install_dir"
    mkdir -p -- "$install_dir"
    
    cp -a -- "$extraction_dir/yazi-*/." "$install_dir"
    rm -rf -- "$extraction_dir" # Clean up

    backup_path "$LOCAL_BIN_DIR/yazi"
    ln -sfn -- "$install_dir/yazi" "$LOCAL_BIN_DIR/yazi"
}

install_treesitter() {
    local release_api_url="https://api.github.com/repos/tree-sitter/tree-sitter/releases/latest"
    local release_info
    local download_url
    local download_path
    local extraction_dir
    local install_dir="$CUSTOM_USER_APPS_DIR/tree-sitter"

    # Download and extract.
    download_url="$(
        curl --fail --silent --show-error --location --header "Accept: application/vnd.github+json" \
            "$release_api_url" | jq -r '.assets[].browser_download_url | select(endswith("linux-x64.zip"))'
    )"

    download_path="$(mktemp)"
    extraction_dir="$(mktemp -d)"

    curl --fail --location "$download_url" --output "$download_path"
    unzip -q -- "$download_path" -d "$extraction_dir"
    rm -f -- "$download_path" # Clean up

    if [[ ! -x "$extraction_dir/tree-sitter" ]]; then
        printf 'Missing tree-sitter binary in release asset: %s\n' "$download_url" >&2
        return 1
    fi

    # Handle binary.
    backup_path "$install_dir"
    mkdir -p -- "$install_dir"
    
    install --mode=0755 -- "$extraction_dir/tree-sitter" "$install_dir/lazygit"
    rm -rf -- "$extraction_dir" # Clean up

    backup_path "$LOCAL_BIN_DIR/tree-sitter"
    ln -sfn -- "$install_dir/tree-sitter" "$LOCAL_BIN_DIR/tree-sitter"
}

install_apt_packages() {
    local packages=(
        git
        curl
        unzip
        vim
        file
        ffmpeg
        zoxide
        xclip
        wl-clipboard
        flatpak
        steam-devices
        build-essential
        gparted
        ca-certificates
        jq
        ripgrep
        # LSPs and runtimes available through apt
        clangd
        default-jdk
        golang-go
        pipx
        python3-venv
        php-cli
        composer
    )

    sudo apt update -y
    sudo apt upgrade -y
    sudo apt autoremove -y
    sudo apt autoclean
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
        org.onlyoffice.desktopeditors
        org.gnome.gedit
        de.swsnr.turnon
        org.videolan.VLC
    )

    # Flatpak remote to flathub [https://flathub.org]
    flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

    # Install Apps
    for app in "${apps[@]}"; do
        flatpak install --user --noninteractive --or-update flathub "$app"
    done
}

# Verify if KVM module is loaded in kernel.
has_kvm() {
    while read -r module _; do
        case "$module" in
            kvm|kvm_intel|kvm_amd)
                return 0
                ;;
        esac
    done < /proc/modules
    
    return 1
}

install_docker() {
    # Remove conflicting packages
    sudo apt remove $(dpkg --get-selections docker.io docker-compose docker-compose-v2 docker-doc docker-buildx podman-docker containerd runc | cut -f1)
    
    # Add Docker's official GPG key:
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    # Add the repository to Apt sources:
    sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

    # Install docker packages
    sudo apt update
    sudo apt install -y \
        docker-ce \
        docker-ce-cli \
        containerd.io \
        docker-buildx-plugin \
        docker-compose-plugin \
        docker-sbx

    # Docker without `sudo`
    sudo groupadd docker
    sudo usermod -aG docker $USER
    newgrp docker
    sudo chown "$USER":"$USER" /home/"$USER"/.docker -R
    sudo chmod g+rwx "$HOME/.docker" -R

    # Test docker
    docker run hello-world

    # Docker service: enable auto start
    sudo systemctl enable docker.service
    sudo systemctl enable containerd.service

    # DOCKER SANDBOXES FOR AI

    # Handle KVM stuff.
    if ! has_kvm; then
        printf "Docker needs KVM to be loaded to build AI sandboxes.\n See %s --help\n" "$0"
        return 1
    fi
    sudo usermod -aG kvm $USER
    newgrp kvm

    # Authenticate docker
    sbx login
}

# Fnm: nodejs version manager.
install_fnm() {
    local installer_path="$(mktemp)"

    # Download and install.
    curl --fail --location "https://fnm.vercel.app/install" --output "$installer_path"
    bash "$installer_path" --install-dir "$CUSTOM_USER_APPS_DIR/fnm" --skip-shell
    rm -f -- "$installer_path" # Clean up

    # Configure fnm just for now and install NODEJS.
    export PATH="$HOME/Apps/fnm:$PATH"
    eval "$(fnm env --use-on-cd --shell bash)"
    fnm install --latest # Node LATEST version. (Long Term Support: `--lts` or, Latest release: `--latest`)
    fnm default "$(fnm current)" # Make node available by default.
}

install_zoxide() {
    local installer_path="$(mktemp)"
    local install_url="https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh"
    local install_dir="$CUSTOM_USER_APPS_DIR/zoxide"

    backup_path "$install_dir"
    mkdir -p -- "$install_dir"

    curl --fail --location "$install_url" --output "$installer_path"
    bash "$installer_path" --bin-dir "$install_dir"
    rm -f -- "$installer_path" # Clean up
}

install_superfile() {
    bash -c "$(curl -sLo- https://superfile.dev/install.sh)"
}

# Laravel language server for nvim.
install_laravel_lsp() {
    export COMPOSER_HOME="$CUSTOM_USER_APPS_DIR/composer"

    composer global require laravel/lsp

    ln -sfn -- "$COMPOSER_HOME/vendor/bin/laravel-lsp" \
        "$LOCAL_BIN_DIR/laravel-lsp"
}

# LSP servers installations from `npm`.
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

# Rust lsp tools.
install_rustup() {
    local installer_path="$(mktemp)"

    # Download and install rustup.
    export CARGO_HOME="$CUSTOM_USER_APPS_DIR/cargo"
    export RUSTUP_HOME="$CUSTOM_USER_APPS_DIR/rustup"
    curl --fail --location https://sh.rustup.rs --output "$installer_path"
    sh "$installer_path" -y --no-modify-path

    # Clean up
    rm -f -- "$installer_path"

    # Install rust language server.
    export PATH="$CARGO_HOME/bin:$PATH"
    rustup component add rust-analyzer
}

install_lua_language_server() {
    local download_url=""
    local install_dir="$CUSTOM_USER_APPS_DIR/lua-language-server"
    local download_path="$(mktemp)"
    local extraction_dir="$(mktemp -d)"
    local release_api_url="https://api.github.com/repos/LuaLS/lua-language-server/releases/latest"

    # Download and extract.
    download_url="$(
        curl --fail --silent --show-error --location --header "Accept: application/vnd.github+json" \
            "$release_api_url" | jq -r '.assets[].browser_download_url | select(endswith("linux-x64.tar.gz"))'
    )"

    curl --fail --location "$download_url" --output "$download_path"
    tar --extract --gzip --file "$download_path" --directory "$extraction_dir"

    # Backup and install.
    backup_path "$install_dir"
    mkdir -p -- "$install_dir"
    cp -a -- "$extraction_dir/." "$install_dir/"

   # Clean up.
    rm -f -- "$download_path"
    rm -rf -- "$extraction_dir"

    # Handle binary.
    ln -sfn -- "$install_dir/bin/lua-language-server" \
        "$LOCAL_BIN_DIR/lua-language-server"
}

# On PopOS 24.04, some flatpak apps bugged to launch.
# This function configure a work-around to fix it.
override_pop_os_flatpak_launchers() {
    # Google Chrome launcher (run as X11).
    cat > "$HOME/.local/share/applications/com.google.Chrome.desktop" <<'EOF'
[Desktop Entry]
Name=Google Chrome
Exec=flatpak run --user com.google.Chrome --ozone-platform=x11 %U
Icon=com.google.Chrome
Type=Application
Categories=Network;WebBrowser;
StartupWMClass=google-chrome
EOF

    # VS Code launcher (run without gpu aceleration).
    cat > "$HOME/.local/share/applications/com.visualstudio.code.desktop" <<'EOF'
[Desktop Entry]
Name=Visual Studio Code
Exec=flatpak run --user com.visualstudio.code --disable-gpu %F
Icon=com.visualstudio.code
Type=Application
Categories=TextEditor;Development;IDE;
StartupWMClass=Code
EOF
}

handle_parameters() {
    run_no_flatpaks=$NULL
    run_reset=$FALSE
    run_update=$FALSE
    run_remove_backups=$FALSE
    run_full_install=$FALSE

    if [[ $# -eq 0 ]]; then
        run_full_install=$TRUE
    fi

    for parameter in $@; do
        case "$parameter" in
            --no-flatpaks)
                run_no_flatpaks=$TRUE
                ;;
            --update|--upgrade)
                run_update=$TRUE
                ;;
            --reset-dot-files|--reset)
                run_reset=$TRUE
                ;;
            --remove-installations-backups|--remove-backups)
                run_remove_backups=$TRUE
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
}

main_home_folders() {
    printf "Creating HOME folders..."
    mkdir -p -- "$CUSTOM_USER_APPS_DIR" \
        "$LOCAL_BIN_DIR" \
        "$LOCAL_SHARE" \
        "$LOCAL_SHARE/flatpak" \
        "$LOCAL_SHARE/applications" \
        "$LOCAL_SHARE/zoxide" \
        "$HOME/Dev" \
        "$HOME/Temp" \
        "$HOME/.docker"
    printf "Ok\n"
}

main_install() {
    # Apt packages.
    printf "Installing apt packages..."
    install_apt_packages
    printf "Ok\n"

    # Fnm.
    printf "Installing fnm..."
    install_fnm
    printf "Ok\n"

    # Npm.
    printf "Installing npm LSP tools..."
    install_npm_lsp_tools
    printf "Ok\n"

    # Lsp Servers.
    printf "Installing general LSP tools (Language Server Protocol)..."
    install_python_lsp_tools
    install_go_lsp_tools
    install_rustup
    install_laravel_lsp
    install_lua_language_server
    printf "Ok\n"

    # Custom fonts.
    printf "Installing custom fonts..."
    install_web_font "SourceCodePro"
    install_web_font "NerdFontsSymbolsOnly"
    fc-cache --force
    printf "Ok\n"

    # Kitty terminal.
    printf "Installing kitty..."
    install_kitty
    printf "Ok\n"

    # Nvim.
    printf "Installing nvim..."
    install_neovim
    printf "Ok\n"

    # Fzf.
    printf "Installing fzf..."
    install_fzf
    printf "Ok\n"

    # Lazygit.
    printf "Installing lazygit..."
    install_lazygit
    printf "Ok\n"

    # Tree-sitter.
    printf "Installing tree-sitter..."
    install_treesitter
    printf "Ok\n"

    # Zoxide.
    printf "Installing zoxide..."
    install_zoxide
    printf "Ok\n"

    # Yazi.
    printf "Installing yazi..."
    install_yazi
    printf "Ok\n"

    # Superfile.
    printf "Installing superfile..."
    install_superfile
    printf "Ok\n"
}

main_configs() {
    printf "Copying dot files..."
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
    printf "Ok\n"
}

main_flatpaks() {
    printf "Installing flatpaks..."
    install_flatpak_packages
    override_pop_os_flatpak_launchers
    printf "Ok\n"
}

# Entry point of the shellscript.
main() {
    # Runtime variables.
    local START_DATE_TIME="$(date '+%Y%m%d%H%M%S')" # AAAAMMDDHHMMSS
    local BACKUP_EXT="bkp"
    local SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)" # Absolute path
    local LOCAL_BIN_DIR="$HOME/.local/bin"
    local CUSTOM_USER_APPS_DIR="$HOME/Apps"
    local LOCAL_SHARE="$HOME/.local/share"
    local FALSE="false"
    local TRUE="true"
    local NULL="null"
    local run_no_flatpaks=$NULL
    local run_reset=$NULL
    local run_update=$NULL
    local run_remove_backups=$NULL

    handle_parameters "$@"

    command clear

    printf "Setting up your environment...\n"

    main_home_folders

    if [[ $run_full_install == $TRUE || $run_update == $TRUE ]]; then
        main_install
    fi

    if [[ $run_full_install == $TRUE || $run_reset == $TRUE ]]; then
        main_configs
    fi

    if [[ $run_no_flatpaks == $FALSE || $run_reset == $FALSE ]]; then
        main_flatpaks
    fi

    printf "\n\nSetup finished. Open a new shell or run 'source ~/.bashrc' in current shell.\n"
    printf "Some apps, like Kitty Terminal, may present bugged behavior at oppening. Mainly with desktop integration. Log out and log in again.\n\n"
    printf "Have a nice day! =)\n"
}

main "$@"
