#!/bin/bash

source $(dirname "$0")/utils.sh

install_volantes_cursors() {
    print_warning "Installing Volantes Cursors..."
    
    # Create necessary directories
    mkdir -p "$HOME/.local/share/icons"
    mkdir -p "$HOME/.icons/default"
    mkdir -p "$HOME/.config/gtk-3.0"
    mkdir -p "$HOME/.config/gtk-4.0"
    
    # Clone the repository directly
    TMP_DIR=$(mktemp -d)
    print_info "Downloading Volantes Cursors from GitHub..."
    git clone --depth 1 https://github.com/varlesh/volantes-cursors.git "$TMP_DIR"
    
    # Install cursors
    cd "$TMP_DIR"
    
    # Copy cursor files to icons directory
    print_info "Installing cursor files to system..."
    cp -rf "$TMP_DIR/dist/Volantes_Cursors" "$HOME/.local/share/icons/"
    cp -rf "$TMP_DIR/dist/Volantes_Cursors_White" "$HOME/.local/share/icons/"
    
    # Also copy to .icons directory for compatibility
    cp -rf "$TMP_DIR/dist/Volantes_Cursors" "$HOME/.icons/"
    cp -rf "$TMP_DIR/dist/Volantes_Cursors_White" "$HOME/.icons/"
    
    # Set X11 cursor theme
    cat > "$HOME/.icons/default/index.theme" << EOF
[Icon Theme]
Inherits=Volantes_Cursors
EOF
    
    # Set GTK cursor theme
    if [ -f "$HOME/.config/gtk-3.0/settings.ini" ]; then
        sed -i '/gtk-cursor-theme-name=/d' "$HOME/.config/gtk-3.0/settings.ini"
        sed -i '/gtk-cursor-theme-size=/d' "$HOME/.config/gtk-3.0/settings.ini"
        echo "gtk-cursor-theme-name=Volantes_Cursors" >> "$HOME/.config/gtk-3.0/settings.ini"
        echo "gtk-cursor-theme-size=24" >> "$HOME/.config/gtk-3.0/settings.ini"
    else
        cat > "$HOME/.config/gtk-3.0/settings.ini" << EOF
[Settings]
gtk-cursor-theme-name=Volantes_Cursors
gtk-cursor-theme-size=24
EOF
    fi
    
    # Copy settings to GTK4
    cp -f "$HOME/.config/gtk-3.0/settings.ini" "$HOME/.config/gtk-4.0/settings.ini"
    
    # Set GTK2 cursor theme
    if [ -f "$HOME/.gtkrc-2.0" ]; then
        sed -i '/gtk-cursor-theme-name=/d' "$HOME/.gtkrc-2.0"
        sed -i '/gtk-cursor-theme-size=/d' "$HOME/.gtkrc-2.0"
        echo 'gtk-cursor-theme-name="Volantes_Cursors"' >> "$HOME/.gtkrc-2.0"
        echo "gtk-cursor-theme-size=24" >> "$HOME/.gtkrc-2.0"
    else
        cat > "$HOME/.gtkrc-2.0" << EOF
gtk-cursor-theme-name="Volantes_Cursors"
gtk-cursor-theme-size=24
EOF
    fi
    
    # Apply cursor theme to running session
    if command -v gsettings &> /dev/null; then
        gsettings set org.gnome.desktop.interface cursor-theme 'Volantes_Cursors'
        gsettings set org.gnome.desktop.interface cursor-size 24
    fi
    
    # Clean up
    rm -rf "$TMP_DIR"
    
    print_success "✅ Volantes Cursors installed successfully!"
}

# Execute the function
install_volantes_cursors
