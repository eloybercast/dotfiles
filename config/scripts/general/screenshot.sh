#!/bin/bash

SCREENSHOT_DIR="$HOME/Images/Screenshots"
mkdir -p "$SCREENSHOT_DIR"

FILENAME="screenshot_$(date +%Y%m%d_%H%M%S).png"
grim -g "$(slurp)" "$SCREENSHOT_DIR/$FILENAME"

if [ -f "$SCREENSHOT_DIR/$FILENAME" ]; then
    wl-copy < "$SCREENSHOT_DIR/$FILENAME"
    
    notify-send "Screenshot" "Saved to $SCREENSHOT_DIR/$FILENAME and copied to clipboard" -i "$SCREENSHOT_DIR/$FILENAME"
    
    find "$SCREENSHOT_DIR" -name "screenshot_*.png" | sort | head -n -10 | xargs -r rm
else
    notify-send "Screenshot" "Failed to take screenshot" -u critical
fi

exit 0 