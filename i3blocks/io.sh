#!/bin/bash

iostatJson=$(iostat -x -o JSON | jq '.sysstat.hosts[0].statistics[0].disk')
diskNum=$(jq length <<< "$iostatJson")
for i in $(seq 0 $((diskNum-1))); do
    diskJson=$(jq ".[$i]" <<< "$iostatJson")
    diskName=$(jq -r ".disk_device" <<< "$diskJson")
    if [[ $diskName == dm* ]]; then
        continue
    fi
    diskUtil=$(jq -r ".util" <<< "$diskJson")
    if (( $(bc <<< "$diskUtil > $threshold") )); then
        echo -n "<span color='#ff0000'>(!) $diskName: $diskUtil%</span>"
    else
        echo -n "$diskName: $diskUtil%"
    fi
    if [[ $i != $(($diskNum-1)) ]]; then
        echo -n "  "
    fi
done
echo
