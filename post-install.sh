#!/bin/bash

DIR_HOME="/home/jose"

if [ -d $DIR_HOME ] && [ ! -f "$DIR_HOME/.gitconfig" ]; then
    cat "./.bashrc" >> "$DIR_HOME/.bashrc"
    cat "./.bash_functions" >> "$DIR_HOME/.bash_functions"
    cp -f ".gitconfig" $DIR_HOME
    cp -Rf "./.ssh" $DIR_HOME
else
    echo -e "Diretório de usuário '/home/jose' não foi encontrado, ou os arquivos de configuração já foram escritos.\n"
fi

echo -e "\n\n>> Adicionando repositórios de terceiros ao sources.list\n\n"

sudo apt install -y software-properties-common
sudo add-apt-repository ppa:linuxuprising/java

echo -e "\n\n>> Atualizando a lista de repositórios\n\n"
sudo apt update

echo -e "\n\n>> Excluindo programas indesejados\n\n"
sudo apt -y purge thunderbird* rhythmbox*

echo -e "\n\n>> Atualizando os programas pré-instalados\n\n"
sudo apt -y upgrade

echo -e "\n\n>> Atualizando o sistema operacional\n\n"
sudo apt -y dist-upgrade

echo -e "\n\n>> Instalando programas\n\n"
sudo apt install -y \
gparted \
vlc \
vim \
unrar \
snap \
snapd

echo -e "\n\n>> Instalando Java 14 (necessita intervenção humana):\n"
sudo apt install oracle-java14-installer

# Instalação via SNAP do Postman
sudo snap install postman

sudo apt autoremove
sudo apt autoclean

echo -e "\n\nProgramas instalados:\n"
echo -e "- gparted\n"
echo -e "- vlc\n"
echo -e "- Postman\n"
echo -e "- VIM\n"
echo -e "- unrar\n"
echo -e "- snap\n"
echo -e "- Java 14\n"

echo -e "\n\nFalta instalar:\n"
echo -e "- VSCode\n"
echo -e "- Dropbox\n"
echo -e "- Google Chrome\n"
echo -e "- PHPStorm \n"
echo -e "- Mysql Workbench \n"
