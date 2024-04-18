#!/bin/bash

if [ ! -z "$button" ]; then
    if [ -d /sys/class/net/hdvpn ]; then
        hdvpn-down.sh
    else
        hdvpn-up.sh
    fi
fi
if [ -d /sys/class/net/hdvpn ]; then
    echo "<span color='#ffff00'>vpn on</span>"
else
    echo "vpn off"
fi
