#!/bin/bash

current_volume=$(pamixer --get-volume)

target_volume=$(( (current_volume / 5) * 5 ))

if [ "$current_volume" -eq "$target_volume" ]; then
    target_volume=$(( target_volume - 5 ))
fi

if [ "$target_volume" -lt 0 ]; then
    target_volume=0
fi

pamixer --set-volume $target_volume

if command -v notify-send &> /dev/null; then
    notify-send -t 1000 -r 1000 "Volume: ${target_volume}%" \
    -h string:x-canonical-private-synchronous:volume \
    -h int:value:$target_volume
fi

exit 0 