#!/bin/bash

WALLPAPERS_DIR="$HOME/Pictures/Wallpapers"
CACHE_DIR="$HOME/.cache/wofi-wallpaper"
THUMBNAIL_SIZE=200
WALLPAPER_SCRIPT="$HOME/.config/scripts/general/set-wallpaper.sh"

if [ -z "$WAYLAND_DISPLAY" ]; then
    export WAYLAND_DISPLAY=wayland-0
fi

if [ -z "$XDG_RUNTIME_DIR" ]; then
    export XDG_RUNTIME_DIR=/run/user/$(id -u)
fi

export WLR_NO_HARDWARE_CURSORS=1
export WLR_RENDERER_ALLOW_SOFTWARE=1

mkdir -p "$CACHE_DIR"

if ! command -v convert &> /dev/null; then
    notify-send "Wallpaper Selector" "ImageMagick is required but not installed. Please install it with: 'sudo pacman -S imagemagick'" -i dialog-error
    
    if command -v zenity &> /dev/null; then
        if zenity --question --text="Would you like to install ImageMagick now?" --title="Install ImageMagick"; then
            if command -v pacman &> /dev/null; then
                if command -v kitty &> /dev/null; then
                    kitty -e sudo pacman -S --needed --noconfirm imagemagick
                elif command -v alacritty &> /dev/null; then
                    alacritty -e sudo pacman -S --needed --noconfirm imagemagick
                elif command -v gnome-terminal &> /dev/null; then
                    gnome-terminal -- sudo pacman -S --needed --noconfirm imagemagick
                else
                    notify-send "Wallpaper Selector" "Please install ImageMagick manually with: 'sudo pacman -S imagemagick'" -i dialog-information
                    exit 1
                fi
                
                if command -v convert &> /dev/null; then
                    notify-send "Wallpaper Selector" "ImageMagick was installed successfully!" -i dialog-information
                else
                    notify-send "Wallpaper Selector" "Failed to install ImageMagick. Please install it manually." -i dialog-error
                    exit 1
                fi
            else
                notify-send "Wallpaper Selector" "Unsupported package manager. Please install ImageMagick manually." -i dialog-error
                exit 1
            fi
        else
            exit 1
        fi
    else
        exit 1
    fi
fi

if [ ! -d "$WALLPAPERS_DIR" ]; then
    notify-send "Wallpaper Selector" "Wallpapers directory not found: $WALLPAPERS_DIR" -i dialog-error
    mkdir -p "$WALLPAPERS_DIR"
    notify-send "Wallpaper Selector" "Created empty wallpapers directory: $WALLPAPERS_DIR" -i dialog-information
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
    
    if [ ! -f "$wallpaper_path" ]; then
        notify-send "Wallpaper Selector" "Selected wallpaper file not found: $wallpaper_path" -i dialog-error
        exit 1
    fi
    
    notify-send "Wallpaper" "Setting wallpaper to $selected..." -i "$wallpaper_path"
    
    ln -sf "$wallpaper_path" "$WALLPAPERS_DIR/default.png"
    
    if [ -x "$WALLPAPER_SCRIPT" ]; then
        result=$("$WALLPAPER_SCRIPT" "$wallpaper_path" 2>&1)
        if [ $? -eq 0 ]; then
            notify-send "Wallpaper" "Wallpaper set to $selected successfully! ($result)" -i "$wallpaper_path"
        else
            notify-send "Wallpaper Error" "Failed to set wallpaper: $result" -i dialog-error
            
            if command -v swaybg &> /dev/null; then
                pkill swaybg 2>/dev/null || true
                swaybg -i "$wallpaper_path" -m fill &
                notify-send "Wallpaper" "Set wallpaper to $selected with swaybg (fallback)" -i "$wallpaper_path"
            else
                notify-send "Wallpaper Error" "No wallpaper setter available. Install swww or swaybg." -i dialog-error
            fi
        fi
    else
        notify-send "Wallpaper Error" "Wallpaper script not found at $WALLPAPER_SCRIPT" -i dialog-error
        
        if command -v swww &> /dev/null; then
            swww init 2>/dev/null || true
            sleep 1
            
            if swww img "$wallpaper_path" --transition-type grow --transition-pos center; then
                notify-send "Wallpaper" "Set wallpaper to $selected with swww" -i "$wallpaper_path"
            else
                if command -v swaybg &> /dev/null; then
                    pkill swaybg 2>/dev/null || true
                    swaybg -i "$wallpaper_path" -m fill &
                    notify-send "Wallpaper" "Set wallpaper to $selected with swaybg (fallback)" -i "$wallpaper_path"
                else
                    notify-send "Wallpaper Error" "No wallpaper setter available. Install swww or swaybg." -i dialog-error
                fi
            fi
        elif command -v swaybg &> /dev/null; then
            pkill swaybg 2>/dev/null || true
            swaybg -i "$wallpaper_path" -m fill &
            notify-send "Wallpaper" "Set wallpaper to $selected with swaybg" -i "$wallpaper_path"
        else
            notify-send "Wallpaper Error" "No supported wallpaper setter found. Please install swww or swaybg." -i dialog-error
        fi
    fi
else
    notify-send "Wallpaper Selector" "No wallpaper selected" -i dialog-information
fi 