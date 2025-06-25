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
    
    local packages=("hyprland" "kitty" "mako" "xdg-desktop-portal-hyprland" "polkit-gnome" "xorg-xwayland" "qt5ct")
    
    packages+=("mesa" "libva-mesa-driver" "mesa-vdpau" "vulkan-intel" "vulkan-radeon" "libva-utils")
    
    packages+=("wayland-utils" "wayland-protocols" "wl-clipboard")
    
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
export QT_QPA_PLATFORM=wayland
export QT_QPA_PLATFORMTHEME=qt5ct
export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
export GDK_BACKEND=wayland
export _JAVA_AWT_WM_NONREPARENTING=1
export XCURSOR_SIZE=24
export XDG_RUNTIME_DIR=/run/user/\$(id -u)
export WAYLAND_DISPLAY=wayland-0
export WLR_NO_HARDWARE_CURSORS=1
export WLR_RENDERER_ALLOW_SOFTWARE=1
export WLR_DRM_NO_ATOMIC=1
export WLR_RENDERER=vulkan

# Make sure polkit agent is running
/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &

# Wait a bit to ensure everything is ready
sleep 1

# Check Hyprland executable
if [ ! -f "/usr/bin/Hyprland" ]; then
    echo "ERROR: Hyprland executable not found!" >> "\$HOME/hyprland-startup.log"
    exit 1
fi

# Start Hyprland with detailed logging
exec Hyprland -d >> "\$HOME/hyprland-debug.log" 2>&1
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
echo "GPU Info: \$(lspci | grep -i vga)"
echo ""

echo "=== Vulkan Support ==="
if command -v vulkaninfo &> /dev/null; then
    vulkaninfo | grep -E "GPU|deviceName" | head -n 10
else
    echo "vulkaninfo not installed (install vulkan-tools)"
fi
echo ""

echo "=== OpenGL Support ==="
if command -v glxinfo &> /dev/null; then
    glxinfo | grep -E "OpenGL vendor|OpenGL renderer|OpenGL version" 
else
    echo "glxinfo not installed (install mesa-utils)"
fi
echo ""

echo "=== Environment Variables ==="
echo "XDG_SESSION_TYPE: \$XDG_SESSION_TYPE"
echo "XDG_SESSION_DESKTOP: \$XDG_SESSION_DESKTOP"
echo "XDG_CURRENT_DESKTOP: \$XDG_CURRENT_DESKTOP"
echo "WAYLAND_DISPLAY: \$WAYLAND_DISPLAY"
echo "WLR_RENDERER: \$WLR_RENDERER"
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

if [ -f "\$HOME/hyprland-debug.log" ]; then
    echo "Debug Log (last 30 lines):"
    tail -n 30 "\$HOME/hyprland-debug.log"
    echo ""
fi

if [ -f "\$HOME/hyprland-error.log" ]; then
    echo "Error Log (last 30 lines):"
    tail -n 30 "\$HOME/hyprland-error.log"
    echo ""
fi

if [ -f "\$HOME/.cache/hyprland/hyprlandCrashReport599.txt" ]; then
    echo "Crash Report:"
    cat "\$HOME/.cache/hyprland/hyprlandCrashReport599.txt"
    echo ""
fi

echo "=== End of Diagnostics ==="
EOF

    chmod +x "$bin_dir/check-hyprland"
    sudo ln -sf "$bin_dir/check-hyprland" "/usr/local/bin/check-hyprland"
    
    print_info "Creating minimal Hyprland launcher..."
    cat > "$bin_dir/hyprland-minimal" <<EOF
#!/bin/bash

# Simple script to start Hyprland with minimal config
mkdir -p ~/.config/hypr
cat > ~/.config/hypr/minimal.conf <<'INNEREOF'
monitor=,preferred,auto,1

input {
    kb_layout = us
    follow_mouse = 1
}

general {
    layout = dwindle
    gaps_in = 0
    gaps_out = 0
    border_size = 1
    col.active_border = rgb(666666)
    col.inactive_border = rgb(333333)
}

decoration {
    rounding = 0
    active_opacity = 1.0
    inactive_opacity = 1.0
    blur {
        enabled = false
    }
}

debug {
    disable_logs = false
    enable_stdout_logs = true
}

misc {
    disable_hyprland_logo = true
    disable_splash_rendering = true
}
INNEREOF

# Set variables for software rendering if needed
export WLR_RENDERER_ALLOW_SOFTWARE=1
export WLR_NO_HARDWARE_CURSORS=1
export WAYLAND_DISPLAY=wayland-0
export WLR_DRM_NO_ATOMIC=1

# Start with debug output and minimal config
exec Hyprland -c ~/.config/hypr/minimal.conf -d >> ~/hyprland-minimal.log 2>&1
EOF

    chmod +x "$bin_dir/hyprland-minimal"
    sudo ln -sf "$bin_dir/hyprland-minimal" "/usr/local/bin/hyprland-minimal"
    
    print_success "Hyprland setup completed successfully"
    print_info "You can now start Hyprland by running 'start-hyprland'"
    print_info "If you encounter issues, try 'hyprland-minimal' for a basic configuration"
    print_info "For diagnostics, run 'check-hyprland'"
}

setup_hyprland
