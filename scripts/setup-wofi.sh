#!/bin/bash

source "$(dirname "$0")/utils.sh"

setup_wofi() {
    print_step "Setting up wofi"

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

    mkdir -p "$HOME/.config/wofi"
    
    mkdir -p "$HOME/.config/scripts/wofi"

    print_info "Copying wofi configuration files"
    cp -r "$DOTFILES_DIR/config/wofi/"* "$HOME/.config/wofi/"
    
    print_info "Copying wofi scripts"
    cp -r "$DOTFILES_DIR/config/scripts/wofi/"* "$HOME/.config/scripts/wofi/"
    
    chmod +x "$HOME/.config/scripts/wofi/"*.sh
    
    print_success "wofi setup completed"
}

setup_wofi 
