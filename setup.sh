#!/usr/bin/env bash

# Set up desktop environment and base apps/packages installations.
# Run from any directory: paths are resolved relative to this script.

# `-u`: nounset - Unset variables raises error. Misspeling variables will not be treated as empty values.
# `-e`: errexit - Exit script on errors.
# `-o pipefail` - Raise errors inside a chain of commands (`cmdA | cmdB | cmdC`) instead of by default use the last command status code.
set -euo pipefail

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

main_install() {
    # Apt packages.
    sudo apt update -y
    sudo apt upgrade -y
    sudo apt autoremove -y
    sudo apt autoclean

    while IFS= read -r apt_object; do
        local package_name="$(jq -r ".package_name" <<< "$apt_object")"
        sudo apt install -y "$package_name"

        while IFS= read -r command; do
            if ! eval "$command"; then
                printf "Warning for '%s' apt installation.\nError running the command:\n%s" "$package_name" "$command"
            fi
        done < <(jq -r ".custom_commands[]" <<< "$apt_object")
    done < <(jq -r ".applications.apt.list[]" "$JSON_PARAMETERS_PATH")

    # Binaries packages.
    while IFS= read -r binary_object; do
        local repo_name="$(jq -r ".repo" <<< "$binary_object")"
        local bin_name="$(jq -r ".bin_name" <<< "$binary_object")"
        local strip_components="$(jq -r ".strip_components" <<< "$binary_object")"

        install_bin_from_github "$repo_name" "$bin_name" "$strip_components"

        while IFS= read -r command; do
            if [[ -z "$command" ]]; then
                printf "Installation of '%s' failed.\nInvalid empty command '%s'." "$repo_name" "$command"
                return 1
            fi

            if ! eval "$command"; then
                printf "Installation of '%s' failed.\nError running the command:\n%s" "$repo_name" "$command"
                return 1
            fi
        done < <(jq -r ".custom_commands[]" <<< "$binary_object")
    done < <(jq -r ".applications.binary.list[]" "$JSON_PARAMETERS_PATH")

    # Docker installation.
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
    flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

    while IFS= read -r flatpak_object; do
        local package_name="$(jq -r ".package_name" <<< "$flatpak_object")"

        flatpak install --user --noninteractive --or-update flathub "$package_name"

        while IFS= read -r command; do
            if [[ -z "$command" ]]; then
                printf "Installation of '%s' failed.\nInvalid empty command '%s'." "$package_name" "$command"
                return 1
            fi

            if ! eval "$command"; then
                printf "Installation of '%s' failed.\nError running the command:\n%s" "$package_name" "$command"
                return 1
            fi
        done < <(jq -r ".custom_commands[]" <<< "$flatpak_object")
    done < <(jq -r ".applications.flatpak.list[]" "$JSON_PARAMETERS_PATH")

    # On PopOS 24.04, some flatpak apps bugged to launch.
    # The code below configures a work-around to fix it, once launchers in `~/.local/share/applications` have priority.

    # Google Chrome launcher (run as X11).
    cp -f -- "$SCRIPT_DIR/.config/desktop-launchers/com.google.Chrome.desktop" "$HOME/.local/share/applications"

    # VS Code launcher (run without gpu aceleration).
    cp -f -- "$SCRIPT_DIR/.config/desktop-launchers/com.visualstudio.code.desktop" "$HOME/.local/share/applications"

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
    # External libraries.
    source "$SCRIPT_DIR/setup-lib.sh"

    # Initialize.
    local SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)" # Absolute path
    local LOCAL_BIN_DIR="$HOME/.local/bin"
    local JSON_PARAMETERS_PATH="$SCRIPT_DIR/setup-params.json"
    
    local __datetime_pattern=$(jq -r ".installations_backups.datetime_pattern", "$JSON_PARAMETERS_PATH")
    local __bkp_extension=$(jq -r ".installations_backups.backup_extension", "$JSON_PARAMETERS_PATH")
    local __apps_dir=$(jq -r ".custom_directories.apps_dir", "$JSON_PARAMETERS_PATH")

    local START_DATE_TIME="$(date "$__datetime_pattern")"
    local BACKUP_EXT="$__bkp_extension"
    local CUSTOM_USER_APPS_DIR="$HOME/$__apps_dir"

    # Home folders structure.
    mkdir -p -- "$LOCAL_BIN_DIR" \
        "$HOME/.local/share/flatpak" \
        "$HOME/.local/share/applications" \
        "$HOME/.local/share/zoxide" \
        "$CUSTOM_USER_APPS_DIR"

    while IFS= read -r directory; do
        mkdir -p -- "$directory"
    done < <(jq -r ".custom_directories.list[]" "$JSON_PARAMETERS_PATH")

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
trap cleanup_temp_paths EXIT
main "$@"