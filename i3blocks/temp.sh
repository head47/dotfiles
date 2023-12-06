#!/bin/bash
degrees=$(( "$(cat /sys/class/thermal/thermal_zone"$thermal_zone"/temp)" / 1000 ))
# workaround for nonstandard thermal zones
if [ "$degrees" -lt 0 ]; then
	thermal_zone=$(( $thermal_zone+1 ))
	degrees=$(( "$(cat /sys/class/thermal/thermal_zone"$thermal_zone"/temp)" / 1000 ))
fi
if [ "$degrees" -gt "$crit_threshold" ]; then
	# if [ $((`date +%s` % 2)) -eq 1 ]; then
	# 	echo "<span color='#ff0000'>T: "$degrees" °C</span>"
	# else
	# 	echo "<span color='#ffff00'>T: "$degrees" °C</span>"
	# fi
	echo "<span color='#ff0000'>T: "$degrees" °C</span>"
elif [ "$degrees" -gt "$threshold" ]; then
        echo "<span color='#ffff00'>T: "$degrees" °C</span>"
else
        echo "t: "$degrees" °C"
fi
