#!/bin/bash

uuid=e7d142a3-5f87-4ffa-9f51-ad536e320554
mountpoint=/mnt/data-hdd-rem

calc_state() {
    if [ ! -L "/dev/disk/by-uuid/$uuid" ]; then
        echo ejected
    elif findmnt "$mountpoint" > /dev/null 2>&1; then
        echo mounted
    else
        echo unmounted
    fi
}
    
state=$(calc_state)
if [ $state = unmounted ]; then
    if [ ! -z "$button" ]; then
        echo "mounting..."
        rem-mount.sh
    else
        echo "rem unmounted"
    fi
elif [ $state = mounted ]; then
    if [ ! -z "$button" ]; then
        echo "ejecting..."
        rem-eject.sh
    else
        echo "<span color='#00ff00'>rem mounted</span>"
    fi
elif [ $state = ejected ]; then
    echo "<span color='#ffff00'>rem ejected</span>"
fi
