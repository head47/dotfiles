#!/bin/bash

resp=$(zenity --question \
    --switch \
    --text='End your X session?' \
    --extra-button="suspend" \
    --extra-button="logout" \
    --extra-button="reboot" \
    --extra-button="shutdown")

case $resp in
    suspend)
        i3lock-extra.sh && systemctl suspend
        ;;

    logout)
        i3-msg exit
        ;;

    reboot)
        systemctl reboot
        ;;

    shutdown)
        systemctl poweroff
        ;;
esac