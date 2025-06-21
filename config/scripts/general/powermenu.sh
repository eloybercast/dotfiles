#!/usr/bin/env bash

~/.config/scripts/general/blur-hyprland.sh on

option=$(printf "⭮ Reboot\n󰍃 Logout\n⏻ Shutdown" | wofi \
    --dmenu \
    --insensitive \
    --width 100% \
    --height 100% \
    --location center \
    --style ~/.config/wofi/power.css \
    --hide-scroll \
    --cache-file /dev/null \
    --prompt " " \
    --no-actions \
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