#!/bin/bash

# Create a temporary file with styled entries
entries_file=$(mktemp)

# Add styled entries with CSS classes
cat > "$entries_file" << EOF
<span class="power-shutdown">⏻  Shutdown</span>
<span class="power-reboot">⟳  Reboot</span>
<span class="power-logout">⇠  Logout</span>
<span class="power-suspend">  Suspend</span>
<span class="power-lock">  Lock</span>
EOF

# Use wofi to display the power menu
selected=$(cat "$entries_file" | wofi \
    --dmenu \
    --cache-file /dev/null \
    --insensitive \
    --width 300 \
    --height 290 \
    --conf "$HOME/.config/wofi/power-config" \
    --style "$HOME/.config/wofi/power-style.css" \
    --hide-scroll \
    --no-actions \
    --parse-search \
    --define "hide_search=true" \
    | sed -r 's/.*>(.*)<.*/\1/' \
    | awk '{print tolower($2)}')

# Clean up temp file
rm "$entries_file"

# Execute the selected option
case $selected in
    shutdown)
        systemctl poweroff
        ;;
    reboot)
        systemctl reboot
        ;;
    logout)
        hyprctl dispatch exit
        ;;
    suspend)
        systemctl suspend
        ;;
    lock)
        swaylock
        ;;
esac 