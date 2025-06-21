#!/usr/bin/env bash

# Get the current active monitor resolution
MONITOR_INFO=$(hyprctl monitors -j | jq -r '.[0].width, .[0].height')
WIDTH=$(echo $MONITOR_INFO | cut -d' ' -f1)
HEIGHT=$(echo $MONITOR_INFO | cut -d' ' -f2)

if [ "$1" = "on" ]; then
  # Disable animations for smoother experience
  hyprctl keyword animations:enabled 0
  
  # Create a dimming overlay layer
  killall -q swaybg
  hyprctl keyword general:gaps_in 0
  hyprctl keyword general:gaps_out 0
  hyprctl keyword decoration:rounding 0
  
elif [ "$1" = "off" ]; then
  # Restore animations
  hyprctl keyword animations:enabled 1
  
  # Restore normal settings
  hyprctl keyword general:gaps_in 5
  hyprctl keyword general:gaps_out 10
  hyprctl keyword decoration:rounding 10
fi 