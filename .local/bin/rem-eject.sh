#!/bin/bash

uuid=e7d142a3-5f87-4ffa-9f51-ad536e320554
name=data-hdd-rem

if ! doas /bin/umount /dev/mapper/$name; then
    zenity --error --text "umount failed"
    exit 1
fi
if ! doas /bin/cryptsetup close $name; then
    zenity --error --text "cryptsetup close failed"
    exit 2
fi
if ! doas /usr/bin/udisksctl power-off -b /dev/disk/by-uuid/$uuid; then
    zenity --error --text "udisksctl power-off failed"
    exit 3
fi
