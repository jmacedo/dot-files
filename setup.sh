#!/usr/bin/env bash

date_time=$(date "+%Y%m%d%H%M%S");
git_config_file="~/.gitconfig";
bashrc_file="~/.bashrc";
bash_aliases_file="~/.bash_aliases";
bash_export_vars_file="~/.bash_export_vars";
zshrc_file="~/.zshrc";

#: UPGRADE

sudo apt update -y;
sudo apt upgrade -y;
sudo apt autoremove -y;
sudo apt autoclean -y;

#: DOT FILES

#> GITCONFIG
if [[ -e $git_config_file ]]; then
    mv $git_config_file "$git_config_file.$date_time.bak"
fi
cp -f .gitconfig $git_config_file

#> BASHRC
if [[ -e $bashrc_file ]]; then
    mv $bashrc_file "$bashrc_file.$date_time.bak"
fi
cp -f .bashrc $bashrc_file

#> BASH ALIASES
if [[ -e $bash_aliases_file ]]; then
    mv $bash_aliases_file "$bash_aliases_file.$date_time.bak"
fi
cp -f .bash_aliases $bash_aliases_file

#> BASH EXPORT VARS
if [[ -e $bash_export_vars_file ]]; then
    mv $bash_export_vars_file "$bash_export_vars_file.$date_time.bak"
fi
cp -f .bash_export_vars $bash_export_vars_file

#> .CONFIG
# KITTY
cp -rf ".config/kitty" "~/.config/"

#: FONTS
fonts_path=".local/share/fonts"
local_fonts_path="~/$fonts_path"
nerd_fonts_url="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0"
nerd_fonts_font="NerdFontsSymbolsOnly"
sauce_code_font="SourceCodePro"
ubuntu_font="Ubuntu"
ubuntu_mono_font="UbuntuMono"
ubuntu_sans_font="UbuntuSans"

cp -rf "$fonts_path/*" "$local_fonts_path/"

sudo apt install -y unzip

#> NERD FONTS SYMBOLS ONLY
if [[ -d "$nerd_fonts_font" ]]; then
    curl -LO "$nerd_fonts_url/$nerd_fonts_font.zip"
    unzip -o "$nerd_fonts_font.zip" -d "$local_fonts_path"
    rm "$nerd_fonts_font.zip"
fi

#> SAUCE CODE PRO NERD FONT
if [[ -d "$sauce_code_font" ]]; then
    curl -LO "$nerd_fonts_url/$sauce_code_font.zip"
    unzip -o "$sauce_code_font.zip" -d "$local_fonts_path"
    rm "$sauce_code_font.zip"
fi

#> UBUNTU NERD FONT
if [[ -d "$ubuntu_font" ]]; then
    curl -LO "$nerd_fonts_url/$ubuntu_font.zip"
    unzip -o "$ubuntu_font.zip" -d "$local_fonts_path"
    rm "$ubuntu_font.zip"
fi

#> UBUNTU MONO NERD FONT
if [[ -d "$ubuntu_mono_font" ]]; then
    curl -LO "$nerd_fonts_url/$ubuntu_mono_font.zip"
    unzip -o "$ubuntu_mono_font.zip" -d "$local_fonts_path"
    rm "$ubuntu_mono_font.zip"
fi

#> UBUNTU SANS NERD FONT
if [[ -d "$ubuntu_sans_font" ]]; then
    curl -LO "$nerd_fonts_url/$ubuntu_sans_font.zip"
    unzip -o "$ubuntu_sans_font.zip" -d "$local_fonts_path"
    rm "$ubuntu_sans_font.zip"
fi

#: SHELL

#> ZSH

sudo apt install -y zsh curl

#: APPS

#> OH MY ZSH

sh -c "$(curl -fsSL 'https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh')"
##: CAREFULL: EXTERNAL SCRIPT
# .bash_aliases
cp -f ".bash_aliases" "~/.oh-my-zsh/custom/aliases.zsh"
# .bash_export_vars
cp -f .bash_export_vars "~/.oh-my-zsh/custom/export_vars.zsh"
# .zshrc
if [[ -e $zshrc_file ]]; then
    mv $zshrc_file "$zshrc_file.$date_time.bak"
fi
cp -f .zshrc $zshrc_file

external_themes="~/.oh-my-zsh/custom/external_themes"
current_pwd="$(pwd)"
mkdir -p  "$external_themes"
cd "$external_themes"
git clone "https://github.com/dvigo/modern-dark-pro-capsule-ohmyzsh.git"
cp -f "modern-dark-pro-capsule-ohmyzsh/modern-dark-pro-capsule.zsh-theme" ~/.oh-my-zsh/custom/themes
cd "$current_pwd"

#> KITTY TERMINAL

curl -L "https://sw.kovidgoyal.net/kitty/installer.sh" | sh /dev/stdin
##: CAREFULL: EXTERNAL SCRIPT

sudo ln -sf "~/.local/kitty.app/bin/kitty" "/usr/bin/kitty"
sudo ln -sf "~/.local/kitty.app/bin/kitten" "/usr/bin/kitten"
cp "~/.local/kitty.app/share/applications/kitty.desktop" "~/.local/share/applications/"
cp "~/.local/kitty.app/share/applications/kitty-open.desktop" "~/.local/share/applications/"
# Update the paths to the kitty and its icon in the kitty desktop file(s)
sed -i "s|Icon=kitty|Icon=$(readlink -f ~)/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png|g" ~/.local/share/applications/kitty*.desktop
sed -i "s|Exec=kitty|Exec=$(readlink -f ~)/.local/kitty.app/bin/kitty|g" ~/.local/share/applications/kitty*.desktop
# Make xdg-terminal-exec (and hence desktop environments that support it use kitty)
echo "kitty.desktop" > "~/.config/xdg-terminals.list"

#> YAZI: Terminal file explorer (https://github.com/sxyazi/yazi/)

# fzf
fzf_installer="fzf_0.74.1_amd64.deb"
curl -LO "https://github.com/junegunn/fzf/releases/download/v0.74.1/$fzf_installer"
chmod +x "./$fzf_installer"
sudo apt install -y "./$fzf_installer"

# zoxide
curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
find "$HOME" -type d -print0 | xargs -0 zoxide add

# yazi extended functionalities
sudo apt install -y file ffmpeg 7zip jq poppler-utils fdutils fzf zoxide imagemagick xclip wl-clipboard xsel

# yazi app
yazi_installer="yazi-x86_64-unknown-linux-gnu.deb"
curl -LO "https://github.com/sxyazi/yazi/releases/download/v26.5.6/$yazi_installer"
chmod +x "./$yazi_installer"
sudo apt install  -y "./$yazi_installer"

ya pkg add yazi-rs/plugins:full-border
ya pkg add yazi-rs/plugins:diff
ya pkg add yazi-rs/flavors:catppuccin-mocha
ya pkg add yazi-rs/plugins:git
ya pkg add yazi-rs/plugins:mount
ya pkg add yazi-rs/plugins:smart-enter