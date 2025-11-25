#!/usr/bin/env bash

## INITIALIZE
cd ~
sudo apt update -y && sudo apt upgrade -y && sudo apt autoremove -y && sudo apt autoclean -y

sudo apt install git \
  vlc \
  curl \
  wget \
  flatpak \
  gnome-software-plugin-flatpak

if [! -d ~/apps]; then
  mkdir ~/apps
fi

if [! -d ~/jollab/dev]; then
  mkdir -p ~/jollab/dev
  git clone -q git@github.com:jmacedo/dot-files.git ~/jollab/dev
fi

ln -s ~/jollab/dev/dot-files/home/.gitconfig ~

## oh-my-bash: BASH MANAGER
# Installed from source, cloning the github repository and following developer instructions.
if [-f "~/.bashrc"]; then
  mv ~/.bashrc ~/.bashrc.original
fi

bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)" --unattended

if [-f "~/.bashrc"]; then
  mv ~/.bashrc ~/.bashrc.omb
fi

if [-f "~/.bash_aliases"]; then
  mv ~/.bash_aliases ~/.bash_aliases.original
fi

ln -s ~/jollab/dev/dot-files/home/.bashrc ~
ln -s ~/jollab/dev/dot-files/home/.bash_aliases ~

## tmux: TERMINAL MULTIPLEXER
sudo apt install tmux
if [-f "~/.tmux.conf"]; then
  mv ~/.tmux.conf ~/.tmux.conf.original
fi
ln -s ~/jollab/dev/dot-files/home/.tmux.conf ~/.tmux.conf

## alacritty: TERMINAL CONSOLE
sudo apt install alacritty
if [-d "~/.config/alacritty"]; then
  mv ~/.config/alacritty ~/.config/alacritty.original
fi

ln -s ~/jollab/dev/dot-files/home/.config/alacritty ~/.config

## vim/neovim: TEXT EDITORS
sudo apt install vim
mkdir ~/apps/nvim-0.11.4
cd ~/apps/nvim-0.11.4
curl -fO https://github.com/neovim/neovim/releases/download/v0.11.4/nvim-linux-x86_64.tar.gz
tar xzvf nvim-linux-x86_64.tar.gz
sudo ln -s ~/apps/nvim-0.11.4/bin/nvim /usr/bin/nvim
ls -s ~/jollab/dev/dot-files/home/.config/nvim ~/.config/nvim

## yazi: TERMINAL FILE EXPLORER (https://github.com/sxyazi/yazi/)
sudo apt install ffmpeg 7zip jq poppler-utils fd-find ripgrep fzf zoxide imagemagick
sudo snap install yazi --classic #TODO: learn to compile from source

### fzf: Terminal Fuzzy Finder
# The fzf package installed to yazi have to be overrided with a newer version. I just downloaded the latest and copy it to /usr/bin/
curl -fO https://github.com/junegunn/fzf/releases/download/v0.66.1/fzf-0.66.1-linux_amd64.tar.gz
