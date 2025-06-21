#!/usr/bin/env bash

~/.config/scripts/general/blur-hyprland.sh on

option=$(printf "󰍃 Logout\n⭮ Reboot\n⏻ Shutdown" | wofi \
    --dmenu \
    --insensitive \
    --width 300 \
    --height 180 \
    --location center \
    --style ~/.config/wofi/power.css \
    --hide-scroll \
    --cache-file /dev/null \
    --prompt "Power Menu" \
    --columns 3)

~/.config/scripts/general/blur-hyprland.sh off

case $option in
    "󰍃 Logout")
        hyprctl dispatch exit
        ;;
    "⭮ Reboot")
        systemctl reboot
        ;;
    "⏻ Shutdown")
        systemctl poweroff
        ;;
esac 