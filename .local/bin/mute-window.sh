#!/bin/bash

sinkInputs=$(pacmd list-sink-inputs)
# this method of finding out a PID was reported by some (in 2013) to be unreliable
# we'll see if that's true
windowPid=$(xprop -id $(xprop -root _NET_ACTIVE_WINDOW | cut -d ' ' -f 5) _NET_WM_PID | sed 's/_NET_WM_PID(CARDINAL) = //')

pgid=$(ps --no-headers -eo pid,pgid | awk '$1 == '"$windowPid"' {print $2}')
groupPids=$(ps --no-headers -eo pgid,pid | awk '$1 == '"$pgid"' {print $2}')

sinkInputId=
while IFS= read -r pid; do
    newSinkInputId=$(
        awk '/index:/{line=$0; next} /application.process.id = "'"$pid"'"/{print line; exit}' <<< "$sinkInputs" |
        grep -Po '(?<=index: ).*'
    )
    echo "$newSinkInputId"
    if [ -z "$newSinkInputId" ]; then
        continue
    fi
    if ! [ -z "$sinkInputId" ]; then
        i3-nagbar -m "multiple sink inputs found, cannot decide"
        exit 2
    fi
    sinkInputId=$newSinkInputId
done <<< "$groupPids"
if [ -z "$sinkInputId" ]; then
    i3-nagbar -m "no sink input found"
    exit 1
fi

pactl set-sink-input-mute "$sinkInputId" toggle