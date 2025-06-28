#!/bin/bash

SCREENSHOTS_DIR="$HOME/Images/Screenshots"
MAX_SCREENSHOTS=10
SOUND_FILE="/usr/share/sounds/freedesktop/stereo/screen-capture.oga"

mkdir -p "$SCREENSHOTS_DIR"

FILENAME="screenshot_$(date +%Y%m%d_%H%M%S).png"
OUTPUT_PATH="$SCREENSHOTS_DIR/$FILENAME"

grim -g "$(slurp)" "$OUTPUT_PATH"

if [ -f "$OUTPUT_PATH" ]; then
    wl-copy < "$OUTPUT_PATH"
    
    if [ -f "$SOUND_FILE" ]; then
        paplay "$SOUND_FILE" &
    else
        paplay /usr/share/sounds/freedesktop/stereo/camera-shutter.oga &> /dev/null || \
        paplay /usr/share/sounds/freedesktop/stereo/complete.oga &> /dev/null || \
        paplay /usr/share/sounds/gnome/default/alerts/click.ogg &> /dev/null &
    fi
    
    ACTION_SCRIPT=$(mktemp)
    chmod +x "$ACTION_SCRIPT"
    
    cat > "$ACTION_SCRIPT" << EOF
#!/bin/bash
case "\$1" in
    "open") xdg-open "$SCREENSHOTS_DIR" ;;
    "view") xdg-open "$OUTPUT_PATH" ;;
esac
EOF
    
    notify-send "Screenshot captured" "Saved to $SCREENSHOTS_DIR\nand copied to clipboard" \
        -a "Screenshot Tool" \
        -i "$OUTPUT_PATH" \
        -t 5000 \
        -A "open=Open Folder" \
        -A "view=View Image" \
        -e "$ACTION_SCRIPT"
        
    SCREENSHOT_COUNT=$(ls -1 "$SCREENSHOTS_DIR" | wc -l)
    
    if [ "$SCREENSHOT_COUNT" -gt "$MAX_SCREENSHOTS" ]; then
        OLDEST_SCREENSHOT=$(ls -t "$SCREENSHOTS_DIR" | tail -1)
        rm "$SCREENSHOTS_DIR/$OLDEST_SCREENSHOT"
        notify-send "Old screenshot removed" "$OLDEST_SCREENSHOT was deleted" -t 3000 -a "Screenshot Tool"
    fi
    
    rm -f "$ACTION_SCRIPT"
else
    notify-send "Screenshot failed" "Failed to take screenshot" -u critical -a "Screenshot Tool"
fi 