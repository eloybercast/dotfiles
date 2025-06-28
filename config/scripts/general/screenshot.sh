#!/bin/bash

SCREENSHOTS_DIR="$HOME/Images/Screenshots"
MAX_SCREENSHOTS=10

# Create Screenshots directory if it doesn't exist
mkdir -p "$SCREENSHOTS_DIR"

# Generate filename with timestamp
FILENAME="screenshot_$(date +%Y%m%d_%H%M%S).png"
OUTPUT_PATH="$SCREENSHOTS_DIR/$FILENAME"

# Take screenshot using grim and slurp
grim -g "$(slurp)" "$OUTPUT_PATH"

# Check if screenshot was successfully taken
if [ -f "$OUTPUT_PATH" ]; then
    # Copy to clipboard using wl-copy
    wl-copy < "$OUTPUT_PATH"
    
    # Notify user
    notify-send "Screenshot taken" "Saved to $OUTPUT_PATH and copied to clipboard" -i "$OUTPUT_PATH"
    
    # Check if we need to delete older screenshots
    SCREENSHOT_COUNT=$(ls -1 "$SCREENSHOTS_DIR" | wc -l)
    
    if [ "$SCREENSHOT_COUNT" -gt "$MAX_SCREENSHOTS" ]; then
        OLDEST_SCREENSHOT=$(ls -t "$SCREENSHOTS_DIR" | tail -1)
        rm "$SCREENSHOTS_DIR/$OLDEST_SCREENSHOT"
        notify-send "Old screenshot removed" "$OLDEST_SCREENSHOT was deleted" -t 3000
    fi
else
    notify-send "Screenshot failed" "Failed to take screenshot" -u critical
fi 