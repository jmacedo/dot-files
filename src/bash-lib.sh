#!/usr/bin/env bash

has_kvm() {
    while read -r module _; do
        case "${module:-}" in
            kvm|kvm_intel|kvm_amd)
                return 0
                ;;
        esac
    done < /proc/modules
    
    return 1
}

backup_path() {
    local destination="${1:-}"

    if [[ -e "$destination" || -L "$destination" ]]; then
        mv -f -- "$destination" "$destination.${START_DATE_TIME:-'old'}.bkp"
    fi

    return 0
}

exclude_temp_path() {
    CLEANUP_PATHS+=("${1:-}")

    return 0
}

cleanup_temp_paths() {
    local path

    for path in "${CLEANUP_PATHS[@]:-}"; do
        [[ -n "$path" ]] && rm -rf -- "$path"
    done

    POST_GITHUB_INSTALL_COMMANDS=()

    return 0
}

install_local_font() {
    local font_name="$1"
    local font_path="${2:-$SCRIPT_DIR/.local/share/fonts}"
    local source="$font_path/$font_name"
    local destination="$HOME/.local/share/fonts/$font_name"

    if [[ ! -d "$source" ]]; then
        printf 'Missing local font: %s\n' "$source" >&2
        return 1
    fi

    backup_path "$destination"
    mkdir -p -- "$(dirname -- "$destination")"
    cp -a -- "$source" "$destination"

    return 0
}

install_web_font() {
    local file_name="$1"
    local source_url="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${file_name}.zip"
    local destination="$HOME/.local/share/fonts/$file_name"
    local download_path="$(mktemp)"
    exclude_temp_path "$download_path"
    local extraction_dir="$(mktemp -d)"
    exclude_temp_path "$extraction_dir"

    backup_path "$destination"
    mkdir -p -- "$destination"

    curl --fail --location "$source_url" --output "$download_path"
    unzip -q -- "$download_path" -d "$extraction_dir"

    cp -a -- "$extraction_dir/." "$destination"

    return 0
}

install_bin_from_github() {
    # Linux x64 platform.
    local filename_pattern="^.*[.*(linux|linux-gnu).*|(linux|linux-gnu).*[x86_64|amd64|x64]+|[x86_64|amd64|x64]+.*(linux|linux-gnu)].*[\.tar\.gz|\.zip]$"
    local binary_name="$1"
    local repo="$2"
    local cmd=""
    local release_api_url="https://api.github.com/repos/$repo/releases/latest"
    local install_dir="$CUSTOM_USER_APPS_DIR/$binary_name"
    local binary_download_url=""
    local binary_path=""
    local is_zip=false
    local temp_file="$(mktemp)"
    exclude_temp_path "$temp_file"
    local extraction_dir="$(mktemp -d)"
    exclude_temp_path "$extraction_dir"

    if ! curl -sSf -o /dev/null "$release_api_url"; then # Validates releases URL from github API.
        printf "Installation of '%s' failed.\nThe releases address '%s' doesn't seem to be working." "$binary_name" "$release_api_url"
        return 1;
    fi

    binary_download_url="$(curl --fail --silent --show-error --location --header "Accept: application/vnd.github+json" "$release_api_url" | jq -r ".assets[].browser_download_url | select(test('${filename_pattern:-}'))")"

    if ! curl -sSf -o /dev/null "$binary_download_url"; then # Validates the binary URL got in github api.
        printf "Installation of '%s' failed.\nThe binary address '%s' doesn't seem to be working." "$binary_name" "$binary_download_url"
        return 1;
    fi

    is_zip=$("$binary_download_url" == *.* && "$("${binary_download_url#*.}")" == "zip")

    # Backup current.
    backup_path "$LOCAL_BIN_DIR/$binary_name"
    backup_path "$install_dir"
    mkdir -p -- "$install_dir"

    curl --fail --location "$binary_download_url" --output "$temp_file"
    # Extract files.
    is_zip && unzip -q "$temp_file" -d "$extraction_dir" || tar --extract --gzip --file "$download_path" --directory "$extraction_dir"

    binary_path="$(find "$extraction_dir" -type f -name "$binary_name" -print -quit)"
    
    if [[ -z "$binary_path" || ! -f "$binary_path" ]]; then # Validates the extracted binary.
        printf 'Installation of '%s' failed.\nMissing '%s' binary in release asset: %s\n' "$binary_name" "$binary_download_url" >&2
        return 1
    fi

    install --mode=0755 -- "$binary_path" "$install_dir/$binary_name"
    ln -sfn -- "$install_dir/$binary_name" "$LOCAL_BIN_DIR/$binary_name"

    if (( ${#POST_GITHUB_INSTALL_COMMANDS[@]} > 0 )); then
        for cmd in "${POST_GITHUB_INSTALL_COMMANDS[@]}"; do
            if [[ -z "$cmd" ]]; then
                printf "Installation of '%s' failed.\nInvalid empty command '%s'." "$binary_name" "$cmd"
                return 1;
            fi

            if ! eval "$cmd"; then
                printf "Warning for '%s' installation.\nError running the command:\n%s" "$binary_name" "$cmd"
            fi
        done
    fi

    return 0
}

install_apt_packages() {
    local packages_array_name="${1:-}"

    if [[ -z "$packages_array_name" ]]; then
        printf "Failed installing apt packages. No array name provided.\n" >&2
        return 1
    fi

    if ! declare -p "$packages_array_name" > /dev/null 2>&1; then
        printf "Failed installing apt packages. Unknown array: %s\n" "$packages_array_name"
        return 1
    fi

    local -n packages="$packages_array_name"
    if (( ${#packages[@]} == 0 )); then
        printf "Failed installing apt packages. Packages array is empty."
        return 1
    fi

    sudo apt update -y
    sudo apt upgrade -y
    sudo apt autoremove -y
    sudo apt autoclean
    sudo apt install -y "${packages[@]}"

    return 0
}

install_flatpak_remote_flathub() {
    flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

    return 0
}

install_flatpak_packages() {
    local app=""
    local apps_array_name="${1:-}"

    if [[ -z "$apps_array_name" ]]; then
        printf "Failed installing flatpak packages. No array name provided.\n" >&2
        return 1
    fi

    if ! declare -p "$apps_array_name" >/dev/null 2>&1; then
        printf "Failed installing flatpak packages. Unknown array: %s\n" "$apps_array_name"
        return 1
    fi

    local -n apps="$apps_array_name"
    for app in "${apps[@]}"; do
        flatpak install --user --noninteractive --or-update "$app"
    done

    return 0
}

install_config() {
    local relative_path="${1:-}"
    local source="${SCRIPT_DIR:-$HOME}/$relative_path"
    local destination="$HOME/$relative_path"

    if [[ ! -e "$source" ]]; then
        printf "Missing source file or directory: '%s'\n" "$source" >&2
        return 1
    fi

    backup_path "$destination"
    mkdir -p -- "$(dirname -- "$destination")"

    if [[ -f "$source" ]]; then
        cp -f -- "$source" "$destination"
        return 0
    fi

    if [[ -d "$source" ]]; then
        cp -rf -- "$source" "$destination"
        return 0
    fi

    return 1
}