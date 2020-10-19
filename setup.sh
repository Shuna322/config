#!/bin/bash

if [ "$EUID" -eq 0 ]
      then echo "Please do not run as root"
            exit
fi

helpFunction()
{
   echo ""
   echo "Usage: $0 -a for Arch or -d for Debian "
   echo -e "\t-o Define OS type Arch or Debian"
   exit 1 # Exit script after printing help
}

while getopts "ad" opt
do
   case "$opt" in
      a ) OS="Arch" ;;
      d ) OS="Deb" ;;
      ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
   esac
done

if [ -z "$OS" ]
then
   echo "Please enter OS version";
   helpFunction
fi

# Install software if it's Arch
if [ $OS == "Arch" ]; then
	yes | sudo pacman -Syu
	if [ $? -ne 0 ]; then
		echo "Please double check the OS distro"
		exit $?
    fi
	yes | sudo pacman -S grep colordiff iproute2 net-tools sudo tar unrar zsh git tmux neovim wget htop vi vim openssh python3 code
fi

if [ $OS == "Deb" ]; then
	echo "Not implemented yet"
    exit 0
fi 


# Install oh-my-zsh
sh -c "$(curl -fsSL --insecure https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# Download antigen
curl -L --insecure git.io/antigen > $HOME/antigen.zsh
cp ./antigen.rc $HOME/antigen.rc
mv $HOME/.zshrc $HOME/.zshrc.bak
cp ./.zshrc $HOME/.zshrc
cp ./.p10k.zsh $HOME/.p10k.zsh

if [ $OS == "Arch" ]; then
    sed -i 's/UPDATECOMMAND/sudo pacman -Syu/' $HOME/.zshrc
fi
if [ $OS == "Deb" ]; then    
    sed -i 's/UPDATECOMMAND/sudo apt update && sudo apt upgrade/' $HOME/.zshrc
fi

source $HOME/.zshrc

