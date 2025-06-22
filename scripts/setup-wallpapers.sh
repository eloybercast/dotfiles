#!/bin/bash
set -e

source scripts/utils.sh

setup_wallpapers() {
    print_info "Setting up wallpapers..."
    
    WALLPAPERS_DIR="$HOME/Pictures/Wallpapers"
    mkdir -p "$WALLPAPERS_DIR"
    
    if [ -d "assets/wallpapers" ]; then
        find assets/wallpapers -type f -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" | while read -r file; do
            cp "$file" "$WALLPAPERS_DIR/"
            print_info "Copied $(basename "$file") to $WALLPAPERS_DIR"
        done
        print_success "Wallpapers copied successfully"
    else
        print_error "Wallpapers directory not found in assets"
        return 1
    fi
    
    chmod -R 755 "$WALLPAPERS_DIR"
    
    print_success "✅ Wallpapers setup complete"
}

setup_wallpapers 