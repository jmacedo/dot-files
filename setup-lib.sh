#!/usr/bin/env bash

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

    return 0
}

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

expand_variables() {
    local input="$1"
    local variable=""
    local value=""

    while [[ "$input" =~ @@([A-Za-z_][A-Za-z0-9_]*)@@ ]]; do
        variable="${BASH_REMATCH[1]}"
        value="${!variable}"

        input="${input//@@${variable}@@/$value}"
    done

    printf '%s' "$input"
}

install_bin_from_github() {
    # Params: $repo_name $version $asset_pattern $bin_name $strip_components
    local repository="${1:-}"
    local version="${2:-'latest'}"
    local filename_pattern="${3:?"Missing asset pattern for github binary"}"
    local binary_name="${4:-"${repository#*/}"}"
    local strip_components="${5:-0}"

    local release_api_url="https://api.github.com/repos/${repository}/releases/${version}"
    local install_dir="$CUSTOM_USER_APPS_DIR/$binary_name"
    local binary_download_url=""
    local binary_download_url_cache_file="$SCRIPT_DIR/$binary_name.bin-url.cache"
    local binary_path=""
    local temp_file="$(mktemp)"
    exclude_temp_path "$temp_file"
    local extraction_dir="$(mktemp -d)"
    exclude_temp_path "$extraction_dir"

    if [[ -z "$repository" ]]; then
        printf "Invalid empty repository for binary install from github.\n"
        return 1
    fi

    if [[ -f "$binary_download_url_cache_file" ]]; then
        binary_download_url=$(cat "$binary_download_url_cache_file")
    else
        if ! binary_download_url="$(
            curl --fail --silent --show-error --location \
                --header "Accept: application/vnd.github+json" "$release_api_url" |
                jq -er --arg pattern "$filename_pattern" \
                    '[.assets[].browser_download_url | select(test($pattern))] |
                    if length == 1 then .[0] else empty end'
        )"; then
            printf "Installation of '%s' failed.\nExpected one matching release asset.\n" "$binary_name" >&2
            return 1
        else
            echo "$binary_download_url" > "$binary_download_url_cache_file"
        fi
    fi

    # Backup current.
    backup_path "$LOCAL_BIN_DIR/$binary_name"
    backup_path "$install_dir"
    mkdir -p -- "$install_dir"

    curl --fail --location "$binary_download_url" --output "$temp_file"
    
    # Extract files.
    case "$binary_download_url" in
        *.zip)
            bsdtar -xf "$temp_file" --strip-components "$strip_components" -C "$extraction_dir"
            ;;
        *.tar.gz)
            tar --extract --gzip --strip-components="$strip_components" --file "$temp_file" --directory "$extraction_dir"
            ;;
        *.txz)
            tar --extract --xz --strip-components="$strip_components" --file "$temp_file" --directory "$extraction_dir"
            ;;
        *)
            printf "Invalid archive URL: '%s'\n" "$binary_download_url" >&2
            return 1
            ;;
    esac

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