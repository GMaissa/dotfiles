#!/bin/bash

# Install Mac apps {{{
echo -e "\n${INFO}DEBIAN COMMANDS${DEFAULT}"
DEBIAN_COMMANDS_LIST=(
  "rubygems"
)
for i in "${DEBIAN_COMMANDS_LIST[@]}"
do
  check_command $i
done
# }}}

# Install Solarized terminal theme {{{
echo -e "\n${INFO}SOLARIZED THEME${DEFAULT}"
STEPMSG="Applying Solarized theme"
if [[ ! -f ${HOME}/.dircolors -o ! -d ${HOME}/.solarized ]];then
  echo -ne "${PROCESSMSG}${STEPMSG}"\\r
  if [[ ! -f ${HOME}/.dircolors ]];then
    OUTPUT=$(wget --no-check-certificate https://raw.github.com/seebi/dircolors-solarized/master/dircolors.ansi-dark ${HOME}/.dircolors 2>&1 >/dev/null)
    if [ $? -ne 0 ]; then
      echo -e "${ERRORMSG}${STEPMSG}"
      echo -e ${WARN}${OUTPUT}${DEFAULT}
      exit 1
    fi
  fi
  if [[ ! -d ${HOME}/.solarized ]]; then
    OUTPUT=$(git clone https://github.com/sigurdga/gnome-terminal-colors-solarized.git ${HOME}/.solarized 2>&1 >/dev/null)
    if [ $? -ne 0 ]; then
      echo -e "${ERRORMSG}${STEPMSG}"
      echo -e ${WARN}${OUTPUT}${DEFAULT}
      exit 1
    fi
    echo -e "${SUCCESSMSG}${STEPMSG}"
  fi
else
  echo -e "${SKIPMSG}${STEPMSG}"
fi
# }}}

" vim: ft=vim sw=2 foldenable foldmethod=marker foldlevel=0
