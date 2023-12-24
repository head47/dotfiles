#!/bin/bash

uuid=e7d142a3-5f87-4ffa-9f51-ad536e320554
name=data-hdd-rem

if ! doas /bin/umount /dev/mapper/$name; then
    pids=( $(doas /usr/bin/fuser -m /dev/mapper/$name) )
    processList=()
    for usingPid in "${pids[@]}"; do
        command=$(cat /proc/$usingPid/cmdline | xargs -0 echo)
        processList+=("$usingPid" "$command")
    done
    respCustom=$(
        zenity --list \
        --title 'Disk in use' \
        --text 'Disk is in use by these processes:' \
        --column "PID" \
        --column "Command" \
        --ok-label "Kill" \
        --extra-button "Retry" \
        --cancel-label "Cancel" \
        "${processList[@]}"
    )
    respStatus=$(echo $?)
    if [ "$respCustom" = "Retry" ]; then    # retry
        $0
        exit $?
    elif [ "$respStatus" -eq 0 ]; then      # kill
        for usingPid in "${pids[@]}"; do
            kill -9 "$usingPid"
        done
        $0
        exit $?
    else                                    # cancel
        exit 1
    fi
fi
if ! doas /bin/cryptsetup close $name; then
    zenity --error --text "cryptsetup close failed"
    exit 2
fi
if ! doas /usr/bin/udisksctl power-off -b /dev/disk/by-uuid/$uuid; then
    zenity --error --text "udisksctl power-off failed"
    exit 3
fi
