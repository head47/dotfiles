#!/bin/bash

declare -A prevInterfaceStats
declare -A currInterfaceStats

interval=2

update_interface_stats() {
	interfaces=("$@")
	prevInterfaceStats=
	for i in "${!currInterfaceStats[@]}"; do
		prevInterfaceStats[$i]=${currInterfaceStats[$i]}
	done
	for i in "${interfaces[@]}"; do
		statisticsPath=/sys/class/net/$i/statistics
		rxBytes=$(cat "$statisticsPath/rx_bytes")
		txBytes=$(cat "$statisticsPath/tx_bytes")
		currInterfaceStats[$i]="$rxBytes $txBytes"
	done
}

get_interface_stats_output() {
	interface=$1
	prevStats=(${prevInterfaceStats[$interface]})
	if [ -z "$prevStats" ]; then
		output="R ?     T ?    "
		echo "$output"
		return
	fi
	currStats=(${currInterfaceStats[$interface]})
	rxPerSecondHR="$(numfmt --to=iec <<< $(( (${currStats[0]}-${prevStats[0]})/$interval )) )"
	rxPerSecondHR=$(printf "%-5s" $rxPerSecondHR)
	txPerSecondHR="$(numfmt --to=iec <<< $(( (${currStats[1]}-${prevStats[1]})/$interval )) )"
	txPerSecondHR=$(printf "%-5s" $txPerSecondHR)
	output="R $rxPerSecondHR T $txPerSecondHR"
	echo "$output"
}

get_interface_status_output() {
	interface=$1
	ipAddrShow=$(ip a show "$interface")
	if [[ $(grep -F 'UP' <<< $ipAddrShow) ]]; then
		if [[ $(grep -P '(?<=inet )[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*(?=(\/| ))' <<< $ipAddrShow) ]]; then
			ap=$(iwconfig 2> /dev/null | grep "$interface" | cut -d '"' -f 2)
				if [[ $ap ]]; then
					output="<span color='#00ff00'>$interface: $(grep -Po '(?<=inet )[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*(?=(\/| ))' <<< $ipAddrShow) - $ap"
				else
					output="<span color='#00ff00'>$interface: $(grep -Po '(?<=inet )[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*(?=(\/| ))' <<< $ipAddrShow)"
				fi
		# elif [[ $(grep -F 'SLAVE' <<< $ipAddrShow) ]]; then
		# 	output="<span color='#c9c9c9'>$interface: SLAVE"
		elif [[ $(grep -F 'NO-CARRIER' <<< $ipAddrShow) ]]; then
			output="<span color='#ff0000'>$interface: NO CARRIER"
		else
			ap=$(iwconfig 2> /dev/null | grep "$interface" | cut -d '"' -f 2)
			if [[ "$ap" == *"Mode:Monitor"* ]]; then
				output="<span color='#0000ff'>$interface: MONITOR"
			elif [[ $ap ]]; then
				output="<span color='#ffff00'>$interface: NO IP - $ap"
			else
				output="<span color='#ffff00'>$interface: NO IP"
			fi
		fi
	else
		output="<span color='#ffffff'>$interface: off"
	fi
	echo "$output"
}

get_short_output() {
	interface=$1
	ipAddrShow=$(ip a show "$interface")
	if [[ $(grep -F 'UP' <<< $ipAddrShow) ]]; then
		if [[ $(grep -P '(?<=inet )[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*(?=(\/| ))' <<< $ipAddrShow) ]]; then
			output="<span color='#00ff00'>$interface"
		elif [[ $(grep -F 'NO-CARRIER' <<< $ipAddrShow) ]]; then
			output="<span color='#ff0000'>$interface"
		else
			ap=$(iwconfig 2> /dev/null | grep "$interface" | cut -d '"' -f 2)
			if [[ "$ap" == *"Mode:Monitor"* ]]; then
				output="<span color='#0000ff'>$interface"
			else
				output="<span color='#ffff00'>$interface"
			fi
		fi
	else
		output="<span color='#ffffff'>$interface"
	fi
	echo "$output"
}

while true; do
	output=
	interfaces=($(ls /sys/class/net))
	update_interface_stats "${interfaces[@]}"
	for i in "${!interfaces[@]}"; do
		if [[ "${interfaces[$i]}" = 'lo' ]]; then
			continue
		fi
		if ! (ip a show "${interfaces[$i]}" > /dev/null 2>&1); then
			continue
		fi
		ifOutput=$(get_interface_status_output "${interfaces[$i]}")
		output+=$ifOutput
		if ! [[ "$ifOutput" = *": NO CARRIER" || "$ifOutput" = *": off" ]]; then
			stats=$(get_interface_stats_output "${interfaces[$i]}")
			if ! [ -z "$stats" ]; then
				output+=" $stats"
			fi
		fi
		output+="</span>"
		if [ "$i" -ne $(("${#interfaces[@]}"-1)) ]; then
			output+="  "
		fi
	done

	shortOutput=
	for i in "${!interfaces[@]}"; do
		if [[ "${interfaces[$i]}" = 'lo' ]]; then
			continue
		fi
		if ! (ip a show "${interfaces[$i]}" > /dev/null 2>&1); then
			continue
		fi
		ifOutput=$(get_short_output "${interfaces[$i]}")
		shortOutput+="$ifOutput</span>"
		if [ "$i" -ne $(("${#interfaces[@]}"-1)) ]; then
			shortOutput+="  "
		fi
	done

	jsonOutput=$(jq -cn --arg full_text "$output" --arg short_text "$shortOutput" '$ARGS.named')
	echo "$jsonOutput"
	sleep "$interval"
done
