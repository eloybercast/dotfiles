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
}

setup_hyprland
