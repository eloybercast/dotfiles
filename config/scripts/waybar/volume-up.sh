#!/bin/bash

# Script to increase volume by 5% increments and ensure it rounds to multiples of 5
# Maximum volume set to 150%

# Get current volume
current_volume=$(pamixer --get-volume)

# Calculate target volume (next multiple of 5)
target_volume=$(( (current_volume / 5 + 1) * 5 ))

# Cap at 150%
if [ "$target_volume" -gt 150 ]; then
    target_volume=150
fi

# Set volume to the target
pamixer --set-volume $target_volume

# Optional: Show notification
if command -v notify-send &> /dev/null; then
    notify-send -t 1000 -r 1000 "Volume: ${target_volume}%" \
    -h string:x-canonical-private-synchronous:volume \
    -h int:value:$target_volume
fi

exit 0 