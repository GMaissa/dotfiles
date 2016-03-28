#!/bin/bash -x

symlink_config()
{
    CONFFILE=$1
    SYMLINKNAME=$2
    if [ -f "${CUR_PATH}/$1.$OS" ]; then
        CONFFILE=$1.$OS
    fi
    STEPMSG="Applying ${CONFFILE} config"
    ADDIMSG=""

    if [ ${OVERRIDE_CONFS} -eq 1 ] || [ ! -e ~/"${SYMLINKNAME}" ]; then
        if [ -L ~/"${SYMLINKNAME}" ]; then
            rm ~/${SYMLINKNAME}
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
    else
        echo -e "${SKIPMSG}${STEPMSG}"
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

check_command()
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
    else
        echo -e "${SKIPMSG}${STEPMSG}"
    fi
}

install_vim_bundle()
{
    REPO=$1
    BUNDLE=$(echo $REPO | cut -d'/' -f 2)
    STEPMSG="Installing VIM bundle ${BUNDLE}"
    if [ ! -d ~/.vim/bundle/"${BUNDLE}" ]; then
        echo -ne "${PROCESSMSG}${STEPMSG}"\\r
        OUTPUT=$(git clone https://github.com/${REPO} ~/.vim/bundle/${BUNDLE} 2>&1 >/dev/null)
        if [ $? -ne 0 ]; then
            echo -e "${ERRORMSG}${STEPMSG}"
            echo -e ${WARN}${OUTPUT}${DEFAULT}
            exit 1
        fi
        echo -e "${SUCCESSMSG}${STEPMSG}"
    else
        echo -e "${SKIPMSG}${STEPMSG}"
    fi
}

install_vim_plugin()
{
    REPO=$1
    PLUGIN=$2
    STEPMSG="Installing VIM plugin ${PLUGIN}"
    if [ ! -d ~/.vim/plugin ]; then
        mkdir ~/.vim/plugin
    fi
    if [ ! -f ~/.vim/plugin/"${PLUGIN}" ]; then
        echo -ne "${PROCESSMSG}${STEPMSG}"\\r
        OUTPUT=$(wget -P ~/.vim/plugin/ https://raw.githubusercontent.com/${REPO}/master/plugin/${PLUGIN} 2>&1 >/dev/null)
        if [ $? -ne 0 ]; then
            echo -e "${ERRORMSG}${STEPMSG}"
            echo -e ${WARN}${OUTPUT}${DEFAULT}
            exit 1
        fi
        echo -e "${SUCCESSMSG}${STEPMSG}"
    else
        echo -e "${SKIPMSG}${STEPMSG}"
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
    STEPMSG="Installing Composer package ${PKG}"
    if [ ! -d ~/.composer/vendor/"${PKG}" ]; then
        echo -ne "${PROCESSMSG}${STEPMSG}"\\r
        OUTPUT=$(composer global require "${PKG}=*" 2>&1 >/dev/null)
        if [ $? -ne 0 ]; then
            echo -e "${ERRORMSG}${STEPMSG}"
            echo -e ${WARN}${OUTPUT}${DEFAULT}
            exit 1
        fi
        echo -e "${SUCCESSMSG}${STEPMSG}"
    else
        echo -e "${SKIPMSG}${STEPMSG}"
    fi
}

install_node_pkg()
{
    PKG=$1
    STEPMSG="Installing NodeJS package ${PKG}"
    if [ ! -d /usr/local/lib/node_modules/"${PKG}" ]; then
        echo -ne "${PROCESSMSG}${STEPMSG}"\\r
        OUTPUT=$(sudo npm install -g "${PKG}" 2>&1 >/dev/null)
        if [ $? -ne 0 ]; then
            echo -e "${ERRORMSG}${STEPMSG}"
            echo -e ${WARN}${OUTPUT}${DEFAULT}
            exit 1
        fi
        echo -e "${SUCCESSMSG}${STEPMSG}"
    else
        echo -e "${SKIPMSG}${STEPMSG}"
    fi

}

install_gem()
{
    GEM=$1
    STEPMSG="Installing Gem ${GEM}"
    INSTALLED=$(gem list --local | grep ${GEM} | wc -l)
    if [ ${INSTALLED} == null ]; then
        echo -ne "${PROCESSMSG}${STEPMSG}"\\r
        OUTPUT=$(sudo gem install "${GEM}" 2>&1 >/dev/null)
        if [ $? -ne 0 ]; then
            echo -e "${ERRORMSG}${STEPMSG}"
            echo -e ${WARN}${OUTPUT}${DEFAULT}
            exit 1
        fi
        echo -e "${SUCCESSMSG}${STEPMSG}"
    else
        echo -e "${SKIPMSG}${STEPMSG}"
    fi
}

install_cask_app()
{
    APP=$1
    STEPMSG="Installing ${APP}"
    INSTALLED=$(brew cask list | grep "${APP}" | wc -l)
    if [ ${INSTALLED} == null ]; then
        echo -ne "${PROCESSMSG}${STEPMSG}"\\r
        # Install the app or exit the script (option -e in the shebang) if failed
        OUTPUT=$(brew cask install ${APP} 2>&1 >/dev/null)
        if [ $? -ne 0 ]; then
            echo -e "${ERRORMSG}${STEPMSG}"
            echo -e ${WARN}${OUTPUT}${DEFAULT}
            exit 1
        fi
        echo -e "${SUCCESSMSG}${STEPMSG}"
    else
        echo -e "${SKIPMSG}${STEPMSG}"
    fi
}

install_atom_plugin()
{
    PLUGIN=$1
    STEPMSG="Installing Atom plugin ${PLUGIN}"
    if [ ! -d ~/.atom/packages/"${PLUGIN}" ] ;then
        echo -ne "${PROCESSMSG}${STEPMSG}"\\r
        # Install the plugin or exit the script (option -e in the shebang) if failed
        OUTPUT=$(apm install ${PLUGIN} 2>&1 >/dev/null)
        if [ $? -ne 0 ]; then
            echo -e "${ERRORMSG}${STEPMSG}"
            echo -e ${WARN}${OUTPUT}${DEFAULT}
            exit 1
        fi
        echo -e "${SUCCESSMSG}${STEPMSG}"
    else
        echo -e "${SKIPMSG}${STEPMSG}"
    fi
}
