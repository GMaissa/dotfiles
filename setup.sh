#!/bin/bash

. $(dirname $0)/abstract.sh

# Repository of the oh-my-zsh project
OHMYZSHREPO=git@github.com:robbyrussell/oh-my-zsh.git

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
    if [ -f "${CUR_PATH}/$1.$OS" ]; then
        CONFFILE=$1.$OS
    fi
    STEPMSG="Applying ${CONFFILE} config"
    ADDIMSG=""

    if [ -L ~/"${SYMLINKNAME}" ]; then
        rm ~/${SYMLINKNAME}
        #ADDIMSG=${WARN}"Old symlinked config ~/${SYMLINKNAME} removed"${DEFAULT}
    elif [[ -f ~/"${SYMLINKNAME}" || -d ~/"${SYMLINKNAME}" ]]; then
        mv ~/${SYMLINKNAME} ~/${SYMLINKNAME}.bak
        ADDIMSG=${WARN}"Old config moved to ~/${SYMLINKNAME}.bak"${DEFAULT}
    fi

    echo -ne "${PROCESSMSG}${STEPMSG}"\\r
    OUTPUT=$(ln -s ${CUR_PATH}/${CONFFILE} ~/${SYMLINKNAME} 2>&1 >/dev/null)
    if [ $? -ne 0 ]; then
        echo -e "${ERRORMSG}${STEPMSG}"
        echo -e ${OUTPUT}
        exit 1
    fi
    echo -e "${SUCCESSMSG}${STEPMSG}"
    if [ "${ADDIMSG}" != "" ];then
        echo -e ${ADDIMSG} 
    fi
}

symlink_bin()
{
    BINFILE=$1
    SYMLINKNAME=$1
    echo -e ${INFO}"Adding ${CONFFILE} script ..."${DEFAULT}
    if [ -L ~/bin/"${SYMLINKNAME}" ]; then
        #echo -e ${WARN}"Removing old symlinked script ~/bin/${SYMLINKNAME}"${DEFAULT}
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
    STEPMSG="Installing ${CMD}"
    if ! type "${CMD}" >/dev/null 2>&1 ;then
        echo -ne "${PROCESSMSG}${STEPMSG}"\\r
        # Install the command or exit the script (option -e in the shebang) if failed
        if [[ "${OS}" != "mac" && -e $( which sudo 2>&1 ) ]]; then
            OUTPUT=$(sudo $INSTALLCMD ${CMD} 2>&1 >/dev/null)
        else
            OUTPUT=$($INSTALLCMD ${CMD} 2>&1 >/dev/null)
        fi
        if [ $? -ne 0 ]; then
            echo -e "${ERRORMSG}${STEPMSG}"
            echo -e ${OUTPUT}
            exit 1
        fi
        echo -e "${SUCCESSMSG}${STEPMSG}"
    fi
}

install_vim_bundle()
{
    REPO=$1
    BUNDLE=$(echo $REPO | cut -d'/' -f 2)
    if [ ! -d ~/.vim/bundle/"${BUNDLE}" ]; then
        STEPMSG="Installing VIM bundle ${BUNDLE}"
        echo -ne "${PROCESSMSG}${STEPMSG}"\\r
        OUTPUT=$(git clone https:#github.com/${REPO} ~/.vim/bundle/${BUNDLE} 2>&1 >/dev/null)
        if [ $? -ne 0 ]; then
            echo -e "${ERRORMSG}${STEPMSG}"
            echo -e ${OUTPUT}
            exit 1
        fi
        echo -e "${SUCCESSMSG}${STEPMSG}"
    fi
}

install_vim_plugin()
{
    REPO=$1
    PLUGIN=$2
    if [ ! -d ~/.vim/plugin ]; then
        mkdir ~/.vim/plugin
    fi
    if [ ! -d ~/.vim/plugin/"${PLUGIN}" ]; then
        STEPMSG="Installing VIM plugin ${PLUGIN}"
        echo -ne "${PROCESSMSG}${STEPMSG}"\\r
        OUTPUT=$(wget -P ~/.vim/plugin/ https://raw.githubusercontent.com/${REPO}/master/plugin/${PLUGIN} 2>&1 >/dev/null)
        if [ $? -ne 0 ]; then
            echo -e "${ERRORMSG}${STEPMSG}"
            echo -e ${OUTPUT}
            exit 1
        fi
        echo -e "${SUCCESSMSG}${STEPMSG}"
    fi
}

# We need Git, Zsh Tmux to be installed
check_commands "zsh"
check_commands "tmux"
check_commands "vim"

# Cloning the oh-my-zsh project if not already done
if [ ! -d ~/.oh-my-zsh ]; then
    STEPMSG="Cloning OH-MY-ZSH repo"
    echo -ne "${PROCESSMSG}${STEPMSG}"\\r
    OUTPUT=$(git clone ${OHMYZSHREPO} ~/.oh-my-zsh 2>&1 >/dev/null)
    if [ $? -ne 0 ]; then
        echo -e "${ERRORMSG}${STEPMSG}"
        echo -e ${OUTPUT}
        exit 1
    fi
    echo -e "${SUCCESSMSG}${STEPMSG}"
fi
for file in oh-my-zsh/themes/*
do
    if [ -f "$file" ];then
        THEME=$(basename "$file")
        symlink_config "$file" ".oh-my-zsh/themes/${THEME}"
    fi
done
for dir in oh-my-zsh/plugins/*
do
    if [ -d "$dir" ];then
        PLUGIN=$(basename "$dir")
        symlink_config "$dir" ".oh-my-zsh/plugins/${PLUGIN}"
    fi
done

# Apply configuration for zsh
symlink_config "config/zsh" ".zshrc"

# Enable common aliases
symlink_config "config/aliases" ".aliases"

# Apply configuration for tmux
symlink_config "config/tmux" ".tmux.conf"

# Apply configuration for vim
symlink_config "config/vim" ".vimrc"
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
curl -so ~/.vim/autoload/pathogen.vim https:#raw.github.com/tpope/vim-pathogen/master/autoload/pathogen.vim
# Install bundles
install_vim_bundle scrooloose/nerdtree
install_vim_bundle kien/ctrlp.vim
install_vim_bundle kien/rainbow_parentheses.vim
install_vim_bundle chilicuil/conque
install_vim_bundle Lokaltog/vim-easymotion
install_vim_bundle nathanaelkane/vim-indent-guides
install_vim_bundle edsono/vim-matchit
install_vim_bundle tpope/vim-speeddating
install_vim_bundle tpope/vim-surround

# Install plugins
install_vim_plugin jamessan/vim-gnupg gnupg.vim

# Apply configuration for git
symlink_config "config/git" ".gitconfig"

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
    symlink_config "config/ssh" ".ssh/config"
fi

if [ -f "$(dirname $0)/setup-${OS}.sh" ];then
    . $(dirname $0)/setup-${OS}.sh
fi

echo -e ${OK}"\nYou are all set. You can now define zsh as your default shell using the command :\nchsh -s $(which zsh)"${DEFAULT}

