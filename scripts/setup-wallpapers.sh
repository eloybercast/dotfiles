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
        sudo pacman -S --needed --noconfirm swww hyprpaper imagemagick
        print_success "✅ Wallpaper managers and dependencies installed"
    else
        print_warning "Unsupported package manager. Please install swww, hyprpaper, and imagemagick manually."
    fi
    
    print_info "Setting up swww service..."
    mkdir -p "$HOME/.config/hypr"
    
    if [ -f "$HOME/.config/hypr/hyprland.conf" ]; then
        if ! grep -q "exec-once = swww init" "$HOME/.config/hypr/hyprland.conf"; then
            echo "exec-once = swww init" >> "$HOME/.config/hypr/hyprland.conf"
            print_info "Added swww to Hyprland autostart"
        fi
        
        if ! grep -q "exec-once = hyprpaper" "$HOME/.config/hypr/hyprland.conf"; then
            echo "exec-once = hyprpaper" >> "$HOME/.config/hypr/hyprland.conf"
            print_info "Added hyprpaper to Hyprland autostart"
        fi
    else
        if [ -d "$HOME/.config/hypr" ]; then
            echo "exec-once = swww init" >> "$HOME/.config/hypr/exec.conf"
            echo "exec-once = hyprpaper" >> "$HOME/.config/hypr/exec.conf"
            print_info "Created new exec.conf with wallpaper service autostart"
        fi
    fi
    
    if [ ! -f "$HOME/.config/hypr/hyprpaper.conf" ]; then
        cat > "$HOME/.config/hypr/hyprpaper.conf" <<EOF
# This is your hyprpaper configuration file
# It will be automatically updated when you change wallpapers using the selector script

# The following option will enable ipc control for external programs
ipc = on
EOF
        print_info "Created default hyprpaper.conf file"
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
            print_info "Setting initial wallpaper: $(basename "$FIRST_WALLPAPER")"
            
            cat > "$HOME/.config/hypr/hyprpaper.conf" <<EOF
# This is your hyprpaper configuration file
# It will be automatically updated when you change wallpapers using the selector script

# Default wallpaper
preload = $FIRST_WALLPAPER
wallpaper = ,$FIRST_WALLPAPER

# The following option will enable ipc control for external programs
ipc = on
EOF
            print_info "Updated hyprpaper.conf with initial wallpaper"
            
            if command -v swww &> /dev/null; then
                swww init || true
                swww img "$FIRST_WALLPAPER" --transition-type grow --transition-pos center
                print_info "Set initial wallpaper with swww"
            fi
            
            if command -v hyprpaper &> /dev/null; then
                if pgrep -x "hyprpaper" > /dev/null; then
                    hyprctl hyprpaper preload "$FIRST_WALLPAPER"
                    hyprctl hyprpaper wallpaper ",$FIRST_WALLPAPER"
                    print_info "Set initial wallpaper with hyprpaper"
                else
                    print_info "Hyprpaper will set the wallpaper on next login"
                fi
            fi
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