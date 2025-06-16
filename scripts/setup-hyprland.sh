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
    
    local packages=("hyprland" "rofi" "mako" "xdg-desktop-portal-hyprland")
    for pkg in "${packages[@]}"; do
        install_package "$pkg"
    done

    if [ -d "$HOME/.config/hypr" ]; then
        print_warning "Hyprland config directory exists, backing up..."
        mv "$HOME/.config/hypr" "$HOME/.config/hypr.bak-$(date +%F_%T)"
    fi
    mkdir -p "$HOME/.config/hypr"

    local config_files=("hyprland.conf" "env.conf" "animations.conf" "keybinds.conf" "user.conf" "windowrules.conf")
    for file in "${config_files[@]}"; do
        if [ -f "config/hyprland/$file" ]; then
            cp "config/hyprland/$file" "$HOME/.config/hypr/" || {
                print_error "Failed to copy $file"
                exit 1
            }
            print_success "$file copied successfully"
        else
            print_warning "Configuration file config/hyprland/$file not found, skipping..."
        fi
    done
}

setup_hyprland