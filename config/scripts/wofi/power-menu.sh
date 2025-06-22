#!/bin/bash

entries_file=$(mktemp)

cat > "$entries_file" << EOF
<span class="power-shutdown">⏻  Shutdown</span>
<span class="power-reboot">⟳  Reboot</span>
<span class="power-logout">⇠  Logout</span>
EOF

selected=$(cat "$entries_file" | wofi \
    --dmenu \
    --cache-file /dev/null \
    --insensitive \
    --width 300 \
    --height 300 \
    --conf "$HOME/.config/wofi/power-config" \
    --style "$HOME/.config/wofi/power-style.css" \
    --hide-scroll \
    --no-actions \
    --parse-search \
    --define "hide_search=true" \
    --lines 4 \
    | sed -r 's/.*>(.*)<.*/\1/' \
    | awk '{print tolower($2)}')

rm "$entries_file"

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
esac 
