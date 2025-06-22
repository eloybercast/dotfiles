#!/bin/bash

mic_info=$(amixer get Capture)
current_volume=$(echo "$mic_info" | grep -oP '\[.*?%' | tr -d '[]' | head -n1 | grep -oP '\d+')

target_volume=$(( (current_volume / 5 + 1) * 5 ))

if [ "$target_volume" -gt 100 ]; then
    target_volume=100
fi

amixer set Capture ${target_volume}% > /dev/null

exit 0 
