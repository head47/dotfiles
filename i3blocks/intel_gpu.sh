#!/bin/bash
intel_gpu_top -s $(( "$upd_interval"*1000 )) -l | while read -r line; do
	percentage=$(echo "$line" | awk '{print $4}')
	if [ "$percentage" != "RC6" ] && [ "$percentage" != '%' ]; then
		percentage=$(echo "$percentage" | cut -d. -f1)
		if [ "$percentage" -gt "$threshold" ]; then
			echo "<span color='#ff0000'>[INTEL] GPU: "$percentage"%</span>"
		else
			echo "[intel] gpu: "$percentage"%"
		fi
	fi
done
