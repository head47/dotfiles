#!/bin/bash
kilobytes=$(cat /proc/meminfo | grep MemAvailable | awk '{print $2}')
if [ -f "/usr/bin/bc" ]; then
	if [ "$kilobytes" -lt "$threshold" ]; then
		echo "<span color='#ff0000'>FREE: $(bc <<< "scale=2; "$kilobytes"/1024/1024") GiB</span>"
	else
		echo "free: $(bc <<< "scale=2; "$kilobytes"/1024/1024") GiB"
	fi
else
	if [ "$kilobytes" -lt "$threshold" ]; then
                echo "<span color='#ff0000'>FREE: "$kilobytes" KiB</span>"
        else
                echo "<span color='#ffff00'>free: "$kilobytes" KiB</span>"
        fi
fi
