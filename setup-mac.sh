#!/bin/bash

# Install Mac apps {{{
  echo -e "\n${INFO}MAC COMMANDS${DEFAULT}"
  MAC_COMMANDS_LIST=(
    "fzf"
  )
  for i in "${MAC_COMMANDS_LIST[@]}"
  do
    check_command $i
  done

  if [[ ${WITH_CASKS} -eq 1 ]]; then
    echo -e "\n${INFO}CASK APPS${DEFAULT}"

    CASK_APPS_LIST=(
        "alfred"
        "appcleaner"
        "bartender"
        "controlplane"
        "cheatsheet"
        "divvy"
        "docker"
        "dropbox"
        "evernote"
        "firefox"
        "flux"
        "flycut"
        "hyperdock"
        "istat-menus"
        "iterm2"
        "osxfuse"
        "phpstorm"
        "slack"
        "spotify"
        "the-unarchiver"
        "tripmode"
        "tunnelblick"
    )
    for i in "${CASK_APPS_LIST[@]}"
    do
      install_cask_app $i
    done
  fi
# }}}

# Install custom font for Terminal {{{
  echo -e "\n${INFO}FONTS${DEFAULT}"
  STEPMSG="Installing AnonymousPro fonts"
  if [ ! -f "/Library/Fonts/Anonymice Powerline.ttf" ]; then
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
  else
    echo -e "${SKIPMSG}${STEPMSG}"
  fi
# } }}

