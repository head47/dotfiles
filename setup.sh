#!/bin/bash

doas pacman -S wireguard-tools maim xclip rofi i3blocks \
    udisks2 cryptsetup sysstat jq bc wireless_tools pulseaudio \
    alsa-utils base-devel git bluez bluez-utils blueman-applet \
    feh i3 xorg-xrdb zenity rofi-emoji rofi-calc &&
doas modprobe btusb &&
doas systemctl enable --now bluetooth.service &&
doas usermod -aG lp "$USER" &&
doas usermod -aG wheel "$USER" &&
doas tee /etc/sudoers.d/50-allow-wheel <<< '%wheel ALL=(ALL:ALL) ALL' &&

mkdir -p ~/aur &&
pushd ~/aur &&
git clone https://aur.archlinux.org/i3lock-color.git &&
cd i3lock-color &&
makepkg -si &&
popd &&

echo "NOTE: relogin to apply group membership"
