#!/bin/bash
set -e

source scripts/utils.sh

setup_wallpapers() {
    print_info "Setting up wallpapers..."
    
    mkdir -p "$HOME/Pictures"
    
    WALLPAPERS_DIR="$HOME/Pictures/Wallpapers"
    mkdir -p "$WALLPAPERS_DIR"
    
    print_info "Installing wallpaper management tools..."
    if command -v pacman &> /dev/null; then
        sudo pacman -S --needed --noconfirm swww swaybg imagemagick
        print_success "✅ Wallpaper managers and dependencies installed"
    else
        print_warning "Unsupported package manager. Please install swww, swaybg, and imagemagick manually."
    fi
    
    print_info "Setting up wallpaper service..."
    mkdir -p "$HOME/.config/hypr"
    
    mkdir -p "$HOME/.config/scripts/general"
    cat > "$HOME/.config/scripts/general/set-wallpaper.sh" <<EOF
#!/bin/bash
# Wallpaper setter script that tries multiple methods

WALLPAPER="\$1"

if [ -z "\$WALLPAPER" ] || [ ! -f "\$WALLPAPER" ]; then
    echo "Error: Please provide a valid wallpaper path"
    exit 1
fi

# Try swww first
if command -v swww &> /dev/null; then
    swww query || swww init
    if swww query; then
        swww img "\$WALLPAPER" --transition-type grow --transition-pos center
        echo "Set wallpaper using swww"
        exit 0
    fi
fi

# Fall back to swaybg if swww fails
if command -v swaybg &> /dev/null; then
    pkill swaybg 2>/dev/null || true
    swaybg -i "\$WALLPAPER" -m fill &
    echo "Set wallpaper using swaybg"
    exit 0
fi

echo "Failed to set wallpaper - no working wallpaper tool found"
exit 1
EOF
    chmod +x "$HOME/.config/scripts/general/set-wallpaper.sh"
    print_info "Created fallback wallpaper setter script"
    
    if [ -f "$HOME/.config/hypr/hyprland.conf" ]; then
        sed -i '/exec-once = swww init/d' "$HOME/.config/hypr/hyprland.conf"
        sed -i '/exec-once = hyprpaper/d' "$HOME/.config/hypr/hyprland.conf"
        
        echo "" >> "$HOME/.config/hypr/hyprland.conf"
        echo "# Wallpaper setup - tries multiple methods" >> "$HOME/.config/hypr/hyprland.conf"
        echo "exec-once = sleep 1 && ~/.config/scripts/general/set-wallpaper.sh \$HOME/Pictures/Wallpapers/default.png" >> "$HOME/.config/hypr/hyprland.conf"
        
        print_info "Updated Hyprland config to use fallback wallpaper script"
    fi
    
    if [ -d "assets/wallpapers" ]; then
        mkdir -p "assets/wallpapers"
        
        find assets/wallpapers -type f -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" | while read -r file; do
            cp "$file" "$WALLPAPERS_DIR/"
            print_info "Copied $(basename "$file") to $WALLPAPERS_DIR"
        done
        print_success "Wallpapers copied successfully"
        
        FIRST_WALLPAPER=$(find "$WALLPAPERS_DIR" -type f -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" | head -n 1)
        if [ -n "$FIRST_WALLPAPER" ]; then
            ln -sf "$FIRST_WALLPAPER" "$WALLPAPERS_DIR/default.png"
            print_info "Setting initial wallpaper: $(basename "$FIRST_WALLPAPER")"
            
            "$HOME/.config/scripts/general/set-wallpaper.sh" "$FIRST_WALLPAPER"
        fi
    else
        print_warning "Wallpapers directory not found in assets"
        print_info "Creating assets/wallpapers directory"
        mkdir -p "assets/wallpapers"
        print_info "Please add wallpapers to assets/wallpapers directory"
    fi
    
    chmod -R 755 "$WALLPAPERS_DIR"
    
    mkdir -p "$HOME/.config/scripts/wofi"
    if [ -f "config/scripts/wofi/wallpaper-selector.sh" ]; then
        cp "config/scripts/wofi/wallpaper-selector.sh" "$HOME/.config/scripts/wofi/"
        chmod +x "$HOME/.config/scripts/wofi/wallpaper-selector.sh"
        print_info "Copied wallpaper selector script to user config directory"
    fi
    
    print_info "To change wallpaper, use: ~/.config/scripts/wofi/wallpaper-selector.sh"
    print_success "✅ Wallpapers setup complete"
}

setup_wallpapers 