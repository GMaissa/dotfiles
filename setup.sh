#!/bin/bash

#aptitude install 'git zsh tmux vim'

# Repository of the oh-my-zsh project
OHMYZSHREPO=git@github.com:GMaissa/oh-my-zsh.git

# COLOR STYLES
INFO='\033[0;36m'
OK='\033[0;32m'
WARN='\033[0;33m'
ERROR='\033[1;31m'
DEFAULT='\033[0m'

if [ ! type "git" > /dev/null ]; then
	echo ${ERROR}"You need git to be installed to perform the setup"${DEFAULT}
	exit 1
fi

if [ ! -f /bin/zsh ]; then
	echo ${ERROR}"ZSH needs to be installed"${DEFAULT}
	exit 1
fi

CUR_PATH=$(pwd)

echo ${INFO}"Cloning OH MY ZSH repo ..."${DEFAULT}
git clone ${OHMYZSHREPO} ~/.oh-my-zsh
echo ${OK}'Done.'${DEFAULT}

echo ${INFO}"Adding ZSH configuration ..."${DEFAULT}
if [ -f ~/.zshrc ]; then
	echo ${WARN}"Moving old config to ~/.zshrc.bak"${DEFAULT}
    mv ~/.zshrc ~/.zshrc.bak
fi
ln -s ${CUR_PATH}/zshrc ~/.zshrc
echo ${OK}'Done.'${DEFAULT}

echo ${INFO}"Adding command aliases ..."${DEFAULT}
if [ -f ~/.aliases ]; then
	echo ${WARN}"Moving old config to ~/.aliases.bak"${DEFAULT}
    mv ~/.aliases ~/.aliases.bak
fi
ln -s ${CUR_PATH}/aliases ~/.aliases
echo ${OK}'Done.'${DEFAULT}

echo ${INFO}"Adding TMUX configuration ..."${DEFAULT}
if [ -f ~/.tmux.conf ]; then
	echo ${WARN}"Moving old config to ~/.tmux.conf.bak"${DEFAULT}
    mv ~/.tmux.conf ~/.tmux.conf.bak
fi
ln -s ${CUR_PATH}/tmux.conf ~/.tmux.conf
echo ${OK}'Done.'${DEFAULT}

echo ${INFO}"Adding VIM configuration ..."${DEFAULT}
if [ -f ~/.vimrc ];then
	echo ${WARN}"Moving old config to ~/.vimrc.bak"${DEFAULT}
    mv ~/.vimrc ~/.vimrc.bak
fi
ln -s ${CUR_PATH}/vimrc ~/.vimrc
echo ${OK}'Done.'${DEFAULT}

echo ${INFO}"Adding SSH configuration ..."${DEFAULT}
if [ ! -d ~/.ssh ];then
    mkdir ~/.ssh
elif [ -f ~/.ssh/config ];then
	echo ${WARN}"Moving old config to ~/.ssh/config.bak"${DEFAULT}
    mv ~/.ssh/config ~/.ssh/config.bak
fi
ln -s ${CUR_PATH}/ssh.conf ~/.ssh/config
echo ${OK}'Done.'${DEFAULT}

echo ${INFO}"Adding GIT configuration ..."${DEFAULT}
if [ -f ~/.gitconfig ];then
	echo ${WARN}"Moving old config to ~/.gitconfig.bak"${DEFAULT}
    mv ~/.gitconfig ~/.gitconfig.bak
fi
ln -s ${CUR_PATH}/gitconfig ~/.gitconfig
echo ${OK}'Done.'${DEFAULT}
