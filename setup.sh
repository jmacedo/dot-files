#!/usr/bin/env bash

set -eu

# Global constants and variables
initialize_script() {
    declare -gr START_DATE_TIME=$(date "+%Y%m%d%H%M%S")
    declare -gr BACKUP_EXT="bkp"
    declare -gr SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
    declare -gr SCRIPT_PATH="$SCRIPT_DIR/$(basename -- '${BASH_SOURCE[0]}')"
    declare -gr WORKING_DIR="$(pwd)"
    declare -gr SCRIPT_NAME="$(basename -- "${BASH_SOURCE[0]}")"
}

#: COMMON / BASE CODE

# Ok message
end_func() {
    printf 'Ok'
    return 0
}

# Verify if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Update the respository list and upgrade all system installed apps
upgrade_packages() {
    sudo apt update -y &&
    sudo apt upgrade -y &&
    sudo apt autoremove -y &&
    sudo apt autoclean -y

    end_func
    return 0
}

# Install packages needed in this script
install_base_packages() {
    declare -g packages=(
        git
        curl
        unzip
        vim

        file 
        ffmpeg 
        7zip 
        jq 
        poppler-utils 
        fdutils 
        fzf 
        zoxide 
        imagemagick 
        xclip 
        wl-clipboard 
        xsel
    )

    sudo apt install -y "${packages[@]}"

    end_func
    return 0
}

#: DOTFILES

# .gitconfig
overwrite_dot_gitconfig() {
    local git_config_file="$HOME/.gitconfig";

    if [[ -e $git_config_file ]]; then
        mv "$git_config_file" "$git_config_file.$START_DATE_TIME.$BACKUP_EXT"
    fi

    cp -f "$SCRIPT_DIR/.gitconfig" "$git_config_file"

    end_func
    return 0
}

# .bashrc
overwrite_dot_bashrc() {
    local bashrc_file="$HOME/.bashrc"

    if [[ -e $bashrc_file ]]; then
        mv "$bashrc_file" "$bashrc_file.$START_DATE_TIME.$BACKUP_EXT"
    fi
    
    cp -f "$SCRIPT_DIR/.bashrc" "$bashrc_file"

    end_func
    return 0
}

# .bash_aliases
overwrite_dot_bash_aliases() {
    local bash_aliases_file="$HOME/.bash_aliases";

    if [[ -e $bash_aliases_file ]]; then
        mv "$bash_aliases_file" "$bash_aliases_file.$START_DATE_TIME.$BACKUP_EXT"
    fi

    cp -f "$SCRIPT_DIR/.bash_aliases" "$bash_aliases_file"

    end_func
    return 0
}

# .bash_export_vars
overwrite_dot_bash_export_vars() {
    local bash_export_vars_file="$HOME/.bash_export_vars";

    if [[ -e $bash_export_vars_file ]]; then
        mv "$bash_export_vars_file" "$bash_export_vars_file.$START_DATE_TIME.$BACKUP_EXT"
    fi

    cp -f "$SCRIPT_DIR/.bash_export_vars" "$bash_export_vars_file"

    end_func
    return 0
}

# .zshrc
overwrite_dot_zshrc() {
    local zshrc_file="$HOME/.zshrc"

    if [[ -e $zshrc_file ]]; then
        mv "$zshrc_file" "$zshrc_file.$START_DATE_TIME.$BACKUP_EXT"
    fi
    
    cp -f "$SCRIPT_DIR/.zshrc" "$zshrc_file"

    end_func
    return 0
}

# .hidden
overwrite_dot_hidden() {
        local hidden_file="$HOME/.hidden"

    if [[ -e $hidden_file ]]; then
        mv "$hidden_file" "$hidden.$START_DATE_TIME.$BACKUP_EXT"
    fi
    
    cp -f "$SCRIPT_DIR/.hidden" "$hidden_file"

    end_func
    return 0
}

#: FONTS AND CUSTOM DYRECTORIES

# Nerd Fonts
verify_and_install_nerdfont() {
    local font_name="$(printf '%s' $1)"
    local fonts_rel_path=".local/share/fonts"
    local fonts_path="$HOME/$fonts_rel_path"
    local nerd_fonts_url="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0"

    if [[ ! (command_exists unzip || command_exists curl) ]]; then
        printf '%s' "The packages 'unzip' and 'curl' must be installed."
        return 1
    fi

    if [[ ! -d "$fonts_path" ]]; then
        mkdir -p "$HOME/$fonts_rel_path"
        (
            cd -- "$HOME/$fonts_rel_path"
            curl -L "$nerd_fonts_url/$font_name.zip" -o "$HOME/$fonts_rel_path/$font_name.zip"
            unzip -o "$font_name.zip" -d "$fonts_path"
            rm "$font_name.zip"
            cd "$WORKING_DIR"
        )
    fi

    if [[ -d "$fonts_path/$font_name" ]]; then
        end_func
        return 0
    else
        printf '%s' "Nerd Font ($font_name) failed to install."
        return 1
    fi

    return 1
}

# Custom user directory
create_custom_dirs() {
    mkdir -p "$HOME/Apps"

    end_func
    return 0
}

#: LOG FUNCTIONS

# Verify and initializes global variable $LOG_FILE_PATH
log_handle_file_path() {
    # Full path of log file already setted and initialized
    if [[ -v "$LOG_FILE_PATH" && -n "$LOG_FILE_PATH" ]]; then
        local log_file_dir="$(cd -- "$(dirname -- "$LOG_FILE_PATH")" && pwd)"
        local log_file_name="$(basename -- "$LOG_FILE_PATH")"

        # If log directory does not exist, create it and the file to
        if [[ ! -d "$log_file_dir" ]]; then
            ( mkdir -p "$log_file_dir" && touch "$LOG_FILE_PATH" ) || return 1
        # If log directory is not writable, change it and ensure the file creation
        elif [[ ! -w "$log_file_dir" ]]; then
            chmod +w "$log_file_dir" || return 1

            # If log file does not exist or is not writable, try to fix it:
            # ( ! EXIST OR ! WRITABLE ) AND ( CREATE AND WRITABLE )
            # If none of this worked, return error:
            # ( ABOVE CONDITIONS ) || return 1
            ( ( [[ ! -e "$LOG_FILE_PATH" ]] || [[ ! -w "$LOG_FILE_PATH" ]]) && (touch "$LOG_FILE_PATH" && chmod +w "$LOG_FILE_PATH") ) || return 1
        fi
    # Full path of log file neither declared or initialized
    else
        local temp_dir="$(mktemp -d)"
        local hashed_name="$(basename -- "$temp_dir")"
        declare -gr $LOG_FILE_PATH="$temp_dir/$SCRIPT_NAME.$hashed_name"
    fi

    return 0
}

# Save a log message in $LOG_FILE_PATH
# e.g. [24/07/2026 20:11:46]  - My custom log message of the script
log_message() {
    log_handle_file_path
    local date_time="$(date "+%d/%m/%Y %H:%M:%S")"
    printf "[%s] - %s\n" "$date_time" "$1" >> $LOG_FILE_PATH
    return 0
}

# Write a "40x equals sign" line with line break
log_message_separator() {
    log_handle_file_path
    printf "========================================\n" >> "$LOG_FILE_PATH"
    return 0
}

# Write a line break in log file
log_message_separator() {
    log_handle_file_path
    printf "\n" >> "$LOG_FILE_PATH"
    return 0
}

#: APPS

# Kitty Terminal
install_kitty_terminal() {
    # Handle fonts
    local fonts_rel_path=".local/share/fonts"
    cp -- -rf "$SCRIPT_DIR/$fonts_rel_path/*" "$HOME/$fonts_rel_path/"
    verify_and_install_nerdfont "NerdFontsSymbolsOnly"
    verify_and_install_nerdfont "SourceCodePro"
    verify_and_install_nerdfont "Ubuntu"
    verify_and_install_nerdfont "UbuntuMono"
    verify_and_install_nerdfont "UbuntuSans"

    # Download and install
    {
        curl -L "https://sw.kovidgoyal.net/kitty/installer.sh" |
        sh /dev/stdin launch="n"
    } 2>&1 | log_message

    # Set custom Kitty configs
    cp -- -rf "$SCRIPT_DIR/.config/kitty" "$HOME/.config/"

    # Global access to binaries
    sudo ln -sf "$HOME/.local/kitty.app/bin/kitty" "/usr/bin/kitty"
    sudo ln -sf "$HOME/.local/kitty.app/bin/kitten" "/usr/bin/kitten"
    
    # Desktop entries
    cp "$HOME/.local/kitty.app/share/applications/kitty.desktop" "$HOME/.local/share/applications/"
    cp "$HOME/.local/kitty.app/share/applications/kitty-open.desktop" "$HOME/.local/share/applications/"
    
    # Icons of desktop entries
    # Update the paths to the kitty and its icon in the kitty desktop file(s)
    sed -i "s|Icon=kitty|Icon=$(readlink -f ~)/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png|g" ~/.local/share/applications/kitty*.desktop
    sed -i "s|Exec=kitty|Exec=$(readlink -f ~)/.local/kitty.app/bin/kitty|g" ~/.local/share/applications/kitty*.desktop

    # Make xdg-terminal-exec (and hence desktop environments that support it use kitty)
    echo "kitty.desktop" > "$HOME/.config/xdg-terminals.list"

    end_func
    return 0
}

# ZSH shell
install_zsh_shell() {
    sudo apt install -y "zsh"

    end_func
    return 0
}

# oh-my-zsh shell manager
install_oh_my_zsh() {
    sh -c "$(curl -fsSL 'https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh')"

    cp -f "$HOME/.bash_aliases" "$HOME/.oh-my-zsh/custom/aliases.zsh"
    cp -f "$HOME/.bash_export_vars" "$HOME/.oh-my-zsh/custom/export_vars.zsh"
    overwrite_dot_zshrc

    external_themes_dir="$HOME/.oh-my-zsh/custom/external_themes"
    mkdir -p  "$external_themes_dir"
    (
        local theme_name="modern-dark-pro-capsule-ohmyzsh"
        cd -- "$external_themes_dir"
        git clone "https://github.com/dvigo/$theme_name.git"
        cp -f "$theme_name/modern-dark-pro-capsule.zsh-theme" "$HOME/.oh-my-zsh/custom/themes"
        rm -rf "$theme_name"
        cd "$WORKING_DIR"
    )

    end_func
    return 0
}

# fzf file searcher
_install_fzf() {
    fzf_installer="fzf_0.74.1_amd64.deb"
    curl -LO "https://github.com/junegunn/fzf/releases/download/v0.74.1/$fzf_installer"
    chmod +x "./$fzf_installer"
    sudo apt install -y "./$fzf_installer"
    rm -f "./$fzf_installer"

    end_func
    return 0
}

# zoxide searcher
_install_zoxide() {
    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
    find "$HOME" -type d -print0 | xargs -0 zoxide add

    end_func
    return 0
}

# Yazi Terminal file explorer (https://github.com/sxyazi/yazi/)
install_yazi() {
    _install_fzf
    _install_zoxide

    #::TODO: Realizar um tratamento
    yazi_installer="yazi-x86_64-unknown-linux-gnu.deb"
    curl -LO "https://github.com/sxyazi/yazi/releases/download/v26.5.6/$yazi_installer"
    chmod +x "./$yazi_installer"
    sudo apt install  -y "./$yazi_installer"
    rm -f "./$yazi_installer"

    #::TODO: Montar um array e iterar
    ya pkg add "yazi-rs/plugins:full-border"
    ya pkg add "yazi-rs/plugins:diff"
    ya pkg add "yazi-rs/flavors:catppuccin-mocha"
    ya pkg add "yazi-rs/plugins:git"
    ya pkg add "yazi-rs/plugins:mount"
    ya pkg add "yazi-rs/plugins:smart-enter"
}

# NVIM text editor
install_nvim() {
    local nvim_dir="$HOME/Apps/nvim"
    mkdir -p "$nvim_dir"

    (
        cd -- "$nvim_dir"
        curl -LO https://github.com/neovim/neovim/releases/download/v0.12.4/nvim-linux-x86_64.tar.gz
        tar xzvf nvim-linux-x86_64.tar.gz
        rm -f nvim-linux-x86_64.tar.gz
        sudo ln -sf "$nvim_dir/nvim-linux-x86_64/bin/nvim" "/usr/bin/nvim"
        cd -- "$WORKING_DIR"
    )

    if [[ -d "$HOME/.config/nvim" ]]; then
        mv "$HOME/.config/nvim" "$HOME/.config/nvim.$START_DATE_TIME.$BACKUP_EXT"
    fi

    cp -rf "$SCRIPT_DIR/.config/nvim" "$HOME/.config/nvim"

    # tree-sitter cli
    tree_sitter_cli_dirname="tree-sitter-cli-linux-x64"
    tree_sitter_cli_path="$HOME/Apps/$tree_sitter_cli_dirname"
    mkdir -p "$tree_sitter_cli_path"
    (
        cd -- "$tree_sitter_cli_path"
        curl -LO "https://github.com/tree-sitter/tree-sitter/releases/download/v0.26.11/$tree_sitter_cli_dirname.zip"
        unzip "$tree_sitter_cli_dirname.zip"
        rm -f "$tree_sitter_cli_dirname.zip"
        sudo ln -sf "$tree_sitter_cli_dir/tree-sitter" "/usr/bin/tree-sitter"
        cd -- "$WORKING_DIR"
    )

    # telescope
    #::TODO: Continuar
    sudo apt install -y ripgrep fd-find
}

# Manegement of the execution of the script
main() {
    log_message "Script de setup de ambiente Gnome + Bash" 
    initialize_script
    
    log_message "Atualizando os pacotes do sistema"
    upgrade_packages

    log_message "Instalando os pacotes base"
    install_base_packages

    log_message "Criando estrutura personalizada de diretórios"
    create_custom_dirs

    log_message "Copiando DOT FILES"
    overwrite_dot_gitconfig
    overwrite_dot_bash_export_vars
    overwrite_dot_bash_aliases
    overwrite_dot_bashrc
    overwrite_dot_hidden

    log_message "Instalando o terminal Kitty"
    install_kitty_terminal

    log_message "Instalando o shell ZSH"
    install_zsh_shell
    
    log_message "Instalando on-my-zsh"
    install_oh_my_zsh
    
    log_message "Instalando Yazi"
    install_yazi

    log_message "Instalando Nvim"
    install_nvim
}

main "$@"