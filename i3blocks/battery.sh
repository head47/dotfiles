#!/bin/bash

batterypath=( "/sys/class/power_supply/BAT*" )
batterypath="${batterypath[0]}"
if [ ! -d $batterypath ]; then
        exit
fi
percentage=$(( $(cat $batterypath/capacity) * $(cat $batterypath/charge_full) / $(cat $batterypath/charge_full_design) ))
status=$(cat $batterypath/status)

if [ "$status" = "Full" ]; then
	echo "<span color='#00ff00'>full "$percentage"%</span>"
elif [ "$status" = "Charging" ]; then
	echo "chr: "$percentage"%"
elif [ "$status" = "Unknown" ]; then
	if [ "$percentage" -lt "$crit_threshold" ]; then
		if [ $((`date +%s` % 2)) -eq 1 ]; then
			echo "<span color='#ff0000'>BAT: "$percentage"%</span>"
		else
			echo "<span color='#ffff00'>BAT: "$percentage"%</span>"
		fi
	elif [ "$percentage" -lt "$threshold" ]; then
        	echo "<span color='#ff0000'>BAT: "$percentage"%</span>"
	else
        	echo "bat: "$percentage"%"
	fi
elif [ "$status" = "Discharging" ]; then
	if [ "$percentage" -lt "$crit_threshold" ]; then
		if [ $((`date +%s` % 2)) -eq 1 ]; then
                	echo "<span color='#ff0000'>DIS: "$percentage"%</span>"
		else
			echo "<span color='#ffff00'>DIS: "$percentage"%</span>"
		fi
	elif [ "$degrees" -lt "$threshold" ]; then
		echo "<span color='#ff0000'>dis: "$percentage"%</span>"
	else
		echo "dis: "$percentage"%"
	fi
fi
