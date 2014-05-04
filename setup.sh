#!/bin/bash -e

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

# Define the current distrib and the install command
if [[ "$(uname -s)" == "Darwin" ]]; then
    OS='mac'
    INSTALLCMD='brew install'
elif [[ "$(uname -s)" == "Linux" ]]; then
    if [ -f /etc/debian_version ]; then
        OS='debian'
        INSTALLCMD='aptitude install -y'
    elif [ -f /etc/redhat-release ]; then
        OS='redhat'
        INSTALLCMD='yum install -y'
    fi
fi

symlink_config()
{
    CONFFILE=$1
    SYMLINKNAME=$2
    if [ -f "${CUR_PATH}/config/$1.$OS" ]; then
        CONFFILE=$1.$OS
    fi

    echo -e ${INFO}"Adding ${CONFFILE} configuration ..."${DEFAULT}
    if [ -L ~/"${SYMLINKNAME}" ]; then
        echo -e ${WARN}"Removing old symlinked config ~/${SYMLINKNAME}"${DEFAULT}
        rm ~/${SYMLINKNAME}
    elif [ -f ~/"${SYMLINKNAME}" ]; then
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
    if [ -L ~/bin/"${SYMLINKNAME}" ]; then
        echo -e ${WARN}"Removing old symlinked script ~/bin/${SYMLINKNAME}"${DEFAULT}
        rm ~/bin/${SYMLINKNAME}
    elif [ -f ~/bin/"${SYMLINKNAME}" ]; then
        echo -e ${WARN}"Moving old script to ~/bin/${SYMLINKNAME}.bak"${DEFAULT}
        mv ~/bin/${SYMLINKNAME} ~/bin/${SYMLINKNAME}.bak
    fi
    ln -s ${CUR_PATH}/bin/${BINFILE} ~/bin/${SYMLINKNAME}
    echo -e ${OK}"Done.\n"${DEFAULT}
}

check_commands()
{
    CMD=$1
    if ! type "${CMD}" > /dev/null ;then
        echo -e ${WARN}"\n${CMD} needs to be installed\n"${DEFAULT}
        # Install the command or exit the script (option -e in the shebang) if failed
        if [[ -e $( which sudo 2>&1 ) ]]; then
            EXEC=`sudo $INSTALLCMD ${CMD}`
        else
            EXEC=`$INSTALLCMD ${CMD}`
        fi
        echo -e ${OK}"Successfully installed."${DEFAULT}
    fi
}

install_vim_bundle()
{
    REPO=$1
    BUNDLE=$(echo $REPO | cut -d'/' -f 2)
    if [ ! -d ~/.vim/bundle/"${BUNDLE}" ]; then
        git clone https://github.com/${REPO} ~/.vim/bundle/${BUNDLE}
    fi
}

# We need Git, Zsh Tmux to be installed
check_commands "zsh"
check_commands "tmux"
check_commands "vim"

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
if [ ! -d ~/.vim/autoload ]; then
    mkdir -p ~/.vim/autoload
fi
if [ ! -d ~/.vim/bundle ]; then
    mkdir -p ~/.vim/bundle
fi
# Install pathogen to manage vim plugins as bundles
curl -so ~/.vim/autoload/pathogen.vim https://raw.github.com/tpope/vim-pathogen/master/autoload/pathogen.vim
# Install plugins
install_vim_bundle scrooloose/nerdtree
install_vim_bundle kien/ctrlp.vim
install_vim_bundle kien/rainbow_parentheses.vim
install_vim_bundle chilicuil/conque
install_vim_bundle Lokaltog/vim-easymotion
install_vim_bundle nathanaelkane/vim-indent-guides
install_vim_bundle edsono/vim-matchit
install_vim_bundle tpope/vim-speeddating
install_vim_bundle maxbrunsfeld/vim-yankstack
install_vim_bundle tpope/vim-surround

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

echo -e ${OK}"\n\n You are all set. You can now define zsh as your default shell using the command :\nchsh -s $(which zsh)"${DEFAULT}

