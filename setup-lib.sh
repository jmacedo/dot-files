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
    local source_url="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/$file_name.zip"
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
    local filename_pattern="^((.*[linux|linux\-gnu].*[x86_64|amd64|x64].*)|(.*[x86_64|amd64|x64].*[linux|linux\-gnu].*))(\.tar\.gz|\.zip)$"
    local repository="$1"
    local binary_name="${2:-$("${repository#*/}")}"
    local strip_components="${3:-0}"
    local cmd=""
    local release_api_url="https://api.github.com/repos/$repository/releases/latest"
    local install_dir="$CUSTOM_USER_APPS_DIR/$binary_name"
    local binary_download_url=""
    local binary_path=""
    local is_zip=false
    local is_txz=false
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

    if [[ "$binary_download_url" == *.* ]]; then
        is_zip=$("${binary_download_url#*.}" == "zip")
        is_txz=$("${binary_download_url#*.}" == "txz")
    fi

    # Backup current.
    backup_path "$LOCAL_BIN_DIR/$binary_name"
    backup_path "$install_dir"
    mkdir -p -- "$install_dir"

    curl --fail --location "$binary_download_url" --output "$temp_file"
    
    # Extract files.
    if is_zip; then
        bsdtar -xf "$temp_file" --strip-components "$strip_components" -C "$extraction_dir"
    elif is_txz; then
        tar --extract --xz --strip-components="$strip_components" --file "$temp_file" --directory "$extraction_dir"
    else
        tar --extract --gzip --strip-components="$strip_components" --file "$temp_file" --directory "$extraction_dir"
    fi

    binary_path="$(find "$extraction_dir" -type f -name "$binary_name" -print -quit)"
    if [[ -z "$binary_path" || ! -f "$binary_path" ]]; then # Validates the extracted binary.
        printf 'Installation of '%s' failed.\nMissing '%s' binary in release asset: %s\n' "$binary_name" "$binary_download_url" >&2
        return 1
    fi

    # Copy/install files.
    cp -a -- "$extraction_dir/." "$install_dir"

    binary_path="$(find "$install_dir" -type f -name "$binary_name" -print -quit)"
    ln -sfn -- "$binary_path" "$LOCAL_BIN_DIR/$binary_name"

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