#!/bin/bash

. $(dirname $0)/abstract.sh

check_app()
{
    APP=$1
    STEPMSG="Installing ${APP}"
    INSTALLED=$(brew cask list | grep ${APP} | wc -l)
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

if [[ ${WITH_CASKS} -eq 1 ]]; then
    echo -e "\n${INFO}CASK APPS${DEFAULT}"
    check_commands "caskroom/cask/brew-cask"

    #check_app "sshfs"
    check_app "alfred"
    check_app "appcleaner"
    check_app "bartender"
    check_app "chromium"
    check_app "controlplane"
    check_app "dash"
    check_app "delibar"
    check_app "divvy"
    check_app "dropbox"
    check_app "evernote"
    check_app "firefox"
    check_app "flux"
    check_app "google-drive"
    check_app "google-hangouts"
    check_app "gpgtools"
    check_app "hyperdock"
    check_app "istat-menus"
    check_app "iterm2"
    check_app "phpstorm"
    #check_app "remote-desktop-connection"
    check_app "skype"
    check_app "spotify"
    check_app "stay"
    check_app "atom"
    check_app "the-unarchiver"
    check_app "transmission"
    check_app "tower"
    check_app "vagrant"
    check_app "virtualbox"
    check_app "vlc"
fi

echo -e "\n${INFO}ATOM PLUGINS${DEFAULT}"
install_atom_plugin vim-mode
install_atom_plugin editorconfig
install_atom_plugin travis-ci-status

if [ ! -f "/Library/Fonts/Anonymice Powerline.ttf" ]; then
    echo -e "\n${INFO}FONTS${DEFAULT}"
    STEPMSG="Installing AnonymousPro fonts"
    echo -ne "${PROCESSMSG}${STEPMSG}"\\r
    OUTPUT1=$(sudo wget --no-check-certificate -P /Library/Fonts/ https://raw.githubusercontent.com/Lokaltog/powerline-fonts/master/AnonymousPro/Anonymice%20Powerline%20Bold%20Italic.ttf 2>&1 >/dev/null)
    OUTPUT2=$(sudo wget --no-check-certificate -P /Library/Fonts/ https://raw.githubusercontent.com/Lokaltog/powerline-fonts/master/AnonymousPro/Anonymice%20Powerline%20Bold.ttf 2>&1 >/dev/null)
    OUTPUT3=$(sudo wget --no-check-certificate -P /Library/Fonts/ https://raw.githubusercontent.com/Lokaltog/powerline-fonts/master/AnonymousPro/Anonymice%20Powerline%20Italic.ttf 2>&1 >/dev/null)
    OUTPUT4=$(sudo wget --no-check-certificate -P /Library/Fonts/ https://raw.githubusercontent.com/Lokaltog/powerline-fonts/master/AnonymousPro/Anonymice%20Powerline.ttf 2>&1 >/dev/null)
    if [ $? -ne 0 ]; then
        echo -e "${ERRORMSG}${STEPMSG}"
        echo -e ${WARN}${OUTPUT1}${DEFAULT}
        echo -e ${WARN}${OUTPUT2}${DEFAULT}
        echo -e ${WARN}${OUTPUT3}${DEFAULT}
        echo -e ${WARN}${OUTPUT4}${DEFAULT}
        exit 1
    fi
    echo -e "${SUCCESSMSG}${STEPMSG}"
fi
