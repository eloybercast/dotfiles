#!/bin/bash

# Import utils
source "$(dirname "$0")/utils.sh"

setup_wofi() {
    print_step "Setting up wofi"

    # Create wofi config directory if it doesn't exist
    mkdir -p "$HOME/.config/wofi"
    
    # Create wofi style directory
    mkdir -p "$HOME/.config/scripts/wofi"

    # Copy config files
    print_info "Copying wofi configuration files"
    cp -r "$DOTFILES_DIR/config/wofi/"* "$HOME/.config/wofi/"
    
    # Copy wofi scripts
    print_info "Copying wofi scripts"
    cp -r "$DOTFILES_DIR/config/scripts/wofi/"* "$HOME/.config/scripts/wofi/"
    
    # Make scripts executable
    chmod +x "$HOME/.config/scripts/wofi/"*.sh
    
    print_success "wofi setup completed"
}

setup_wofi 