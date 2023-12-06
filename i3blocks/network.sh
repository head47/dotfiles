#!/bin/bash

interfaces=($(ls /sys/class/net))
for i in "${!interfaces[@]}"; do
	if [[ "${interfaces[$i]}" = 'lo' ]]; then
		continue
	fi
	#if [[ "${interfaces[$i]}" == *'mon'* ]]; then
	#	echo -n "<span color='#0000ff'>${interfaces[$i]}: MONITOR</span>"
	#	continue
	#fi
	if [[ $(ip a show "${interfaces[$i]}" | grep -F 'UP') ]]; then
		if [[ $(ip a show "${interfaces[$i]}" | grep -P '(?<=inet )[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*(?=(\/| ))') ]]; then
			ap=$(iwconfig 2> /dev/null | grep "${interfaces[$i]}" | cut -d '"' -f 2)
                        if [[ $ap ]]; then
				echo -n "<span color='#00ff00'>${interfaces[$i]}: $(ip a show "${interfaces[$i]}" | grep -Po '(?<=inet )[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*(?=(\/| ))') - $ap</span>"
                        else
				echo -n "<span color='#00ff00'>${interfaces[$i]}: $(ip a show "${interfaces[$i]}" | grep -Po '(?<=inet )[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*(?=(\/| ))')</span>"
                        fi
		elif [[ $(ip a show "${interfaces[$i]}" | grep -F 'NO-CARRIER') ]]; then
			echo -n "<span color='#ff0000'>${interfaces[$i]}: NO CARRIER</span>"
		else
			ap=$(iwconfig 2> /dev/null | grep "${interfaces[$i]}" | cut -d '"' -f 2)
			if [[ "$ap" == *"Mode:Monitor"* ]]; then
				echo -n "<span color='#0000ff'>${interfaces[$i]}: MONITOR</span>"
			elif [[ $ap ]]; then
				echo -n "<span color='#ffff00'>${interfaces[$i]}: NO IP - $ap</span>"
			else
				echo -n "<span color='#ffff00'>${interfaces[$i]}: NO IP</span>"
			fi
		fi
	else
		echo -n "<span color='#ffffff'>${interfaces[$i]}: off</span>"
	fi
	if [ "$i" -ne $(("${#interfaces[@]}"-1)) ]; then
		echo -n "  "
	fi
done
echo
