#!/bin/bash

pamixer --toggle-mute

is_muted=$(pamixer --get-mute)
current_volume=$(pamixer --get-volume)

if [ "$is_muted" = "true" ]; then
    if command -v notify-send &> /dev/null; then
        notify-send -t 1000 -r 1000 "Volume: Muted" \
        -h string:x-canonical-private-synchronous:volume \
        -h int:value:0
    fi
else
    if command -v notify-send &> /dev/null; then
        notify-send -t 1000 -r 1000 "Volume: ${current_volume}%" \
        -h string:x-canonical-private-synchronous:volume \
        -h int:value:$current_volume
    fi
fi

exit 0 