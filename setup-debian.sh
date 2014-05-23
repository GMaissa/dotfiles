#!/bin/bash

STEPMSG=$(printf "%-45s" "Applying Solarized theme")
echo -ne "${STEPMSG}${PROCESSMSG}"\\r
if [[ ! -f ${HOME}/.dircolors ]];then
    wget --no-check-certificate https://raw.github.com/seebi/dircolors-solarized/master/dircolors.ansi-dark ${HOME}/.dircolors >/dev/null 2>&1
fi
if [[ ! -d ${HOME}/.solarized-terminal ]]; then
    git clone https://github.com/sigurdga/gnome-terminal-colors-solarized.git ${HOME}/.solarized-terminal >/dev/null 2>&1
fi
OUTPUT=$(${HOME}/.solarized-terminal/set_dark.sh 2>&1 >/dev/null)
if [ $? -ne 0 ]; then
    echo -e "${STEPMSG}${ERRORMSG}"
    echo -e ${OUTPUT}
    exit 1
fi
echo -e "${STEPMSG}${SUCCESSMSG}"
    
