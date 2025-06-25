#!/bin/bash

source scripts/utils.sh

is_package_installed() {
    pacman -Qi "$1" &>/dev/null
    return $?
}

install_package() {
    local pkg=$1
    if is_package_installed "$pkg"; then
        print_success "$pkg is already installed"
    else
        print_warning "Installing $pkg..."
        sudo pacman -S --noconfirm "$pkg"
        if is_package_installed "$pkg"; then
            print_success "$pkg installed successfully"
        else
            print_error "Failed to install $pkg"
            exit 1
        fi
    fi
}

setup_hyprland() {
    print_warning "Installing Hyprland and dependencies..."
    
    local packages=("hyprland" "rofi" "mako" "xdg-desktop-portal-hyprland" "kitty" "polkit-gnome" "xorg-xwayland" "qt5ct")
    for pkg in "${packages[@]}"; do
        install_package "$pkg"
    done
    
    print_info "Copying Hyprland configuration files..."
    mkdir -p "$HOME/.config/hypr"
    
    if [ -d "config/hypr" ]; then
        cp -r config/hypr/* "$HOME/.config/hypr/"
        print_success "Hyprland configuration files copied successfully"
    else
        print_error "Hyprland configuration directory not found"
    fi
    
    if [ ! -d "$HOME/.config/hyprland" ]; then
        ln -sf "$HOME/.config/hypr" "$HOME/.config/hyprland"
        print_info "Created symbolic link from ~/.config/hyprland to ~/.config/hypr for compatibility"
    fi
    
    print_info "Creating Hyprland startup script..."
    local bin_dir="$HOME/.local/bin"
    mkdir -p "$bin_dir"
    
    cat > "$bin_dir/start-hyprland" <<EOF
#!/bin/bash

# Debug info for session startup
echo "Starting Hyprland session at \$(date)" >> "\$HOME/hyprland-startup.log"

# Set important environment variables
export XDG_SESSION_TYPE=wayland
export XDG_SESSION_DESKTOP=Hyprland
export XDG_CURRENT_DESKTOP=Hyprland
export MOZ_ENABLE_WAYLAND=1
export QT_QPA_PLATFORM=wayland;xcb
export QT_QPA_PLATFORMTHEME=qt5ct
export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
export GDK_BACKEND=wayland,x11
export _JAVA_AWT_WM_NONREPARENTING=1
export XCURSOR_SIZE=24
export XDG_RUNTIME_DIR=/run/user/\$(id -u)
export WAYLAND_DISPLAY=wayland-0
export WLR_NO_HARDWARE_CURSORS=1
export WLR_RENDERER_ALLOW_SOFTWARE=1
export WLR_DRM_NO_ATOMIC=1

# Make sure polkit agent is running
/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &

# Wait a bit to ensure everything is ready
sleep 1

# Log debug info
echo "Environment variables set. Starting Hyprland..." >> "\$HOME/hyprland-startup.log"

# Check Hyprland executable
if [ ! -f "/usr/bin/Hyprland" ]; then
    echo "ERROR: Hyprland executable not found!" >> "\$HOME/hyprland-startup.log"
    exit 1
fi

# Start Hyprland with detailed logging
exec Hyprland 2>> "\$HOME/hyprland-error.log"
EOF
    
    chmod +x "$bin_dir/start-hyprland"
    
    sudo mkdir -p /usr/local/bin
    sudo ln -sf "$bin_dir/start-hyprland" "/usr/local/bin/start-hyprland"
    
    print_info "Fixing home directory permissions..."
    sudo chown -R $(whoami):$(whoami) $HOME
    sudo chmod 755 $HOME
    
    print_info "Creating session check script..."
    cat > "$bin_dir/check-hyprland" <<EOF
#!/bin/bash

echo "=== Hyprland Session Diagnostics ==="
echo "Date: \$(date)"
echo ""

echo "=== System Information ==="
echo "Kernel: \$(uname -r)"
echo "Display Server: \$XDG_SESSION_TYPE"
echo ""

echo "=== Environment Variables ==="
echo "XDG_SESSION_TYPE: \$XDG_SESSION_TYPE"
echo "XDG_SESSION_DESKTOP: \$XDG_SESSION_DESKTOP"
echo "XDG_CURRENT_DESKTOP: \$XDG_CURRENT_DESKTOP"
echo "WAYLAND_DISPLAY: \$WAYLAND_DISPLAY"
echo ""

echo "=== Critical Files ==="
echo "Hyprland Executable: \$(which Hyprland 2>/dev/null || echo 'NOT FOUND!')"
echo "Startup Script: \$([ -x /usr/local/bin/start-hyprland ] && echo 'EXISTS' || echo 'NOT FOUND!')"
echo ""

echo "=== Log Files ==="
if [ -f "\$HOME/hyprland-startup.log" ]; then
    echo "Startup Log:"
    cat "\$HOME/hyprland-startup.log"
    echo ""
fi

if [ -f "\$HOME/hyprland-error.log" ]; then
    echo "Error Log:"
    tail -n 20 "\$HOME/hyprland-error.log"
    echo ""
fi

echo "=== End of Diagnostics ==="
EOF

    chmod +x "$bin_dir/check-hyprland"
    sudo ln -sf "$bin_dir/check-hyprland" "/usr/local/bin/check-hyprland"
    
    print_info "Creating direct Hyprland launcher..."
    cat > "$bin_dir/hyprland-session" <<EOF
#!/bin/bash

# Simple script to start Hyprland directly
exec Hyprland
EOF
    chmod +x "$bin_dir/hyprland-session"
    sudo ln -sf "$bin_dir/hyprland-session" "/usr/local/bin/hyprland-session"
    
    print_success "Hyprland setup completed successfully"
    print_info "You can now start Hyprland by running 'hyprland-session' or 'start-hyprland'"
    print_info "If you encounter issues, run 'check-hyprland' for diagnostics"
}

setup_hyprland
