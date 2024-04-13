#!/bin/bash

util_percentage=$(gpustat --json | jq ".gpus[$gpu_index]."'"utilization.gpu"')

if [ "$util_percentage" -gt "$threshold" ]; then
    echo "<span color='#ff0000'>GPU: "$util_percentage"%</span>"
else
	echo "gpu: "$util_percentage"%"
fi
