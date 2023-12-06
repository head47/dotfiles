#!/bin/bash
batterypath=( "/sys/class/power_supply/BAT*" )
batterypath="${batterypath[0]}"
if [ ! -d $batterypath ]; then
	echo 'no battery detected'
	exit
fi
energy_name=energy_full
if [ ! -f $batterypath/$energy_name ]; then
	energy_name=charge_full
fi
percentage=$(( $(cat $batterypath/capacity) * $(cat $batterypath/$energy_name) / $(cat $batterypath/"$energy_name"_design) ))
wear_percentage=$(( 100 * $(cat $batterypath/$energy_name) / $(cat $batterypath/"$energy_name"_design) ))
status=$(cat $batterypath/status)
secsrem=$(( $(cat $batterypath/charge_now) * 3600 / $(cat $batterypath/current_now) ))
timerem=$(date -u -d @${secsrem} +"%T")

if [ "$status" = "Full" ]; then
	echo -n "[$percentage% / $wear_percentage% full] <span color='#00ff00'>"
elif [ "$status" = "Charging" ]; then
	echo -n "[$percentage% / $wear_percentage% chr] <span>"
elif [ "$status" = "Unknown" ]; then
	if [ "$percentage" -lt "$crit_threshold" ]; then
		if [ $((`date +%s` % 2)) -eq 1 ]; then
			echo -n "[$percentage% / $wear_percentage%] <span color='#ff0000'>"
		else
			echo -n "[$percentage% / $wear_percentage%] <span color='#ffff00'>"
		fi
	elif [ "$percentage" -lt "$threshold" ]; then
        	echo -n "[$percentage% / $wear_percentage%] <span color='#ff0000'>"
	else
        	echo -n "[$percentage% / $wear_percentage%] <span>"
	fi
elif [ "$status" = "Discharging" ]; then
	if [ "$percentage" -lt "$crit_threshold" ] || [ "$secsrem" -lt 300 ]; then
		if [ $((`date +%s` % 2)) -eq 1 ]; then
                	echo -n "<span color='#ff0000'>SHUTDOWN IMMINENT</span> [$percentage% / $wear_percentage% $timerem] <span color='#ff0000'>"
		else
			echo -n "<span color='#ff0000'>SHUTDOWN IMMINENT</span> [$percentage% / $wear_percentage% $timerem] <span color='#ffff00'>"
		fi
	elif [ "$percentage" -lt "$threshold" ]; then
		echo -n "[$percentage% / $wear_percentage% $timerem] <span color='#ff0000'>"
	else
		echo -n "[$percentage% / $wear_percentage% $timerem] <span>"
	fi
fi

#batstring=''
#for i in {1..$percentage}; do
#	batstring="█$batstring"
#done
batstring=$(perl -e "print '█' x $percentage;")
#for i in {100..$(( $percentage+1 ))..-1}; do
#	batstring="░$batstring"
#done
batstring=$(perl -e "print '░' x $(( $wear_percentage-$percentage ));")$batstring
batstring="<span color='#ffff00'>"$(perl -e "print '░' x $(( 100-$wear_percentage ));")"</span>"$batstring

echo "$batstring</span>"
