#!/bin/bash
set -e

source scripts/utils.sh

setup_wallpapers() {
    print_info "Setting up wallpapers..."
    
    mkdir -p "$HOME/Pictures"
    
    WALLPAPERS_DIR="$HOME/Pictures/Wallpapers"
    mkdir -p "$WALLPAPERS_DIR"
    
    if grep -q "hypervisor" /proc/cpuinfo || systemd-detect-virt -q; then
        print_info "Virtual machine detected - optimizing wallpaper setup for VMs"
        VM_DETECTED=true
    else
        VM_DETECTED=false
    fi
    
    print_info "Installing wallpaper management tools..."
    if command -v pacman &> /dev/null; then
        sudo pacman -S --needed --noconfirm swaybg imagemagick curl
        
        if [ "$VM_DETECTED" = false ]; then
            sudo pacman -S --needed --noconfirm swww
            print_success "✅ Installed swww for animations on physical hardware"
        else
            print_info "Skipping swww installation in VM environment"
        fi
        
        print_success "✅ Wallpaper managers and dependencies installed"
    else
        print_warning "Unsupported package manager. Please install swaybg, imagemagick, and curl manually."
    fi
    
    print_info "Setting up wallpaper service..."
    mkdir -p "$HOME/.config/hypr"
    
    mkdir -p "$HOME/.config/scripts/general"
    cat > "$HOME/.config/scripts/general/set-wallpaper.sh" <<EOF
#!/bin/bash

WALLPAPER="\$1"

if [ -z "\$WALLPAPER" ] || [ ! -f "\$WALLPAPER" ]; then
    echo "Error: Please provide a valid wallpaper path"
    exit 1
fi

if [ -z "\$WAYLAND_DISPLAY" ]; then
    export WAYLAND_DISPLAY=wayland-0
fi

if [ -z "\$XDG_RUNTIME_DIR" ]; then
    export XDG_RUNTIME_DIR=/run/user/\$(id -u)
fi

if grep -q "hypervisor" /proc/cpuinfo || systemd-detect-virt -q; then
    if command -v swaybg &> /dev/null; then
        pkill swaybg 2>/dev/null || true
        swaybg -i "\$WALLPAPER" -m fill &
        echo "Set wallpaper using swaybg (VM-optimized)"
        exit 0
    fi
else
    if command -v swww &> /dev/null; then
        swww init 2>/dev/null || true
        sleep 1
        
        if swww img "\$WALLPAPER" --transition-type grow --transition-pos center 2>/dev/null; then
            echo "Set wallpaper using swww with animations"
            exit 0
        else
            echo "swww failed, trying alternative methods"
        fi
    fi
fi

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
    print_info "Created wallpaper setter script with VM detection"
    
    if [ -f "$HOME/.config/hypr/hyprland.conf" ]; then
        sed -i '/exec-once = swww init/d' "$HOME/.config/hypr/hyprland.conf"
        sed -i '/exec-once = hyprpaper/d' "$HOME/.config/hypr/hyprland.conf"
        sed -i '/exec-once = .*set-wallpaper.sh/d' "$HOME/.config/hypr/hyprland.conf"
        
        echo "" >> "$HOME/.config/hypr/hyprland.conf"
        echo "exec-once = sleep 3 && ~/.config/scripts/general/set-wallpaper.sh \$HOME/Pictures/Wallpapers/default.png" >> "$HOME/.config/hypr/hyprland.conf"
        
        print_info "Updated Hyprland config to use wallpaper script with increased delay"
    fi
    
    print_info "Checking environment variables for VM compatibility..."
    ENV_CONF="$HOME/.config/hypr/env.conf"
    
    if [ -f "$ENV_CONF" ]; then
        if ! grep -q "WAYLAND_DISPLAY" "$ENV_CONF"; then
            cat >> "$ENV_CONF" <<EOF

export WAYLAND_DISPLAY=wayland-0
export XDG_RUNTIME_DIR=/run/user/\$(id -u)
export WLR_NO_HARDWARE_CURSORS=1
export WLR_RENDERER_ALLOW_SOFTWARE=1
EOF
            print_info "Added VM compatibility variables to env.conf"
        fi
    else
        mkdir -p "$HOME/.config/hypr"
        cat > "$ENV_CONF" <<EOF
export XDG_SESSION_TYPE=wayland
export MOZ_ENABLE_WAYLAND=1
export QT_QPA_PLATFORM=wayland

export WAYLAND_DISPLAY=wayland-0
export XDG_RUNTIME_DIR=/run/user/\$(id -u)
export WLR_NO_HARDWARE_CURSORS=1
export WLR_RENDERER_ALLOW_SOFTWARE=1
EOF
        print_info "Created env.conf with VM compatibility variables"
    fi
    
    download_random_wallpaper() {
        mkdir -p "$WALLPAPERS_DIR"
        DEFAULT_WALLPAPER="$WALLPAPERS_DIR/default.png"
        
        print_info "Downloading a random wallpaper..."
        
        if command -v curl &> /dev/null; then
            curl -s -L -o "$DEFAULT_WALLPAPER" "https://source.unsplash.com/random/1920x1080/?nature,landscape"
            if [ -f "$DEFAULT_WALLPAPER" ] && [ -s "$DEFAULT_WALLPAPER" ]; then
                print_success "Downloaded random wallpaper from Unsplash"
                return 0
            fi
            
            curl -s -L -o "$DEFAULT_WALLPAPER" "https://picsum.photos/1920/1080"
            if [ -f "$DEFAULT_WALLPAPER" ] && [ -s "$DEFAULT_WALLPAPER" ]; then
                print_success "Downloaded random wallpaper from Picsum Photos"
                return 0
            fi
        fi
        
        if command -v convert &> /dev/null; then
            print_info "Creating default gradient wallpaper with ImageMagick..."
            convert -size 1920x1080 gradient:navy-darkblue "$DEFAULT_WALLPAPER"
            print_success "Created default gradient wallpaper"
            return 0
        fi
        
        return 1
    }
    
    WALLPAPERS_FOUND=false
    if [ -d "assets/wallpapers" ]; then
        find assets/wallpapers -type f -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" | while read -r file; do
            cp "$file" "$WALLPAPERS_DIR/"
            print_info "Copied $(basename "$file") to $WALLPAPERS_DIR"
            WALLPAPERS_FOUND=true
        done
        
        if [ "$WALLPAPERS_FOUND" = true ]; then
            print_success "Wallpapers copied successfully"
        else
            print_warning "No wallpapers found in assets/wallpapers"
        fi
    else
        print_warning "Wallpapers directory not found in assets"
        mkdir -p "assets/wallpapers"
    fi
    
    FIRST_WALLPAPER=$(find "$WALLPAPERS_DIR" -type f -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" | head -n 1)
    if [ -n "$FIRST_WALLPAPER" ]; then
        ln -sf "$FIRST_WALLPAPER" "$WALLPAPERS_DIR/default.png"
        print_info "Setting initial wallpaper: $(basename "$FIRST_WALLPAPER")"
    else
        print_info "No wallpapers found, downloading a random one..."
        if download_random_wallpaper; then
            print_success "Default wallpaper set up successfully"
        else
            print_error "Failed to set up a default wallpaper"
        fi
    fi
    
    export WAYLAND_DISPLAY=wayland-0
    export XDG_RUNTIME_DIR=/run/user/$(id -u)
    
    print_info "Wallpaper will be set automatically on next Hyprland startup"
    
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