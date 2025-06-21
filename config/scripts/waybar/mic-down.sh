#!/bin/bash

mic_info=$(amixer get Capture)
current_volume=$(echo "$mic_info" | grep -oP '\[.*?%' | tr -d '[]' | head -n1 | grep -oP '\d+')

target_volume=$(( (current_volume / 5) * 5 ))

if [ "$current_volume" -eq "$target_volume" ]; then
    target_volume=$(( target_volume - 5 ))
fi

if [ "$target_volume" -lt 0 ]; then
    target_volume=0
fi

amixer set Capture ${target_volume}% > /dev/null

exit 0 