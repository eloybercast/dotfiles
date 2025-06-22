#!/bin/bash

# Import utils
source "$(dirname "$0")/utils.sh"

setup_wofi() {
    print_step "Setting up wofi"

    # Check if wofi is installed, if not install it
    if ! command -v wofi &> /dev/null; then
        print_info "Installing wofi package"
        if command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm wofi
        elif command -v apt &> /dev/null; then
            sudo apt install -y wofi
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y wofi
        else
            print_error "Could not install wofi. Please install it manually."
            return 1
        fi
    else
        print_info "wofi is already installed"
    fi

    # Create wofi config directory if it doesn't exist
    mkdir -p "$HOME/.config/wofi"
    
    # Create wofi script directory
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