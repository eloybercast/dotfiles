#!/bin/bash

# Launch wofi with custom styling
wofi --show drun \
     --conf "$HOME/.config/wofi/config" \
     --style "$HOME/.config/wofi/style.css" \
     --cache-file /dev/null \
     --no-actions \
     --insensitive \
     --allow-markup \
     --define "hide_scroll=true" 