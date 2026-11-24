#!/usr/bin/env bash

# Set up desktop environment and base apps/packages installations.
# Run from any directory: paths are resolved relative to this script.

# `-u`: nounset - Unset variables raises error. Misspeling variables will not be treated as empty values.
# `-e`: errexit - Exit script on errors.
# `-o pipefail` - Raise errors inside a chain of commands (`cmdA | cmdB | cmdC`) instead of by default use the last command status code.
set -euo pipefail

handle_parameters() {
    #if [[ $# -eq 0 ]]; then ### fi

    #for parameter in "$@"; do
    #    case "$parameter" in
    #        --my-parameter|--another-parameter)
    #            ;;
    #        *)
    #            printf "Unknown parameter: %s" $parameter >&2
    #            printf "Use '%s --help'." $0 >&2
    #            exit 1
    #            ;;
    #    esac
    #done

    return 0
}

install_docker() {
    local apt_source_template="${SCRIPT_DIR:-$HOME}/.config/docker/docker.sources"
    local apt_source_temp="$(mktemp)"
    exclude_temp_path "$apt_source_temp"

    sudo apt remove docker.io docker-compose docker-compose-v2 docker-doc docker-buildx podman-docker containerd runc
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

    sudo groupadd -f docker
    sudo usermod -aG docker $USER
    newgrp docker
    sudo chown "$USER":"$USER" /home/"$USER"/.docker -R
    sudo chmod g+rwx "$HOME/.docker" -R

    sudo systemctl enable docker.service
    sudo systemctl enable containerd.service

    # Verify KVM for docker sandboxes for AI
    if ! has_kvm; then
        printf "Docker needs KVM to be loaded to build AI sandboxes.\n See %s --help\n" "$0"
        return 1
    fi
    sudo usermod -aG kvm $USER
    newgrp kvm

    return 0
}

install_flatpak_remotes() {
    flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

    return 0
}

override_pop_os_flatpak_launchers() {
    # On PopOS 24.04, some flatpak apps bugged to launch.
    # This function configure a work-around to fix it.

    # Google Chrome launcher (run as X11).
    cp -f -- "$SCRIPT_DIR/.config/desktop-launchers/com.google.Chrome.desktop" "$HOME/.local/share/applications"

    # VS Code launcher (run without gpu aceleration).
    cp -f -- "$SCRIPT_DIR/.config/desktop-launchers/com.visualstudio.code.desktop" "$HOME/.local/share/applications"

    return 0
}

main_install() {
    # Apt
    local apt_packages=()
    while IFS= read -r package; do
        apt_packages+=("$package")
    done < <(jq -r ".applications.apt.list[]" "$JSON_PARAMETERS_PATH")
    install_apt_packages apt_packages

    # Binary
    while IFS= read -r binary_object; do
        local repo_name=$(jq -r ".repo" <<< "$binary_object")

        POST_GITHUB_INSTALL_COMMANDS=()
        while IFS= read -r command; do
            POST_GITHUB_INSTALL_COMMANDS+=("$command")
        done < <(jq -r ".custom_commands[]" <<< "$binary_object")

        install_bin_from_github "$repo_name"
    done < <(jq -r ".applications.binary.list[]" "$JSON_PARAMETERS_PATH")

    # Docker.
    install_docker

    return 0
}

main_configs() {
    while IFS= read -r dot_file; do
        install_config "$dot_file"
    done < <(jq -r ".dot_files[]" "$JSON_PARAMETERS_PATH")

    return 0
}

main_flatpaks() {
    local apps=()
    while IFS= read -r package; do
        apps+=("$package")
    done < <(jq -r ".applications.flatpak.list[]" "$JSON_PARAMETERS_PATH")

    install_flatpak_remotes
    install_flatpak_packages apps
    override_pop_os_flatpak_launchers

    return 0
}

main_fonts() {
    while IFS= read -r nerd_font; do
        install_web_font "$nerd_font"
    done < <(jq -r ".fonts.nerd_fonts[]" "$JSON_PARAMETERS_PATH")

    while IFS= read -r local_font; do
        install_local_font "$local_font"
    done < <(jq -r ".fonts.local_fonts[]" "$JSON_PARAMETERS_PATH")

    fc-cache --really-force

    return 0
}

main() {
    # Initialize.
    local SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)" # Absolute path
    local LOCAL_BIN_DIR="$HOME/.local/bin"
    local LOCAL_SHARE="$HOME/.local/share"
    local JSON_PARAMETERS_PATH="$SCRIPT_DIR/setup-params.json"

    #handle_parameters "$@"

    local __datetime_pattern=$(jq -r ".installations_backups.datetime_pattern", "$JSON_PARAMETERS_PATH")
    local __bkp_extension=$(jq -r ".installations_backups.backup_extension", "$JSON_PARAMETERS_PATH")
    local __apps_dir=$(jq -r ".custom_directories.apps_dir", "$JSON_PARAMETERS_PATH")

    local START_DATE_TIME="$(date "$__datetime_pattern")"
    local BACKUP_EXT="$__bkp_extension"
    local CUSTOM_USER_APPS_DIR="$HOME/$__apps_dir"

    # Home folders structure.
    mkdir -p -- "$CUSTOM_USER_APPS_DIR"
    
    while IFS= read -r directory; do
        mkdir -p -- "$directory"
    done < <(jq -r ".custom_directories.list[]" "$JSON_PARAMETERS_PATH")

    mkdir -p -- "$HOME/.local/bin" \
        "$HOME/.local/share/flatpak" \
        "$HOME/.local/share/applications" \
        "$HOME/.local/share/zoxide"

    # External libraries.
    source "$SCRIPT_DIR/setup-lib.sh"

    # Main execution.
    command clear
    main_install
    main_configs
    main_flatpaks
    main_fonts

    # Finalize.
    echo "Finish!"
    echo "For testing docker, run: docker run hello-world"
    echo "For login to docker, run: sbx login"
}

CLEANUP_PATHS=()
POST_GITHUB_INSTALL_COMMANDS=()
trap cleanup_temp_paths EXIT
main "$@"