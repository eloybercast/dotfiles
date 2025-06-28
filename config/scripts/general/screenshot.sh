#!/bin/bash

SCREENSHOTS_DIR="$HOME/Images/Screenshots"
MAX_SCREENSHOTS=10
SOUND_FILE="/usr/share/sounds/freedesktop/stereo/screen-capture.oga"

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
    
    # Play sound effect
    if [ -f "$SOUND_FILE" ]; then
        paplay "$SOUND_FILE" &
    else
        # Fallback sound if the primary one doesn't exist
        paplay /usr/share/sounds/freedesktop/stereo/camera-shutter.oga &> /dev/null || \
        paplay /usr/share/sounds/freedesktop/stereo/complete.oga &> /dev/null || \
        paplay /usr/share/sounds/gnome/default/alerts/click.ogg &> /dev/null &
    fi
    
    # Notify user with clickable notification to open folder
    notify-send -a "Screenshot" "Screenshot taken" "Saved to $SCREENSHOTS_DIR and copied to clipboard" \
        -i "$OUTPUT_PATH" \
        --action="open=Open folder" \
        --action="view=View image"
    
    # Handle notification action
    case "$?" in
        0) xdg-open "$SCREENSHOTS_DIR" ;; # Open folder
        1) xdg-open "$OUTPUT_PATH" ;; # View image
    esac
    
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