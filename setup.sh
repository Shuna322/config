#!/bin/bash

if [ "$EUID" -eq 0 ]
      then echo "Please do not run as root"
            exit
fi

helpFunction()
{
   echo ""
   echo "Usage: $0 -p For pacman -a For apt -y For yum "
   exit 1 # Exit script after printing help
}

while getopts "pay" opt
do
   case "$opt" in
      p ) pacman=1 ;;
      a ) apt=1 ;;
      y ) yum=1 ;;
      ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
   esac
done

if [[ -z ${pacman+x} && -z ${apt+x} && -z ${yum+x} ]]
then
   echo "Please select package manager";
   helpFunction
fi

if (( pacman + apt + yum > 1 )); then
  echo "Only one of '-p' '-a' '-y' is allowed"
  exit 1
fi

# Install software if it's Arch
if [ $pacman ]; then
	yes | sudo pacman -Syu
	if [ $? -ne 0 ]; then
		echo "Please double check the package manager"
		exit $?
    fi
	yes | sudo pacman -S grep colordiff iproute2 net-tools unzip sudo tar unrar zsh git tmux neovim wget htop vim openssh python3

elif [ $apt ]; then
  sudo apt update && sudo apt upgrade -y
  if [ $? -ne 0 ]; then
    echo "Please double check the package manager"
    exit $?
  fi
  sudo apt install -y grep colordiff iproute2 net-tools unzip sudo tar unrar zsh git tmux neovim wget htop vim python3

elif [ $yum ]; then
    echo "Not implemented yet"
    exit 1
fi

# Install oh-my-zsh
yes | sh -c "$(curl -fsSL --silent --insecure https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# Download antigen
curl -L --silent --insecure git.io/antigen > $HOME/antigen.zsh
/bin/cp -f ./.antigenrc $HOME/.antigenrc
# Backup zshrc
mv $HOME/.zshrc $HOME/.zshrc.bak
# Copy config files
/bin/cp -f ./.zshrc $HOME/.zshrc
/bin/cp -f ./.p10k.zsh $HOME/.p10k.zsh
/bin/cp -f ./.vimrc $HOME/.vimrc
/bin/cp -f ./.tmux.conf* $HOME/

# Install colors script
git clone https://gitlab.com/dwt1/shell-color-scripts.git
cd shell-color-scripts
rm -rf /opt/shell-color-scripts || return 1
sudo mkdir -p /opt/shell-color-scripts/colorscripts || return 1
sudo cp -rf colorscripts/* /opt/shell-color-scripts/colorscripts
sudo cp colorscript.sh /usr/bin/colorscript
# optional for zsh completion
sudo cp zsh_completion/_colorscript /usr/share/zsh/site-functions


mkdir $HOME/.vim/colors
curl --insecure -L https://raw.githubusercontent.com/sonph/onehalf/master/vim/colors/onehalfdark.vim -o $HOME/.vim/colors/onehalfdark.vim



#echo "Downloading and installing Nerd Hack font"
#curl -o ./Hack_Nerd.zip --silent --insecure -L https://github.com/source-foundry/Hack/releases/download/v3.003/Hack-v3.003-ttf.zip
#mkdir Hack_Nerd; unzip -o Hack_Nerd.zip -d ./Hack_Nerd
#sudo cp ./Hack_Nerd/ttf/*.ttf /usr/share/fonts/

if [ $pacman ]; then
    sed -i 's/UPDATECOMMAND/sudo pacman -Syu/' $HOME/.zshrc
fi
if [ $apt ]; then    
    sed -i 's/UPDATECOMMAND/sudo apt update && sudo apt upgrade/' $HOME/.zshrc
fi

ps -ef | grep 'zsh' | grep -v grep | awk '{print $2}' | xargs -r kill -9 2>/dev/null

zsh
