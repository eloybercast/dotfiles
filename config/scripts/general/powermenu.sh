#!/usr/bin/env bash

# Turn off animations for cleaner look
~/.config/scripts/general/blur-hyprland.sh on

# Run the power menu with minimalist parameters, using config file
option=$(printf "⭮ Reboot\n󰍃 Logout\n⏻ Shutdown" | wofi \
    --conf ~/.config/wofi/config \
    --style ~/.config/wofi/power.css)

# Restore animations
~/.config/scripts/general/blur-hyprland.sh off

# Execute the selected command
case "$option" in
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