#!/bin/bash

. $(dirname $0)/abstract.sh

echo -e ${INFO} "        __  ___             __      __  _____ __             "${DEFAULT};
echo -e ${INFO} "       /  |/  /_  __   ____/ /___  / /_/ __(_) /__  _____    "${DEFAULT};
echo -e ${INFO} "      / /|_/ / / / /  / __  / __ \/ __/ /_/ / / _ \/ ___/    "${DEFAULT};
echo -e ${INFO} "     / /  / / /_/ /  / /_/ / /_/ / /_/ __/ / /  __(__  )     "${DEFAULT};
echo -e ${INFO} "    /_/  /_/\__  /   \____/\____/\__/_/ /_/_/\___/____/      "${DEFAULT};
echo -e ${INFO} "           /____/                                            \n"${DEFAULT};

# Repository of the oh-my-zsh project
OHMYZSHREPO=git@github.com:robbyrussell/oh-my-zsh.git

# Current path
CUR_PATH=$(pwd)

WITH_COMPOSER=0
WITH_NODE=0
WITH_SSH=0

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
    echo -e "   -h, --help         Display this help"
    echo -e "   --with-composer    Install composer and the static analysis / unit test tools"
    echo -e "   --with-node        Install NodeJS, NPM and some NodeJS packages (grunt, bower)"
    echo -e "   --with-ssh         Install ssh 'bins' and configuration\n"
#    echo -e $DEFAULT
    exit
}

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
        echo -e "${ERRORMSG}"
        echo -e ${OUTPUT}
        exit 1
    fi
    echo -e "${SUCCESSMSG}"
    if [ "${ADDIMSG}" != "" ];then
        echo -e ${ADDIMSG} 
    fi
}

symlink_bin()
{
    BINFILE=$1
    SYMLINKNAME=$1
    STEPMSG="Adding ${BINFILE} script ..."
    ADDIMSG=""

    if [ -L ~/bin/"${SYMLINKNAME}" ]; then
        #echo -e ${WARN}"Removing old symlinked script ~/bin/${SYMLINKNAME}"${DEFAULT}
        rm ~/bin/${SYMLINKNAME}
    elif [ -f ~/bin/"${SYMLINKNAME}" ]; then
        mv ~/bin/${SYMLINKNAME} ~/bin/${SYMLINKNAME}.bak
        ADDIMSG=${WARN}"Moving old script to ~/bin/${SYMLINKNAME}.bak"${DEFAULT}
    fi
    echo -ne "${PROCESSMSG}${STEPMSG}"\\r
    OUTPUT=$(ln -s ${CUR_PATH}/bin/${BINFILE} ~/bin/${SYMLINKNAME} 2>&1 >/dev/null)
    if [ $? -ne 0 ]; then
        echo -e "${ERRORMSG}"
        echo -e ${OUTPUT}
        exit 1
    fi
    echo -e "${SUCCESSMSG}"
    if [ "${ADDIMSG}" != "" ];then
        echo -e ${ADDIMSG} 
    fi
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
            echo -e ${WARN}${OUTPUT}${DEFAULT}
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
        OUTPUT=$(git clone https://github.com/${REPO} ~/.vim/bundle/${BUNDLE} 2>&1 >/dev/null)
        if [ $? -ne 0 ]; then
            echo -e "${ERRORMSG}${STEPMSG}"
            echo -e ${WARN}${OUTPUT}${DEFAULT}
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
    if [ ! -f ~/.vim/plugin/"${PLUGIN}" ]; then
        STEPMSG="Installing VIM plugin ${PLUGIN}"
        echo -ne "${PROCESSMSG}${STEPMSG}"\\r
        OUTPUT=$(wget -P ~/.vim/plugin/ https://raw.githubusercontent.com/${REPO}/master/plugin/${PLUGIN} 2>&1 >/dev/null)
        if [ $? -ne 0 ]; then
            echo -e "${ERRORMSG}${STEPMSG}"
            echo -e ${WARN}${OUTPUT}${DEFAULT}
            exit 1
        fi
        echo -e "${SUCCESSMSG}${STEPMSG}"
    fi
}

install_gpg_key()
{
    GPGKEY=$1
    STEPMSG="Installing GPG key ${GPGKEY}"
    echo -ne "${PROCESSMSG}${STEPMSG}"\\r
    OUTPUT=$(gpg --keyserver pgp.mit.edu--recv-key ${GPGKEY} 2>&1 >/dev/null)
    if [ $? -ne 0 ]; then
        echo -e "${ERRORMSG}${STEPMSG}"
        echo -e ${WARN}${OUTPUT}${DEFAULT}
        exit 1
    fi
    echo -e "${SUCCESSMSG}${STEPMSG}"
}

install_composer_pkg()
{
    PKG=$1
#    if [ ! -d ~/.vim/bundle/"${PKG}" ]; then
        STEPMSG="Installing Composer package ${PKG}"
        echo -ne "${PROCESSMSG}${STEPMSG}"\\r
        OUTPUT=$(composer global require "${PKG}=*" 2>&1 >/dev/null)
        if [ $? -ne 0 ]; then
            echo -e "${ERRORMSG}${STEPMSG}"
            echo -e ${WARN}${OUTPUT}${DEFAULT}
            exit 1
        fi
        echo -e "${SUCCESSMSG}${STEPMSG}"
#    fi
}

install_node_pkg()
{
    PKG=$1
    STEPMSG="Installing NodeJS package ${PKG}"
    echo -ne "${PROCESSMSG}${STEPMSG}"\\r
    OUTPUT=$(sudo npm install -g "${PKG}" 2>&1 >/dev/null)
    if [ $? -ne 0 ]; then
        echo -e "${ERRORMSG}${STEPMSG}"
        echo -e ${WARN}${OUTPUT}${DEFAULT}
        exit 1
    fi
    echo -e "${SUCCESSMSG}${STEPMSG}"
}

# Check command arguments
while test $# -gt 0
do
    case "$1" in
        -h)                 display_help
                            ;;
        --help)             display_help
                            ;;
        --with-composer)    WITH_COMPOSER=1
                            ;;
        --with-node)        WITH_NODE=1
                            ;;
        --with-ssh)         WITH_SSH=1
                            ;;
    esac
    shift
done

# We need Git, Zsh Tmux to be installed
echo -e "\n${INFO}COMMANDS${DEFAULT}"
check_commands "zsh"
check_commands "tmux"
check_commands "vim"
check_commands "wget"
check_commands "gnupg2"
check_commands "git-flow"
check_commands "tree"
check_commands "openssl"

echo -e "\n${INFO}SHELL${DEFAULT}"
# Cloning the oh-my-zsh project if not already done
if [ ! -d ~/.oh-my-zsh ]; then
    STEPMSG="Cloning OH-MY-ZSH repo"
    echo -ne "${PROCESSMSG}${STEPMSG}"\\r
    OUTPUT=$(git clone ${OHMYZSHREPO} ~/.oh-my-zsh 2>&1 >/dev/null)
    if [ $? -ne 0 ]; then
        echo -e "${ERRORMSG}${STEPMSG}"
        echo -e ${WARN}${OUTPUT}${DEFAULT}
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
echo -e "\n${INFO}VIM${DEFAULT}"
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
if [ ! -f ~/.vim/autoload/pathogen.vim ]; then
    STEPMSG="Installing VIM plugin pathogen"
    echo -ne "${PROCESSMSG}${STEPMSG}"\\r
    OUTPUT=$(wget -P ~/.vim/autoload/ https://raw.github.com/tpope/vim-pathogen/master/autoload/pathogen.vim 2>&1 >/dev/null)
    if [ $? -ne 0 ]; then
        echo -e "${ERRORMSG}${STEPMSG}"
        echo -e ${WARN}${OUTPUT}${DEFAULT}
        exit 1
    fi
    echo -e "${SUCCESSMSG}${STEPMSG}"
fi
# Install plugins
install_vim_plugin jamessan/vim-gnupg gnupg.vim

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
install_vim_bundle rizzatti/dash.vim
install_vim_bundle altercation/vim-colors-solarized

# Install plugins
install_vim_plugin jamessan/vim-gnupg gnupg.vim

# Apply configuration for git
echo -e "\n${INFO}GIT${DEFAULT}"
symlink_config "config/git" ".gitconfig"
symlink_config "config/gitignore" ".gitignore_global"

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
    fi
    install_composer_pkg "squizlabs/php_codesniffer"
    install_composer_pkg "phpunit/phpunit"
    install_composer_pkg "phpmd/phpmd"
    install_composer_pkg "sebastian/phpcpd"
fi

# Install NodeJS packages
if [[ ${WITH_NODE} -eq 1 ]]; then
    echo -e "\n${INFO}NodeJS${DEFAULT}"
    
    check_commands "node"

    install_node_pkg "grunt-cli"
    install_node_pkg "bower"
    install_node_pkg "bower-installer"
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
fi

if [ -f "$(dirname $0)/setup-${OS}.sh" ];then
    . $(dirname $0)/setup-${OS}.sh
fi

echo -e ${INFO}"\nYou are all set. You can now define zsh as your default shell using the command :\nchsh -s $(which zsh)"${DEFAULT}

