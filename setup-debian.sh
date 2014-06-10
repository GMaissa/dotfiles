#!/bin/bash

STEPMSG="Applying Solarized theme"
echo -ne "${PROCESSMSG}${STEPMSG}"\\r
if [[ ! -f ${HOME}/.dircolors ]];then
    wget --no-check-certificate https://raw.github.com/seebi/dircolors-solarized/master/dircolors.ansi-dark ${HOME}/.dircolors >/dev/null 2>&1
fi
if [[ ! -d ${HOME}/.solarized ]]; then
    git clone https://github.com/sigurdga/gnome-terminal-colors-solarized.git ${HOME}/.solarized >/dev/null 2>&1
fi
OUTPUT=$(${HOME}/.solarized/gnome-terminal-colors-solarized/set_dark.sh 2>&1 >/dev/null)
if [ $? -ne 0 ]; then
    echo -e "${ERRORMSG}"
    echo -e ${WARN}${OUTPUT}${DEFAULT}
    exit 1
fi
echo -e "${SUCCESSMSG}"
    
