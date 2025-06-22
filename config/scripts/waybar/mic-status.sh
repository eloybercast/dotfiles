#!/bin/bash

mic_info=$(amixer get Capture)

if echo "$mic_info" | grep -q '\[off\]'; then
    echo '{"text": "󰍭", "tooltip": "Microphone is muted", "class": "mic-muted"}'
else
    volume=$(echo "$mic_info" | grep -oP '\[.*?%' | tr -d '[]' | head -n1)
    volume_num=$(echo "$volume" | grep -oP '\d+')
    rounded_volume=$(( (volume_num + 2) / 5 * 5 ))
    
    if [ "$rounded_volume" -gt 100 ]; then
        rounded_volume=100
    fi
    
    echo "{\"text\": \"󰍬\", \"tooltip\": \"Microphone: ${rounded_volume}%\", \"class\": \"mic-active\"}"
fi 
