dbus-update-activation-environment DISPLAY; blueman-applet &
echo 100 | doas /bin/tee /sys/class/backlight/nvidia_0/brightness &
~/.fehbg &
xrdb ~/.Xresources &
xset -dpms &
i3
