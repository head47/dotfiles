#!/bin/bash
read cpu user nice system idle iowait irq softirq steal guest< /proc/stat

cpu_active_prev=$((user+system+nice+softirq+steal))
cpu_total_prev=$((user+system+nice+softirq+steal+idle+iowait))

sleep 0.5

read cpu user nice system idle iowait irq softirq steal guest< /proc/stat

cpu_active_cur=$((user+system+nice+softirq+steal))
cpu_total_cur=$((user+system+nice+softirq+steal+idle+iowait))

cpu_util=$((100*( cpu_active_cur-cpu_active_prev ) / (cpu_total_cur-cpu_total_prev) ))

if [ "$cpu_util" -gt "$threshold" ]; then
	echo "<span color='#ff0000'>CPU: "$cpu_util"%</span>"
else
	echo "cpu: "$cpu_util"%"
fi
