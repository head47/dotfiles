#!/bin/bash

name=data-hdd-rem
systemdName=data\\x2dhdd\\x2drem

if ! doas /bin/systemctl restart systemd-cryptsetup@$systemdName.service; then
    zenity --error --text "systemctl restart failed"
    exit 1
fi
if ! doas /bin/mount /dev/mapper/$name; then
    zenity --error --text "mount failed"
    exit 2
fi
