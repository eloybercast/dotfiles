#!/bin/bash

source scripts/utils.sh

setup_sddm_theme() {
    print_warning "Setting up SDDM Sugar Dark Theme..."
    
    local temp_dir=$(mktemp -d)
    
    print_info "Downloading SDDM Sugar Dark Theme..."
    git clone https://github.com/MarianArlt/sddm-sugar-dark.git "$temp_dir"
    
    if [ ! -d "$temp_dir" ]; then
        print_error "Failed to download SDDM Sugar Dark theme"
        rm -rf "$temp_dir"
        exit 1
    fi
    
    local sddm_themes_dir="/usr/share/sddm/themes"
    if [ ! -d "$sddm_themes_dir" ]; then
        print_info "Creating SDDM themes directory..."
        sudo mkdir -p "$sddm_themes_dir"
    fi
    
    if [ -d "$sddm_themes_dir/sugar-dark" ]; then
        print_info "SDDM Sugar Dark theme is already installed. Removing old version..."
        sudo rm -rf "$sddm_themes_dir/sugar-dark"
    fi
    
    print_info "Installing theme to $sddm_themes_dir/sugar-dark..."
    sudo cp -r "$temp_dir" "$sddm_themes_dir/sugar-dark"
    
    local sddm_conf_dir="/etc/sddm.conf.d"
    if [ ! -d "$sddm_conf_dir" ]; then
        print_info "Creating SDDM configuration directory..."
        sudo mkdir -p "$sddm_conf_dir"
    fi
    
    local sddm_conf="$sddm_conf_dir/10-theme.conf"
    print_info "Updating SDDM configuration at $sddm_conf..."
    
    echo "[Theme]
Current=sugar-dark" | sudo tee "$sddm_conf" > /dev/null
    
    if ! command -v sddm &>/dev/null; then
        print_warning "SDDM is not installed. Installing SDDM..."
        sudo pacman -S --noconfirm sddm
        
        print_info "Enabling SDDM service..."
        sudo systemctl enable sddm
    fi
    
    local dependencies=("qt5-quickcontrols2" "qt5-graphicaleffects" "qt5-svg")
    for dep in "${dependencies[@]}"; do
        if ! pacman -Qi "$dep" &>/dev/null; then
            print_warning "Installing dependency: $dep..."
            sudo pacman -S --noconfirm "$dep"
        fi
    done
    
    rm -rf "$temp_dir"
    
    print_success "SDDM Sugar Dark Theme has been installed successfully!"
    print_info "Your login screen will use the Sugar Dark theme on next boot."
}

setup_sddm_theme 