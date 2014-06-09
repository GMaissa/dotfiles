#!/bin/bash

STEPMSG=$(printf "%-45s" "Installing AnonymousPro fonts")
echo -ne "${PROCESSMSG}${STEPMSG}"\\r
OUTPUT1=$(sudo wget --no-check-certificate -P /Library/Fonts/ https://raw.githubusercontent.com/Lokaltog/powerline-fonts/master/AnonymousPro/Anonymice%20Powerline%20Bold%20Italic.ttf 2>&1 >/dev/null)
OUTPUT2=$(sudo wget --no-check-certificate -P /Library/Fonts/ https://raw.githubusercontent.com/Lokaltog/powerline-fonts/master/AnonymousPro/Anonymice%20Powerline%20Bold.ttf 2>&1 >/dev/null)
OUTPUT3=$(sudo wget --no-check-certificate -P /Library/Fonts/ https://raw.githubusercontent.com/Lokaltog/powerline-fonts/master/AnonymousPro/Anonymice%20Powerline%20Italic.ttf 2>&1 >/dev/null)
OUTPUT4=$(sudo wget --no-check-certificate -P /Library/Fonts/ https://raw.githubusercontent.com/Lokaltog/powerline-fonts/master/AnonymousPro/Anonymice%20Powerline.ttf 2>&1 >/dev/null)
if [ $? -ne 0 ]; then
    echo -e "${ERRORMSG}${STEPMSG}"
    echo -e ${OUTPUT1}
    echo -e ${OUTPUT2}
    echo -e ${OUTPUT3}
    echo -e ${OUTPUT4}
    exit 1
fi
echo -e "${SUCCESSMSG}${STEPMSG}"
