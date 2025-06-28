#!/bin/bash

source scripts/utils.sh

setup_scripts() {
    print_warning "Setting up scripts in user config directory..."
    
    if [ ! -d "$HOME/.config/scripts" ]; then
        mkdir -p "$HOME/.config/scripts"
        print_success "Created directory: $HOME/.config/scripts"
    else
        print_info "Directory already exists: $HOME/.config/scripts"
    fi
    
    cp -r scripts/* "$HOME/.config/scripts/"
    
    if [ $? -eq 0 ]; then
        print_success "All scripts copied successfully to $HOME/.config/scripts/"
        
        chmod +x "$HOME/.config/scripts/"*.sh
        print_success "Made all scripts executable"
    else
        print_error "Failed to copy scripts to $HOME/.config/scripts/"
        exit 1
    fi
}

setup_scripts 
