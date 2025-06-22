#!/bin/bash

# Define the power options
entries="⏻  Shutdown\n⟳  Reboot\n⇠  Logout\n  Suspend\n  Lock"

# Use wofi to display the power menu
selected=$(echo -e $entries | wofi \
    --dmenu \
    --cache-file /dev/null \
    --insensitive \
    --width 300 \
    --height 290 \
    --conf "$HOME/.config/wofi/power-config" \
    --style "$HOME/.config/wofi/power-style.css" \
    --hide-scroll \
    --no-actions \
    --define "hide_search=true" \
    | awk '{print tolower($2)}')

# Execute the selected option
case $selected in
    shutdown)
        systemctl poweroff
        ;;
    reboot)
        systemctl reboot
        ;;
    logout)
        hyprctl dispatch exit
        ;;
    suspend)
        systemctl suspend
        ;;
    lock)
        swaylock
        ;;
esac 