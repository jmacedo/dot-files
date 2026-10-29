#!/usr/bin/env bash

# Set up desktop environment and base apps/packages installations.
# Run from any directory: paths are resolved relative to this script.

# `-u`: nounset - Unset variables raises error. Misspeling variables will not be treated as empty values.
# `-e`: errexit - Exit script on errors.
# `-o pipefail` - Raise errors inside a chain of commands (`cmdA | cmdB | cmdC`) instead of by default use the last command status code.
set -euo pipefail

custom_clear() {
    # Verify if is a valid interactive terminal and command `clear` exists.
    if [[ -t 1 && -n "${TERM:-}" ]] && command -v clear >/dev/null 2>&1; then
        clear || true
    fi
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

command_exists() { 
    command -v "$1" >/dev/null 2>&1 
}

# Check operational system requirements: Linux kernel, x86_64 architecture, apt packages.
validate_environment() {
    if [[ "$(uname -s)" != "Linux" ]]; then
        printf "This setup supports Linux only.\n" >&2
        return 1
    fi

    if [[ "$(uname -m)" != "x86_64" ]]; then
        printf "This setup supports x86_64 only.\n" >&2
        return 1
    fi
    
    if [[ ! command_exists apt ]]; then
        printf "This setup requires apt package manager (a Debian-based distribution).\n" >&2
        return 1
    fi
}

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
    local install_dir="$HOME/Apps/nvim"
    local download_path="$(mktemp)"

    # Download and copy files.    
    curl --fail --location "$source_url" --output "$download_path"
    backup_path "$install_dir"
    mkdir -p -- "$install_dir"
    tar --extract --gzip --file "$download_path" --strip-components=1 --directory "$install_dir"
    
    # Handle binaries.
    ln -sfn -- "$install_dir/bin/nvim" "$LOCAL_BIN_DIR/nvim"

    # Clean up
    rm -f -- "$download_path"
}

# FZF fuzzy finder from the latest stable official GitHub release.
install_fzf() {
    local release_api_url="https://api.github.com/repos/junegunn/fzf/releases/latest"
    local release_info
    local download_url
    local download_path
    local extraction_dir
    local install_dir="$CUSTOM_USER_APPS_DIR/fzf"

    # Get latest release download url.
    release_info="$(
        curl --fail --silent --show-error --location \
            --header "Accept: application/vnd.github+json" \
            "$release_api_url"
    )"

    download_url="$(
        printf '%s' "$release_info" | python3 -c '
import json
import re
import sys

release = json.load(sys.stdin)
asset_pattern = re.compile(r"fzf-\d+(?:\.\d+)*-linux_amd64\.tar\.gz")

for asset in release.get("assets", []):
    if asset_pattern.fullmatch(asset.get("name", "")):
        print(asset["browser_download_url"])
        break
else:
    raise SystemExit("Could not find the fzf Linux amd64 release asset.")
'
    )"


    # Download and extract.
    download_path="$(mktemp)"
    extraction_dir="$(mktemp -d)"

    curl --fail --location "$download_url" --output "$download_path"
    tar --extract --gzip --file "$download_path" --directory "$extraction_dir"

    if [[ ! -x "$extraction_dir/fzf" ]]; then
        printf 'Missing fzf binary in release asset: %s\n' "$download_url" >&2
        return 1
    fi

    # Handle binary.
    backup_path "$install_dir"
    mkdir -p -- "$install_dir"
    install --mode=0755 -- "$extraction_dir/fzf" "$install_dir/fzf"
    backup_path "$LOCAL_BIN_DIR/fzf"
    ln -sfn -- "$install_dir/fzf" "$LOCAL_BIN_DIR/fzf"

    # Clean up.
    rm -f -- "$download_path"
    rm -rf -- "$extraction_dir"
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

# Install oficial debian package from Dropbox website.
# It works, but it's not used.
install_dropbox_deb() {
    local package_family
    local package_index_url
    local package_listing
    local package_name
    local temp_dir
    local package_path

    # AI: Pop!_OS and Ubuntu derivatives use Dropbox's Ubuntu package.
    # AI: Debian and Debian derivatives use its Debian package.
    # shellcheck disable=SC1091
    . /etc/os-release

    case " ${ID:-} ${ID_LIKE:-} " in
        *" ubuntu "*)
            package_family="ubuntu"
            ;;
        *" debian "*)
            package_family="debian"
            ;;
        *)
            printf 'Dropbox .deb installation only supports Ubuntu- or Debian-based systems.\n' >&2
            return 1
            ;;
    esac

    # Select the newest dated 64-bit desktop package from Dropbox's listing.
    package_index_url="https://linux.dropbox.com/packages/$package_family/"
    package_listing="$(
        curl --fail --silent --show-error --location "$package_index_url"
    )"

    package_name="$(
        printf '%s\n' "$package_listing" |
            { grep -oE 'dropbox_[0-9]{4}\.[0-9]{2}\.[0-9]{2}_amd64\.deb' || true; } |
            sort -V |
            tail -n 1
    )"

    if [[ -z "$package_name" ]]; then
        printf 'Could not find a Dropbox amd64 .deb at %s\n' \
            "$package_index_url" >&2
        return 1
    fi

    # Download and install.
    temp_dir="$(mktemp -d)"
    package_path="$temp_dir/$package_name"

    curl --fail --silent --show-error --location \
        "$package_index_url$package_name" \
        --output "$package_path"

    dpkg-deb --info "$package_path" >/dev/null
    sudo apt install --yes "$package_path"

    # Clean up
    rm -rf -- "$temp_dir"
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

    # Flatpak remote
    flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

    # Install Apps
    for app in "${apps[@]}"; do
        flatpak install --user --noninteractive --or-update flathub "$app"
    done

    
    # On *Pop!_OS 24.04*, at least inside a VM, Chrome and VSCode failed on open.
    # TODO: Analyse to use these parameters directly in `<app>.desktop`, in `Exec=` call.
    
    # Override flatpak to use x11 engine in Chrome.
    #flatpak override --user \
    #    --env=ELECTRON_OZONE_PLATFORM_HINT=x11 \
    #    --env=GDK_BACKEND=x11 \
    #    com.google.Chrome

    # Disable GPU aceleration in VSCode.
    #flatpak override --user \
    #    --env=LIBGL_ALWAYS_SOFTWARE=1 \
    #    com.visualstudio.code
}

# Laravel language server for nvim.
install_laravel_lsp() {
    export COMPOSER_HOME="$CUSTOM_USER_APPS_DIR/composer"

    composer global require laravel/lsp

    ln -sfn -- "$COMPOSER_HOME/vendor/bin/laravel-lsp" \
        "$LOCAL_BIN_DIR/laravel-lsp"
}

# Fnm: nodejs version manager.
install_fnm() {
    local installer_path="$(mktemp)"

    # Download and install.
    curl --fail --location "https://fnm.vercel.app/install" --output "$installer_path"
    bash "$installer_path" --install-dir "$CUSTOM_USER_APPS_DIR/fnm" --skip-shell

    # Clean up
    rm -f -- "$installer_path"

    # Configure fnm for now and install LTS nodejs (`--lts`). For latest: `--latest`.
    export PATH="$HOME/Apps/fnm:$PATH"
    eval "$(fnm env --use-on-cd --shell bash)"
    fnm install --lts # Node LTS version.
    fnm default "$(fnm current)" # Make node available by default.
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
    local release_info
    local download_url
    local install_dir="$CUSTOM_USER_APPS_DIR/lua-language-server"
    local download_path
    local extraction_dir

    # AI implementation approved.
    # The goal is to discover latest versions and get the download url.
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
print(asset["browser_download_url"])
            ')"

    read -r download_url <<< "$release_info"

    # Download and extract.
    download_path="$(mktemp)"
    extraction_dir="$(mktemp -d)"
    curl --fail --location "$download_url" --output "$download_path"
    tar --extract --gzip --file "$download_path" --directory "$extraction_dir"

    # Backup and install.
    backup_path "$install_dir"
    mkdir -p -- "$install_dir"
    cp -a -- "$extraction_dir/." "$install_dir/"

    # Handle binary.
    ln -sfn -- "$install_dir/bin/lua-language-server" \
        "$LOCAL_BIN_DIR/lua-language-server"

    # Clean up.
    rm -f -- "$download_path"
    rm -rf -- "$extraction_dir"
}

# On PopOS 24.04, some flatpak apps bugged to launch.
# This function configure a work-around to fix it.
override_pop_os_flatpak_launchers() {
    cat > "$HOME/.local/share/applications/com.google.Chrome.desktop" <<'EOF'
[Desktop Entry]
Name=Google Chrome
Exec=flatpak run --user com.google.Chrome --ozone-platform=x11 %U
Icon=com.google.Chrome
Type=Application
Categories=Network;WebBrowser;
StartupWMClass=google-chrome
EOF

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

# Entry point of the shellscript.
main() {
    # Runtime variables.
    START_DATE_TIME="$(date '+%Y%m%d%H%M%S')" # AAAAMMDDHHMMSS
    BACKUP_EXT="bkp"
    SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)" # Absolute path
    LOCAL_BIN_DIR="$HOME/.local/bin"
    CUSTOM_USER_APPS_DIR="$HOME/Apps"
    LOCAL_SHARE="$HOME/.local/share"
    run_no_flatpaks=false
    run_fast=false
    FALSE="false"

    case "${1:-}" in
    --no-flatpaks|--disable-flatpaks)
        run_no_flatpaks=true
        ;;
    --fast-install|--lite)
        run_no_flatpaks=true
        run_fast=true
        ;;
    help|--help|-h)
        echo "Usage: $0 {--no-flatpaks|--fast-install|--help}"
        exit 0
        ;;
    "")
        ;;
    *)
        echo "Unknown parameter: $1" >&2
        echo "Use '$0 --help'." >&2
        exit 1
        ;;
    esac

    custom_clear
    print_ascii_art
    validate_environment
    printf "Setting up your environment...\n"

    # Create custom home directories.
    mkdir -p -- "$CUSTOM_USER_APPS_DIR" \
        "$LOCAL_BIN_DIR" \
        "$LOCAL_SHARE" \
        "$LOCAL_SHARE/flatpak" \
        "$LOCAL_SHARE/applications" \
        "$LOCAL_SHARE/zoxide" \
        "$HOME/Dev" \
        "$HOME/Temp"

    if [[ "$run_fast" == "$FALSE" ]]; then
        # Apt packages.
        printf "Apt packages...\n"
        install_apt_packages

        # Fnm.
        printf "fnm...\n"
        install_fnm

        # Npm.
        printf "npm installations...\n"
        install_npm_lsp_tools

        # Lsp Servers.
        printf "Lsp tools...\n"

        # Python, Go, Rust, Laravel, Lua.
        install_python_lsp_tools
        install_go_lsp_tools
        install_rustup
        install_laravel_lsp
        install_lua_language_server

        # Custom fonts.
        printf "Custom fonts...\n"
        install_web_font "SourceCodePro"
        install_web_font "NerdFontsSymbolsOnly"
        fc-cache --force

        # Kitty terminal.
        printf "Install kitty...\n"
        install_kitty

        # Nvim.
        printf "Install nvim...\n"
        install_neovim

        # Fzf.
        printf "Install fzf...\n"
        install_fzf
    fi

    # Configs.
    printf "Copying dot files...\n"
    install_config ".config/bash"
    install_config ".config/kitty"
    install_config ".config/nvim"
    install_config ".config/fzf"
    install_config ".bashrc"
    install_config ".gitconfig"
    install_config ".hidden"

    # Conditionally install flatpaks.
    if [[ $run_no_flatpaks == "false" && "$run_fast" == "false" ]]; then
        printf "Installing flatpaks...\n"
        install_flatpak_packages
        override_pop_os_flatpak_launchers
    fi

    printf "\n\nSetup finished. Open a new shell or run 'source ~/.bashrc' in current shell.\n"
    printf "Some apps, like Kitty Terminal, may present bugged behavior at oppening. Mainly with desktop integration. Log out and log in again.\n\n"
    printf "Have a nice day! =)\n"
    print_ascii_art
    echo ""
}

main "$@"
