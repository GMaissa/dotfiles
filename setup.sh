#!/bin/bash

# Repository of the oh-my-zsh project
OHMYZSHREPO=git@github.com:GMaissa/oh-my-zsh.git

# COLOR STYLES
INFO="\033[0;36m "
OK="\033[0;32m "
WARN="\033[0;33m "
ERROR="\033[1;31m "
DEFAULT="\033[0m "

# Current path
CUR_PATH=$(pwd)

# Distributions
DEBIAN=( "Debian" "Ubuntu" )
REDHAT=( "Rhel" "CentOS" )

if [[ "$(uname -s)" == "Darwin" ]]; then
    OS='mac'
    INSTALLCMD='brew install'
elif [[ "$(uname -s)" == "Linux" ]]; then
    if ! type "lsb_release" > /dev/null ;then
        echo -e ${ERROR}"\nlsb_release is needed to identify your Linux distribution\n"${DEFAULT}
        exit 1
    fi

    TESTVAR=$(lsb_release -si)
    
    if [[ ${DEBIAN[@]} =~ ${TESTVAR} ]]; then
        OS='debian'
        INSTALLCMD='aptitude install -y'
    elif [[ ${REDHAT[@]} =~ ${TESTVAR} ]]; then
        OS='redhat'
        INSTALLCMD='yum install -y'
    fi  
fi

symlink_config()
{
    CONFFILE=$1
    SYMLINKNAME=$2
    if [ -f ${CUR_PATH}/config/$1.$OS ]; then
        CONFFILE=$1.$OS
    fi

    echo -e ${INFO}"Adding ${CONFFILE} configuration ..."${DEFAULT}
    if [ -L ~/${SYMLINKNAME} ]; then
        echo -e ${WARN}"Removing old symlinked config ~/${SYMLINKNAME}"${DEFAULT}
        rm ~/${SYMLINKNAME}
    elif [ -f ~/${SYMLINKNAME} ]; then
        echo -e ${WARN}"Moving old config to ~/${SYMLINKNAME}.bak"${DEFAULT}
        mv ~/${SYMLINKNAME} ~/${SYMLINKNAME}.bak
    fi
    ln -s ${CUR_PATH}/config/${CONFFILE} ~/${SYMLINKNAME}
    echo -e ${OK}"Done.\n"${DEFAULT}
}

symlink_bin()
{
    BINFILE=$1
    SYMLINKNAME=$1
    echo -e ${INFO}"Adding ${CONFFILE} script ..."${DEFAULT}
    if [ -L ~/bin/${SYMLINKNAME} ]; then
        echo -e ${WARN}"Removing old symlinked script ~/bin/${SYMLINKNAME}"${DEFAULT}
        rm ~/bin/${SYMLINKNAME}
    elif [ -f ~/bin/${SYMLINKNAME} ]; then
        echo -e ${WARN}"Moving old script to ~/bin/${SYMLINKNAME}.bak"${DEFAULT}
        mv ~/bin/${SYMLINKNAME} ~/bin/${SYMLINKNAME}.bak
    fi
    ln -s ${CUR_PATH}/bin/${BINFILE} ~/bin/${SYMLINKNAME}
    echo -e ${OK}"Done.\n"${DEFAULT}
}

# We need Git, Zsh Tmux to be installed
# (ex: aptitude install git zsh tmux vim)
if ! type "zsh" > /dev/null ;then
    `$INSTALLCMD zsh`
    echo -e ${ERROR}"\nZSH needs to be installed\n"${DEFAULT}
    exit 1
elif ! type "tmux" > /dev/null ;then
    `$INSTALLCMD tmux`
    echo -e ${ERROR}"\nTMUX needs to be installed\n"${DEFAULT}
    exit 1
elif ! type "vim" > /dev/null ;then
    `$INSTALLCMD vim`
    echo -e ${ERROR}"\nVIM needs to be installed\n"${DEFAULT}
    exit 1
fi

# Cloning the oh-my-zsh project if not already done
if [ ! -d ~/.oh-my-zsh ]; then
    echo -e ${INFO}"Cloning OH MY ZSH repo ..."${DEFAULT}
    git clone ${OHMYZSHREPO} ~/.oh-my-zsh
    echo -e ${OK}"Done.\n"${DEFAULT}
fi

# Apply configuration for zsh
symlink_config "zsh" ".zshrc"

# Enable common aliases
symlink_config "aliases" ".aliases"

# Apply configuration for tmux
symlink_config "tmux" ".tmux.conf"

# Apply configuration for vim
symlink_config "vim" ".vimrc"
if [ ! -d ~/.vim/backup ]; then
    mkdir -p ~/.vim/backup
fi

# Apply configuration for git
symlink_config "git" ".gitconfig"

# Apply configuration for ssh
if [ $# -eq 1 -a "$1" = "with-ssh" ]; then
    # Adding a few usefull scripts
    # You will be able to split the ssh configuration into multiple files
    # ex: config.work config.personal ...
    if [ ! -d ~/bin ]; then
        mkdir ~/bin
    fi
    symlink_bin "ssh"
    symlink_bin "ssh-copy-id"

    if [ ! -d ~/.ssh ]; then
        mkdir ~/.ssh
    fi
    symlink_config "ssh" ".ssh/config"
fi
