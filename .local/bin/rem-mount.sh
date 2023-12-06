#!/bin/bash

name=data-hdd-rem
systemdName=data\\x2dhdd\\x2drem

if ! doas /bin/systemctl restart systemd-cryptsetup@$systemdName.service; then
    i3-nagbar -m "systemctl restart failed"
    exit 1
fi
if ! doas /bin/mount /dev/mapper/$name; then
    i3-nagbar -m "mount failed"
    exit 2
fi
