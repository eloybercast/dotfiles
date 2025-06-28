#!/bin/bash

current_window=$(hyprctl activewindow -j | jq -r '.address')

workspaces=$(hyprctl workspaces -j)
active_workspace=$(hyprctl activeworkspace -j | jq -r '.id')

entries_file=$(mktemp)

echo "$workspaces" | jq -c '.[]' | while read -r workspace; do
    id=$(echo "$workspace" | jq -r '.id')
    windows=$(echo "$workspace" | jq -r '.windows')
    
    if [ "$id" -eq "$active_workspace" ]; then
        prefix="→ "
    else
        prefix="  "
    fi
    
    echo "<span class='workspace-entry' data-id='$id'>$prefix Workspace $id ($windows windows)</span>" >> "$entries_file"
done

selected=$(cat "$entries_file" | wofi \
    --dmenu \
    --cache-file /dev/null \
    --insensitive \
    --width 400 \
    --height 300 \
    --conf "$HOME/.config/wofi/workspace-config" \
    --style "$HOME/.config/wofi/workspace-style.css" \
    --prompt "Move window to workspace:" \
    --hide-scroll \
    --no-actions \
    | sed -r 's/.*data-id='"'"'([0-9]+)'"'"'.*/\1/')

rm "$entries_file"

if [ -n "$selected" ] && [ "$current_window" != "0x0" ]; then
    hyprctl dispatch movetoworkspacesilent "$selected,address:$current_window"
    
    hyprctl dispatch workspace "$selected"
    
    notify-send "Window moved" "Window moved to workspace $selected" -t 3000
fi 