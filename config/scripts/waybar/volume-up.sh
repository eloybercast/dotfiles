#!/bin/bash


current_volume=$(pamixer --get-volume)

target_volume=$(( (current_volume / 5 + 1) * 5 ))

if [ "$target_volume" -gt 100 ]; then
    target_volume=100
fi

pamixer --set-volume $target_volume

exit 0 
