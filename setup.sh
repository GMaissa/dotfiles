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

if ! type "zsh" > /dev/null; then
    echo ${ERROR}"\nZSH needs to be installed\n"${DEFAULT}
    exit 1
fi
if ! type "tmux" > /dev/null; then
    echo ${ERROR}"\nTMUX needs to be installed\n"${DEFAULT}
    exit 1
fi
if ! type "vim" > /dev/null; then
    echo ${ERROR}"\nVIM needs to be installed\n"${DEFAULT}
    exit 1
fi

CUR_PATH=$(pwd)

if [ ! -d ~/.oh-my)zsh ]; then
    echo ${INFO}"Cloning OH MY ZSH repo ..."${DEFAULT}
    git clone ${OHMYZSHREPO} ~/.oh-my-zsh
    echo ${OK}"Done.\n"${DEFAULT}
fi

symlinkConfig "zsh" ".zshrc"

symlinkConfig "aliases" ".aliases"

symlinkConfig "tmux" ".tmux.conf"

symlinkConfig "vim" ".vimrc"
if [ ! -d ~/.vim/backup ]; then
    mkdir -p ~/.vim/backup
fi

symlinkConfig "git" ".gitconfig"

if [ ! -d ~/.ssh ];then
    mkdir ~/.ssh
if
symlinkConfig "ssh" ".ssh/config"

if [ ! -d ~/bin ]; then
    mkdir ~/bin
fi
ln -s ${CUR_PATH}/bin/ssh ~/bin/ssh
ln -s ${CUR_PATH}/bin/ssh-copy-id ~/bin/ssh-copy-id

symlinkConfig()
{
    CONFFILE=$1
    SYMLINKNAME=$2
    echo ${INFO}"Adding ${CONFFILE} configuration ..."${DEFAULT}
    if [ -f ~/${SYMLINKNAME} ];then
        echo ${WARN}"Moving old config to ~/${SYMLINKNAME}.bak"${DEFAULT}
        mv ~/${SYMLINKNAME} ~/${SYMLINKNAME}.bak
    elif [ -L ~/${SYMLINKNAME} ];then
        echo ${WARN}"Removing old symlinked config ~/${SYMLINKNAME}"${DEFAULT}
        rm ~/${SYMLINKNAME}
    fi
    ln -s ${CUR_PATH}/config/${CONFFILE} ~/${SYMLINKNAME}
    echo ${OK}"Done.\n"${DEFAULT}
}
