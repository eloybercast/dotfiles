#!/bin/bash

amixer set Capture toggle > /dev/null

mic_info=$(amixer get Capture)

if echo "$mic_info" | grep -q '\[off\]'; then
    if command -v notify-send &> /dev/null; then
        notify-send -t 1000 -r 1001 "Microphone: Muted" \
        -h string:x-canonical-private-synchronous:mic \
        -h int:value:0
    fi
else
    volume=$(echo "$mic_info" | grep -oP '\[.*?%' | tr -d '[]' | head -n1)
    volume_num=$(echo "$volume" | grep -oP '\d+')
    rounded_volume=$(( (volume_num + 2) / 5 * 5 ))
    
    if [ "$rounded_volume" -gt 100 ]; then
        rounded_volume=100
    fi
    
    if command -v notify-send &> /dev/null; then
        notify-send -t 1000 -r 1001 "Microphone: ${rounded_volume}%" \
        -h string:x-canonical-private-synchronous:mic \
        -h int:value:$rounded_volume
    fi
fi

exit 0 