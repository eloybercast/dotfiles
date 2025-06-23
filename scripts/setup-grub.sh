#!/bin/bash

source scripts/utils.sh

setup_grub_theme() {
    print_warning "Setting up MineGrub World Selection Theme..."
    
    local temp_dir=$(mktemp -d)
    
    print_info "Downloading MineGrub World Selection Theme..."
    git clone https://github.com/Lxtharia/minegrub-world-sel-theme.git "$temp_dir"
    
    if [ ! -d "$temp_dir/minegrub-world-selection" ]; then
        print_error "Failed to download MineGrub theme"
        rm -rf "$temp_dir"
        exit 1
    fi
    
    local grub_path="/boot/grub"
    if [ -d "/boot/grub2" ]; then
        grub_path="/boot/grub2"
        print_info "Detected GRUB2 path: $grub_path"
    fi
    
    sudo mkdir -p "$grub_path/themes"
    
    print_info "Installing theme to $grub_path/themes/..."
    sudo cp -ruv "$temp_dir/minegrub-world-selection" "$grub_path/themes/"
    
    local grub_config="/etc/default/grub"
    if [ ! -f "$grub_config" ]; then
        print_error "GRUB configuration file not found at $grub_config"
        rm -rf "$temp_dir"
        exit 1
    fi
    
    sudo cp "$grub_config" "$grub_config.backup"
    print_info "Created backup of GRUB configuration at $grub_config.backup"
    
    print_info "Updating GRUB configuration..."
    
    if grep -q "^GRUB_THEME=" "$grub_config"; then
        sudo sed -i "s|^GRUB_THEME=.*|GRUB_THEME=$grub_path/themes/minegrub-world-selection/theme.txt|" "$grub_config"
    else
        echo "GRUB_THEME=$grub_path/themes/minegrub-world-selection/theme.txt" | sudo tee -a "$grub_config" > /dev/null
    fi
    
    if grep -q "^GRUB_TERMINAL_OUTPUT=" "$grub_config"; then
        sudo sed -i "s|^GRUB_TERMINAL_OUTPUT=.*|GRUB_TERMINAL_OUTPUT=gfxterm|" "$grub_config"
    else
        echo "GRUB_TERMINAL_OUTPUT=gfxterm" | sudo tee -a "$grub_config" > /dev/null
    fi
    
    print_info "Updating GRUB configuration..."
    if [ -f "/usr/sbin/update-grub" ]; then
        sudo update-grub
    elif [ -f "/usr/sbin/grub-mkconfig" ]; then
        sudo grub-mkconfig -o "$grub_path/grub.cfg"
    elif [ -f "/usr/sbin/grub2-mkconfig" ]; then
        sudo grub2-mkconfig -o "$grub_path/grub.cfg"
    else
        print_warning "Could not find grub-mkconfig or update-grub. Please update your GRUB configuration manually."
    fi
    
    rm -rf "$temp_dir"
    
    print_success "MineGrub World Selection Theme has been installed successfully!"
    print_info "Your GRUB will use the Minecraft World Selection theme on next boot."
}

setup_grub_theme 