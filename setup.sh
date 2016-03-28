#!/bin/bash

. $(dirname $0)/abstract.sh
. $(dirname $0)/functions.sh

echo -e ${INFO} "        __  ___             __      __  _____ __             "${DEFAULT};
echo -e ${INFO} "       /  |/  /_  __   ____/ /___  / /_/ __(_) /__  _____    "${DEFAULT};
echo -e ${INFO} "      / /|_/ / / / /  / __  / __ \/ __/ /_/ / / _ \/ ___/    "${DEFAULT};
echo -e ${INFO} "     / /  / / /_/ /  / /_/ / /_/ / /_/ __/ / /  __(__  )     "${DEFAULT};
echo -e ${INFO} "    /_/  /_/\__  /   \____/\____/\__/_/ /_/_/\___/____/      "${DEFAULT};
echo -e ${INFO} "           /____/                                            \n"${DEFAULT};

# Current path
CUR_PATH=$(pwd)
FROM_HOME=$(echo ${PWD#$HOME})

WITH_COMPOSER=0
OVERRIDE_CONFS=0
WITH_NODE=0
WITH_SSH=0
WITH_CASKS=0

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

display_help()
{
#    echo -e $INFO
    echo -e "Usage :"
    echo -e "   ./setup.sh <options>\n"
    echo -e "Options :"
    echo -e "   -h, --help            Display this help"
    echo -e "   -o, --override-confs  Override configuration files if they exist"
    echo -e "   --with-composer       Install composer and the static analysis / unit test tools"
    echo -e "   --with-node           Install NodeJS, NPM and some NodeJS packages (grunt, bower)"
    echo -e "   --with-ssh            Install ssh 'bins' and configuration"
    echo -e "   --with-casks          Install homebrew casks apps (only available for Mac OSX)\n"
#    echo -e $DEFAULT
    exit
}

# Check command arguments
while test $# -gt 0
do
    case "$1" in
        -h | --help)              display_help
                                  ;;
        -o | --override-confs)    OVERRIDE_CONFS=1
                                  ;;
        --with-composer)          WITH_COMPOSER=1
                                  ;;
        --with-node)              WITH_NODE=1
                                  ;;
        --with-ssh)               WITH_SSH=1
                                  ;;
        --with-casks)             WITH_CASKS=1
                                  ;;
    esac
    shift
done

if [ ! -f ${HOME}/.dotfiles.conf ]; then
    echo -e "\n${INFO}DOTFILES CONFIG FILE${DEFAULT}"
    STEPMSG='Set dotfiles directory path'
    echo -ne "${PROCESSMSG}${STEPMSG}"\\r
    OUTPUT=$(echo "export DOTFILESDIR=\$HOME${FROM_HOME}" > ${HOME}/.dotfiles.conf 2>/dev/null)
    if [ $? -ne 0 ]; then
        echo -e "${ERRORMSG}${STEPMSG}"
        echo -e ${WARN}${OUTPUT}${DEFAULT}
        exit 1
    fi
    echo -e "${SUCCESSMSG}${STEPMSG}"
    STEPMSG='Register current user login'
    echo -ne "${PROCESSMSG}${STEPMSG}"\\r
    USERNAME=$(whoami)
    OUTPUT=$(echo "export USERLOGIN=${USERNAME}" >> ${HOME}/.dotfiles.conf 2>/dev/null)
    if [ $? -ne 0 ]; then
        echo -e "${ERRORMSG}${STEPMSG}"
        echo -e ${WARN}${OUTPUT}${DEFAULT}
        exit 1
    fi
    echo -e "${SUCCESSMSG}${STEPMSG}"
fi

# We need Git, Zsh Tmux, ... to be installed
echo -e "\n${INFO}COMMANDS${DEFAULT}"
COMMANDS_LIST=(
    "zsh"
    "tmux"
    "vim"
    "wget"
    "gnupg2"
    "git-flow"
    "tree"
    "openssl"
    "autojump"
)
for i in "${COMMANDS_LIST[@]}"
do
    check_command $i
done

echo -e "\n${INFO}EXTERNAL LIBS${DEFAULT}"
STEPMSG='Download external libraries'
echo -ne "${PROCESSMSG}${STEPMSG}"\\r
OUTPUT=$(git submodule init && git submodule update 2>&1 >/dev/null)
if [ $? -ne 0 ]; then
    echo -e "${ERRORMSG}${STEPMSG}"
    echo -e ${WARN}${OUTPUT}${DEFAULT}
    exit 1
fi
echo -e "${SUCCESSMSG}${STEPMSG}"

echo -e "\n${INFO}SHELL${DEFAULT}"
for file in oh-my-zsh/themes/*
do
    if [ -f "$file" ];then
        THEME=$(basename "$file")
        symlink_config "$file" "${FROM_HOME}/oh-my-zsh/themes/${THEME}"
    fi
done
for dir in oh-my-zsh/plugins/*
do
    if [ -d "$dir" ];then
        PLUGIN=$(basename "$dir")
        symlink_config "$dir" "${FROM_HOME}/oh-my-zsh/plugins/${PLUGIN}"
    fi
done

# Apply configuration for zsh
symlink_config "config/zsh" ".zshrc"

# Enable common aliases
symlink_config "config/aliases" ".aliases"

# Apply configuration for tmux
symlink_config "config/tmux" ".tmux.conf"

# Apply configuration for vim
echo -e "\n${INFO}VIM${DEFAULT}"
symlink_config "config/vim" ".vimrc"
if [ ! -d ~/.vim/backup ]; then
    mkdir -p ~/.vim/backup
fi
if [ ! -d ~/.vim/swap ]; then
    mkdir -p ~/.vim/swap
fi
if [ ! -d ~/.vim/undo ]; then
    mkdir -p ~/.vim/undo
fi
if [ ! -d ~/.vim/autoload ]; then
    mkdir -p ~/.vim/autoload
fi
if [ ! -d ~/.vim/bundle ]; then
    mkdir -p ~/.vim/bundle
fi
# Install pathogen to manage vim plugins as bundles
STEPMSG="Installing VIM plugin pathogen"
if [ ! -f ~/.vim/autoload/pathogen.vim ]; then
    echo -ne "${PROCESSMSG}${STEPMSG}"\\r
    OUTPUT=$(wget -P ~/.vim/autoload/ https://raw.github.com/tpope/vim-pathogen/master/autoload/pathogen.vim 2>&1 >/dev/null)
    if [ $? -ne 0 ]; then
        echo -e "${ERRORMSG}${STEPMSG}"
        echo -e ${WARN}${OUTPUT}${DEFAULT}
        exit 1
    fi
    echo -e "${SUCCESSMSG}${STEPMSG}"
else
    echo -e "${SKIPMSG}${STEPMSG}"
fi
# Install plugins
install_vim_plugin jamessan/vim-gnupg gnupg.vim

# Install bundles
VIM_BUNDLE_LIST=(
    scrooloose/nerdtree
    kien/ctrlp.vim
    kien/rainbow_parentheses.vim
    chilicuil/conque
    Lokaltog/vim-easymotion
    nathanaelkane/vim-indent-guides
    edsono/vim-matchit
    tpope/vim-speeddating
    tpope/vim-surround
    rizzatti/dash.vim
    altercation/vim-colors-solarized
    editorconfig/editorconfig-vim
)
for i in "${VIM_BUNDLE_LIST[@]}"
do
    install_vim_bundle $i
done

echo -e "\n${INFO}TMUX${DEFAULT}"
# Install gem
install_gem tmuxinator

# Install tmuxinator autocompletion script for zsh
STEPMSG="Installing tmuxinator autocompletion script for zsh"
if [ ! -f ~/.bin/tmuxinator.zsh ]; then
    if [ ! -d ~/.bin ]; then
        mkdir -p ~/.bin
    fi
    echo -ne "${PROCESSMSG}${STEPMSG}"\\r
    OUTPUT=$(wget -P ~/.bin/ https://raw.githubusercontent.com/tmuxinator/tmuxinator/master/completion/tmuxinator.zsh 2>&1 >/dev/null)
    if [ $? -ne 0 ]; then
        echo -e "${ERRORMSG}${STEPMSG}"
        echo -e ${WARN}${OUTPUT}${DEFAULT}
        exit 1
    fi
    echo -e "${SUCCESSMSG}${STEPMSG}"
else
    echo -e "${SKIPMSG}${STEPMSG}"
fi

# Apply configuration for git
echo -e "\n${INFO}GIT${DEFAULT}"
symlink_config "config/git/config" ".gitconfig"
if [ ! -d ~/.gitconfig.d ]; then
    mkdir -p ~/.gitconfig.d
fi
symlink_config "config/git/ignore" ".gitconfig.d/.gitignore_global"
symlink_config "config/git/commit.template" ".gitconfig.d/.gitcommit.template"

# Install composer
if [[ ${WITH_COMPOSER} -eq 1 ]]; then
    echo -e "\n${INFO}COMPOSER${DEFAULT}"
    if [ ! -f /usr/local/bin/composer ]; then
        STEPMSG="Installing Composer"
        echo -ne "${PROCESSMSG}${STEPMSG}"\\r
        OUTPUT=$(curl -sS https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer 2>&1 >/dev/null)
        if [ $? -ne 0 ]; then
            echo -e "${ERRORMSG}${STEPMSG}"
            echo -e ${WARN}${OUTPUT}${DEFAULT}
            exit 1
        fi
        echo -e "${SUCCESSMSG}${STEPMSG}"
    else
        STEPMSG="Updating Composer"
        echo -ne "${PROCESSMSG}${STEPMSG}"\\r
        OUTPUT=$(composer self-update 2>&1 >/dev/null)
        if [ $? -ne 0 ]; then
            echo -e "${ERRORMSG}${STEPMSG}"
            echo -e ${WARN}${OUTPUT}${DEFAULT}
            exit 1
        fi
        echo -e "${SUCCESSMSG}${STEPMSG}"
    fi
    COMPOSER_PKG_LIST=(
        "squizlabs/php_codesniffer"
        "phpunit/phpunit"
        "phpmd/phpmd"
        "sebastian/phpcpd"
    )
    for i in "${COMPOSER_PKG_LIST[@]}"
    do
        install_composer_pkg $i
    done
fi

# Install NodeJS packages
if [[ ${WITH_NODE} -eq 1 ]]; then
    echo -e "\n${INFO}NODEJS${DEFAULT}"

    check_command "node"

    NODE_PKG_LIST=(
        "grunt-cli"
        "bower"
        "bower-installer"
    )
    for i in "${NODE_PKG_LIST[@]}"
    do
        install_node_pkg $i
    done
fi

# Apply configuration for ssh
if [[ ${WITH_SSH} -eq 1 ]]; then
    echo -e "\n${INFO}SSH${DEFAULT}"
    # Adding a few usefull scripts
    # You will be able to split the ssh configuration into multiple files
    # ex: config.work config.personal ...
    if [ ! -d ~/bin ]; then
        mkdir ~/bin
    fi
    symlink_bin "ssh_cmds"
    symlink_bin "ssh-copy-id"

    if [ ! -d ~/.ssh ]; then
        mkdir ~/.ssh
    fi
    symlink_config "config/ssh" ".ssh/config"

    # Installing ssh config files and ssh keys stored on Dropbox
    . ~/Dropbox/dotfiles/ssh/setup.sh
fi

if [ -f "$(dirname $0)/setup-${OS}.sh" ];then
    . $(dirname $0)/setup-${OS}.sh
fi

if type "atom" >/dev/null 2>&1 ;then
    echo -e "\n${INFO}ATOM PLUGINS${DEFAULT}"
    ATOM_PLUGIN_LIST=(
        vim-mode
        editorconfig
        travis-ci-status
        language-go
        dash
    )
    for i in "${ATOM_PLUGIN_LIST[@]}"
    do
        install_atom_plugin $i
    done
fi

echo -e ${INFO}"\nYou are all set. You can now define zsh as your default shell using the command :\nchsh -s $(which zsh)"${DEFAULT}
