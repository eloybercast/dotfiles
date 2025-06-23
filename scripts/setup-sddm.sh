#!/bin/bash

source "$(dirname "$0")/utils.sh"

setup_sddm() {
    print_info "Setting up SDDM with Minegrub World Selection theme..."
    
    if ! command -v sddm &>/dev/null; then
        print_warning "SDDM not found. Installing SDDM..."
        sudo pacman -S --noconfirm sddm
    fi

    sudo mkdir -p /usr/share/sddm/themes
    
    print_info "Downloading Minegrub World Selection theme..."
    temp_dir=$(mktemp -d)
    git clone https://github.com/Lxtharia/minegrub-world-sel-theme.git "$temp_dir"
    
    sudo mkdir -p /usr/share/sddm/themes/minegrub-world-sel
    
    print_info "Installing theme files..."
    sudo cp -r "$temp_dir"/* /usr/share/sddm/themes/minegrub-world-sel/
    
    rm -rf "$temp_dir"
    
    print_info "Configuring SDDM to use Minegrub World Selection theme..."
    sudo mkdir -p /etc/sddm.conf.d
    
    cat << EOF | sudo tee /etc/sddm.conf.d/theme.conf
[Theme]
Current=minegrub-world-sel
EOF
    
    print_info "Enabling SDDM service..."
    sudo systemctl enable sddm.service
    
    print_success "SDDM setup with Minegrub World Selection theme completed!"
}

setup_sddm