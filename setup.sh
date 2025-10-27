#!/usr/bin/env bash

### INITIALIZE
sudo apt update -y
sudo apt upgrade -y
sudo apt autoremove -y
sudo apt autoclean -y

### yazi: Terminal file explorer (https://github.com/sxyazi/yazi/)
sudo apt install ffmpeg 7zip jq poppler-utils fd-find ripgrep fzf zoxide imagemagick
sudo snap install yazi --classic #TODO: learn to compile from source

### kitty: Terminal console emulator
ln -sf ~/.config/kitty/Catppuccin-Mocha.conf current-theme.conf

