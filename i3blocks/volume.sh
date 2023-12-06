#!/bin/bash

printvol()
{
	listSinksOutput=$(pacmd list-sinks | awk '/\* index: /{f=1} /  index: /{f=0} f')
	port=$(echo "$listSinksOutput" | grep 'active port' | grep -Po '\<\K[^>]*')
	if [ -z "$port" ]; then
		port="(unknown output)"
	fi
	prefix=$(echo "$listSinksOutput" | grep -Po 'alsa.name = "\K[^"]+')
	if [ -z "$prefix" ]; then
		prefix=$(echo "$listSinksOutput" | grep -Po '(?<=index: ).*')
	fi
	volumes=$(amixer -M -D pulse get Master | grep -o -E '[[:digit:]]+%' | tr -d '%')
	volumeL=$(echo "$volumes" | sed -n 1p -)
	volumeR=$(echo "$volumes" | sed -n 2p -)
	volume=$(((volumeL+volumeR)/2))
	#volume=$(amixer -M get Master | grep -o -E '[[:digit:]]+%' | tr -d '%')
	if [[ $(amixer -M -D pulse get Master | grep -F '[off]') ]]; then
		echo "<span color='#ffff00'>[off] $prefix:$port: $volume%</span>"
	else
		echo "$prefix:$port: $volume%"
	fi
}

#echo $$ > `dirname "$0"`/volume.pid
printvol
pactl subscribe | grep --line-buffered sink | while read line; do
	printvol
done
#trap printvol USR1
#while :
#do
#	sleep 60s &
#	wait $!
#done
