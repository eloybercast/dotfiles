#!/bin/bash

WALLPAPERS_DIR="$HOME/Pictures/Wallpapers"
CACHE_DIR="$HOME/.cache/wofi-wallpaper"
THUMBNAIL_SIZE=200

mkdir -p "$CACHE_DIR"

if [ ! -d "$WALLPAPERS_DIR" ]; then
    notify-send "Wallpaper Selector" "Wallpapers directory not found: $WALLPAPERS_DIR" -i dialog-error
    exit 1
fi

image_files=$(find "$WALLPAPERS_DIR" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" \))

if [ -z "$image_files" ]; then
    notify-send "Wallpaper Selector" "No wallpapers found in $WALLPAPERS_DIR" -i dialog-error
    exit 1
fi

options=""
for img in $image_files; do
    filename=$(basename "$img")
    thumbnail="$CACHE_DIR/${filename%.*}.png"
    
    if [ ! -f "$thumbnail" ] || [ "$img" -nt "$thumbnail" ]; then
        convert "$img" -thumbnail "${THUMBNAIL_SIZE}x${THUMBNAIL_SIZE}^" -gravity center -extent "${THUMBNAIL_SIZE}x${THUMBNAIL_SIZE}" "$thumbnail"
    fi
    
    options="$options$filename\x00icon\x1f$thumbnail\n"
done

selected=$(echo -e "$options" | wofi --dmenu --allow-images --cache-file /dev/null --insensitive --prompt "Select Wallpaper" --width 600 --height 400)

if [ -n "$selected" ]; then
    wallpaper_path="$WALLPAPERS_DIR/$selected"
    
    if command -v hyprctl &> /dev/null; then
        if pgrep -x "hyprpaper" > /dev/null; then
            echo "preload = $wallpaper_path" > ~/.config/hypr/hyprpaper.conf
            echo "wallpaper = ,${wallpaper_path}" >> ~/.config/hypr/hyprpaper.conf
            hyprctl hyprpaper preload "$wallpaper_path"
            hyprctl hyprpaper wallpaper ",${wallpaper_path}"
        else
            if command -v swww &> /dev/null; then
                swww init
                swww img "$wallpaper_path" --transition-type grow --transition-pos center
            else
                if command -v swaybg &> /dev/null; then
                    pkill swaybg 2>/dev/null || true
                    swaybg -i "$wallpaper_path" -m fill &
                fi
            fi
        fi
    fi
    
    notify-send "Wallpaper" "Set wallpaper to $selected" -i "$wallpaper_path"
else
    notify-send "Wallpaper Selector" "No wallpaper selected" -i dialog-information
fi 