#!/usr/bin/env bash

# Set up desktop environment and base apps/packages installations.
# Run from any directory: paths are resolved relative to this script.

# `-u`: nounset - Unset variables raises error. Misspeling variables will not be treated as empty values.
# `-E`: Inherit ERR trap in functions and subshells.
# `-e`: errexit - Exit script on errors.
# `-o pipefail` - Raise errors inside a chain of commands (`cmdA | cmdB | cmdC`) instead of by default use the last command status code.
set -Eeuo pipefail

install_docker() {
    # Initialize.
    local apt_source_template="${SCRIPT_DIR:-$HOME}/.config/docker/docker.sources"
    local code_name=""
    local architecture=""
    local apt_source_temp=""
    local gpg_temp=""

    apt_source_temp="$(mktemp)" || return 1
    exclude_temp_path "$apt_source_temp"

    gpg_temp="$(mktemp)" || return 1
    exclude_temp_path "$gpg_temp"

    # Some validations.
    [[ -f "$apt_source_template" ]] || {
        printf "Docker apt template not found: %s\n" "$apt_source_template" >&2
        return 1
    }

    if ! has_kvm; then
        printf "Docker sandboxes requires KVM for local sandboxes (mainly AI).\n"
        return 1
    fi

    # Remove conflicting packages.
    sudo apt remove -y docker.io docker-compose docker-compose-v2 docker-doc docker-buildx podman-docker containerd runc

    # Install gpg keyrings.
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o "$gpg_temp" || return 1
    sudo install -m 0644 "$gpg_temp" /etc/apt/keyrings/docker.asc

    # Docker source list.
    code_name="$(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")"
    architecture="$(dpkg --print-architecture)"

    sed -e "s|@@CODE_NAME@@|${code_name}|g" \
        -e "s|@@ARCHITECTURE@@|${architecture}|g" \
        "$apt_source_template" > "$apt_source_temp" || return 1

    if grep -q '@@' "$apt_source_temp"; then
        printf "Unresolved placeholder in Docker APT template.\n" >&2
        return 1
    fi

    sudo install -m 0644 "$apt_source_temp" "/etc/apt/sources.list.d/docker.sources"
    sudo apt update

    # Main installation.
    sudo apt install -y \
        docker-ce \
        docker-ce-cli \
        containerd.io \
        docker-buildx-plugin \
        docker-compose-plugin \
        docker-sbx

    # Permissions.
    sudo groupadd -f docker
    sudo usermod -aG docker,kvm "$(whoami)"
    newgrp docker
    newgrp kvm

    # Services.
    sudo systemctl enable --now docker.service containerd.service

    return 0
}

install_nodejs() {
    local version="v26.13.1"
    local platform="linux-x64"
    local package_name="node-${version}-${platform}.tar.gz"

    local binary_download_url="https://nodejs.org/dist/${version}/node-${version}-${platform}.tar.gz"
    local install_directory="$CUSTOM_USER_APPS_DIR/nodejs"
    local temp_file=""
    
    temp_dir="$(mktemp -d)"
    exclude_temp_path "$temp_dir"

    backup_path "$install_directory"
    mkdir -p -- "$install_directory"

    curl --fail --silent --show-error --location --output-dir "${temp_dir}" -O "${binary_download_url}"
    tar --extract --gzip --file="${temp_dir}/node-${version}-${platform}.tar.gz" --strip-components=1 -C "$install_directory"

    return 0
}

main_install() {
    # Apt packages.
    while IFS= read -r apt_object; do
        local package_name="$(jq -r ".package_name" <<< "$apt_object")"
        sudo apt install -y "$package_name"

        while IFS= read -r command; do
            if ! eval "$command"; then
                printf "Failed installing '%s' apt installation.\nError running the command:\n%s\n" "$package_name" "$command"
                return 1
            fi
        done < <(jq -r ".custom_commands[]" <<< "$apt_object")
    done < <(jq -rc ".applications.apt.list[]" "$JSON_PARAMETERS_PATH")

    # Binaries packages.
    while IFS= read -r binary_object; do
        local repo_name="$(jq -r ".repo" <<< "$binary_object")"
        local bin_name="$(jq -r ".bin_name" <<< "$binary_object")"
        local version="$(jq -r ".version" <<< "$binary_object")"
        local strip_components="$(jq -r ".strip_components" <<< "$binary_object")"
        local asset_pattern="$(jq -r ".asset_pattern" <<< "$binary_object")"

        install_bin_from_github "$repo_name" "$version" "$asset_pattern" "$bin_name" "$strip_components"

        while IFS= read -r command; do
            local parsed_command=""

            if [[ -z "$command" ]]; then
                printf "Installation of '%s' failed.\nInvalid empty command '%s'.\n" "$repo_name" "$command"
                return 1
            fi

            parsed_command=$(expand_variables "$command")

            if ! eval "$parsed_command"; then
                printf "Installation of '%s' failed.\nError running the command:\n%s\n" "$repo_name" "$parsed_command"
                return 1
            fi
        done < <(jq -r ".custom_commands[]" <<< "$binary_object")
    done < <(jq -rc ".applications.binary.list[]" "$JSON_PARAMETERS_PATH")

    # Docker installation.
    install_docker

    # Nodejs installation.
    install_nodejs

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
                printf "Installation of '%s' failed.\nInvalid empty command '%s'.\n" "$package_name" "$command"
                return 1
            fi

            if ! eval "$command"; then
                printf "Installation of '%s' failed.\nError running the command:\n%s\n" "$package_name" "$command"
                return 1
            fi
        done < <(jq -r ".custom_commands[]" <<< "$flatpak_object")
    done < <(jq -rc ".applications.flatpak.list[]" "$JSON_PARAMETERS_PATH")

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
    # Initialize.
    sudo apt update -y
    sudo apt upgrade -y
    sudo apt autoremove -y
    sudo apt autoclean
    sudo apt install -y jq || exit 1

    local LOCAL_BIN_DIR="$HOME/.local/bin"
    local SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)" # Absolute path
    local JSON_PARAMETERS_PATH="$SCRIPT_DIR/setup-params.json"
    local __datetime_pattern="$(jq -r '.installations_backups.datetime_pattern' "$JSON_PARAMETERS_PATH")"
    local __bkp_extension="$(jq -r '.installations_backups.backup_extension' "$JSON_PARAMETERS_PATH")"
    local __apps_dir="$(jq -r '.custom_directories.apps_directory' "$JSON_PARAMETERS_PATH")"
    local CUSTOM_USER_APPS_DIR="$HOME/$__apps_dir"
    local START_DATE_TIME="$(date "$__datetime_pattern")"
    local BACKUP_EXT="$__bkp_extension"

    # Include external libraries.
    while IFS= read -r external_library; do
        source "$SCRIPT_DIR/$external_library"
    done < <(jq -r ".runtime.external_libraries[]" "$JSON_PARAMETERS_PATH")

    # Home folders structure.
    mkdir -p -- "$LOCAL_BIN_DIR" \
        "$CUSTOM_USER_APPS_DIR" \
        "$HOME/.local/share/flatpak" \
        "$HOME/.local/share/applications" \
        "$HOME/.local/share/zoxide"

    while IFS= read -r directory; do
        mkdir -p -- "$HOME/$directory"
    done < <(jq -r ".custom_directories.list[]" "$JSON_PARAMETERS_PATH")

    # Main execution.
    command clear
    main_install
    main_configs
    main_flatpaks
    main_fonts

    # Finalize.
    echo "Finish!"
    echo "Remember to login to docker with: sbx login."
}

cleanup_temp_paths() {
    local path=""
    for path in "${CLEANUP_PATHS[@]:-}"; do
        [[ -n "$path" ]] && rm -rf -- "$path"
    done
    return 0
}
CLEANUP_PATHS=()
trap cleanup_temp_paths EXIT
main "$@"