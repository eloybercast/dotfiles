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
    
    local packages=("hyprland" "rofi" "mako" "xdg-desktop-portal-hyprland" "kitty")
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

    # Disable Hyprland update notifications
    print_info "Disabling Hyprland update notifications..."
    mkdir -p "$HOME/.config/hypr"
    if ! grep -q "disable_hyprland_logo" "$HOME/.config/hypr/hyprland.conf" 2>/dev/null; then
        echo -e "\n# Disable update notifications\ndisable_hyprland_logo = true\ndisable_splash_rendering = true" >> "$HOME/.config/hypr/hyprland.conf"
    fi
    
    # Create or update the env.conf file to disable update notifications
    mkdir -p "$HOME/.config/hypr"
    cat > "$HOME/.config/hypr/env.conf" << EOF
# Environment variables
env = XCURSOR_SIZE,24
env = HYPRCURSOR_SIZE,24
env = LIBVA_DRIVER_NAME,nvidia
env = XDG_SESSION_TYPE,wayland
env = GBM_BACKEND,nvidia-drm
env = __GLX_VENDOR_LIBRARY_NAME,nvidia
env = WLR_NO_HARDWARE_CURSORS,1

# Disable Hyprland update notifications
env = HYPRLAND_NO_RT,1
env = HYPRLAND_NO_SD,1
EOF
    print_success "Hyprland update notifications disabled"
}

setup_hyprland
