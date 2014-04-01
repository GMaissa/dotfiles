#!/bin/sh

#aptitude install 'git zsh tmux vim'

# Repository of the oh-my-zsh project
OHMYZSHREPO=git@github.com:GMaissa/oh-my-zsh.git

# COLOR STYLES
INFO='\033[0;36m'
OK='\033[0;32m'
WARN='\033[0;33m'
ERROR='\033[1;31m'
DEFAULT='\033[0m'

symlink_config()
{
    CONFFILE=$1
    SYMLINKNAME=$2
    echo ${INFO}"Adding ${CONFFILE} configuration ..."${DEFAULT}
    if [ -L ~/${SYMLINKNAME} ]; then
        echo ${WARN}"Removing old symlinked config ~/${SYMLINKNAME}"${DEFAULT}
        rm ~/${SYMLINKNAME}
    elif [ -f ~/${SYMLINKNAME} ]; then
        echo ${WARN}"Moving old config to ~/${SYMLINKNAME}.bak"${DEFAULT}
        mv ~/${SYMLINKNAME} ~/${SYMLINKNAME}.bak
    fi
    ln -s ${CUR_PATH}/config/${CONFFILE} ~/${SYMLINKNAME}
    echo ${OK}"Done.\n"${DEFAULT}
}

symlink_bin()
{
    BINFILE=$1
    SYMLINKNAME=$1
    echo ${INFO}"Adding ${CONFFILE} script ..."${DEFAULT}
    if [ -L ~/bin/${SYMLINKNAME} ]; then
        echo ${WARN}"Removing old symlinked script ~/bin/${SYMLINKNAME}"${DEFAULT}
        rm ~/bin/${SYMLINKNAME}
    elif [ -f ~/bin/${SYMLINKNAME} ]; then
        echo ${WARN}"Moving old script to ~/bin/${SYMLINKNAME}.bak"${DEFAULT}
        mv ~/bin/${SYMLINKNAME} ~/bin/${SYMLINKNAME}.bak
    fi
    ln -s ${CUR_PATH}/bin/${BINFILE} ~/bin/${SYMLINKNAME}
    echo ${OK}"Done.\n"${DEFAULT}
}

if ! type "zsh" > /dev/null ;then
    echo ${ERROR}"\nZSH needs to be installed\n"${DEFAULT}
    exit 1
fi
if ! type "tmux" > /dev/null ;then
    echo ${ERROR}"\nTMUX needs to be installed\n"${DEFAULT}
    exit 1
fi
if ! type "vim" > /dev/null ;then
    echo ${ERROR}"\nVIM needs to be installed\n"${DEFAULT}
    exit 1
fi

CUR_PATH=$(pwd)

if [ ! -d ~/.oh-my-zsh ]; then
    echo ${INFO}"Cloning OH MY ZSH repo ..."${DEFAULT}
    git clone ${OHMYZSHREPO} ~/.oh-my-zsh
    echo ${OK}"Done.\n"${DEFAULT}
fi

symlink_config "zsh" ".zshrc"

symlink_config "aliases" ".aliases"

symlink_config "tmux" ".tmux.conf"

symlink_config "vim" ".vimrc"
if [ ! -d ~/.vim/backup ]; then
    mkdir -p ~/.vim/backup
fi

symlink_config "git" ".gitconfig"

if [ ! -d ~/.ssh ]; then
    mkdir ~/.ssh
fi
symlink_config "ssh" ".ssh/config"

if [ ! -d ~/bin ]; then
    mkdir ~/bin
fi
symlink_bin "ssh"
symlink_bin "ssh-copy-id"
