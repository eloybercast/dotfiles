#!/bin/bash

source $(dirname "$0")/utils.sh

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
DOTFILES_DIR=$(dirname "$SCRIPT_DIR")

print_info "Setting up cursor theme for Hyprland in VM..."

# Install xcursor-themes and dependencies
print_info "Installing required packages..."
if command -v pacman &> /dev/null; then
    sudo pacman -S --needed --noconfirm xcursor-themes adwaita-icon-theme
elif command -v apt &> /dev/null; then
    sudo apt install -y xcursor-themes adwaita-icon-theme
fi

# Set up a basic cursor that works reliably in VMs
print_info "Setting up cursor configuration for VM compatibility..."

# Create a simple ~/.Xresources file to set cursor theme and size
cat > "$HOME/.Xresources" << EOF
Xcursor.theme: Adwaita
Xcursor.size: 24
EOF

# Ensure the cursor is readable
xrdb -merge "$HOME/.Xresources" 2>/dev/null || true

# Update GTK settings in both GTK3 and GTK4
for gtk_ver in "gtk-3.0" "gtk-4.0"; do
    GTK_CONFIG_DIR="$HOME/.config/$gtk_ver"
    GTK_SETTINGS="$GTK_CONFIG_DIR/settings.ini"
    
    mkdir -p "$GTK_CONFIG_DIR"
    
    if [ -f "$GTK_SETTINGS" ]; then
        sed -i 's/gtk-cursor-theme-name=.*/gtk-cursor-theme-name=Adwaita/' "$GTK_SETTINGS"
        sed -i 's/gtk-cursor-theme-size=.*/gtk-cursor-theme-size=24/' "$GTK_SETTINGS"
        
        if ! grep -q "gtk-cursor-theme-name" "$GTK_SETTINGS"; then
            echo "gtk-cursor-theme-name=Adwaita" >> "$GTK_SETTINGS"
        fi
        
        if ! grep -q "gtk-cursor-theme-size" "$GTK_SETTINGS"; then
            echo "gtk-cursor-theme-size=24" >> "$GTK_SETTINGS"
        fi
    else
        cat > "$GTK_SETTINGS" << EOF
[Settings]
gtk-cursor-theme-name=Adwaita
gtk-cursor-theme-size=24
gtk-application-prefer-dark-theme=1
EOF
    fi
done

# Update Hyprland configuration to use hardware cursor
ENV_CONF="$HOME/.config/hypr/env.conf"
CONFIG_ENV_CONF="$DOTFILES_DIR/config/hypr/env.conf"

# Update env.conf - this is critical
if [ -f "$ENV_CONF" ]; then
    # Replace WLR_NO_HARDWARE_CURSORS=1 with WLR_NO_HARDWARE_CURSORS=0
    sed -i 's/WLR_NO_HARDWARE_CURSORS=1/WLR_NO_HARDWARE_CURSORS=0/g' "$ENV_CONF"
    
    # Remove any XCURSOR lines
    sed -i '/XCURSOR_THEME/d' "$ENV_CONF"
    sed -i '/XCURSOR_SIZE/d' "$ENV_CONF" 
    sed -i '/XCURSOR_PATH/d' "$ENV_CONF"
    
    # Add our cursor configuration
    cat >> "$ENV_CONF" << EOF

# Cursor configuration
export XCURSOR_THEME=Adwaita
export XCURSOR_SIZE=24
EOF
fi

# Update the dotfiles version too
if [ -f "$CONFIG_ENV_CONF" ]; then
    # Replace WLR_NO_HARDWARE_CURSORS=1 with WLR_NO_HARDWARE_CURSORS=0
    sed -i 's/WLR_NO_HARDWARE_CURSORS=1/WLR_NO_HARDWARE_CURSORS=0/g' "$CONFIG_ENV_CONF"
    
    # Remove any XCURSOR lines
    sed -i '/XCURSOR_THEME/d' "$CONFIG_ENV_CONF"
    sed -i '/XCURSOR_SIZE/d' "$CONFIG_ENV_CONF"
    sed -i '/XCURSOR_PATH/d' "$CONFIG_ENV_CONF"
    
    # Add our cursor configuration
    cat >> "$CONFIG_ENV_CONF" << EOF

# Cursor configuration
export XCURSOR_THEME=Adwaita
export XCURSOR_SIZE=24
EOF
fi

# Update hyprland.conf directly
HYPR_CONF="$HOME/.config/hypr/hyprland.conf"
if [ -f "$HYPR_CONF" ]; then
    # Replace cursor exec-once lines
    sed -i '/exec-once = hyprctl setcursor/d' "$HYPR_CONF"
    sed -i '/exec-once = gsettings set org.gnome.desktop.interface cursor-theme/d' "$HYPR_CONF"
    
    # Add our cursor setting commands
    cat >> "$HYPR_CONF" << EOF

# Apply Adwaita cursor (VM-compatible)
exec-once = gsettings set org.gnome.desktop.interface cursor-theme 'Adwaita'
exec-once = gsettings set org.gnome.desktop.interface cursor-size 24
exec-once = hyprctl setcursor Adwaita 24
EOF
fi

# Create user.conf with proper cursor settings
USER_CONF="$HOME/.config/hypr/user.conf"
DOTFILES_USER_CONF="$DOTFILES_DIR/config/hypr/user.conf"

if [ -f "$USER_CONF" ]; then
    # Remove any existing cursor settings
    sed -i '/cursor {/,/}/d' "$USER_CONF"
    
    # Add our cursor config
    cat >> "$USER_CONF" << EOF

# VM-compatible cursor settings
cursor {
    # Use hardware cursor to fix VM issues
    force_no_hardware_cursors = false
}
EOF
fi

if [ -f "$DOTFILES_USER_CONF" ]; then
    # Remove any existing cursor settings
    sed -i '/cursor {/,/}/d' "$DOTFILES_USER_CONF"
    
    # Add our cursor config
    cat >> "$DOTFILES_USER_CONF" << EOF

# VM-compatible cursor settings
cursor {
    # Use hardware cursor to fix VM issues
    force_no_hardware_cursors = false
}
EOF
fi

# Apply settings with gsettings immediately
if command -v gsettings &> /dev/null; then
    gsettings set org.gnome.desktop.interface cursor-theme 'Adwaita'
    gsettings set org.gnome.desktop.interface cursor-size 24
fi

print_success "✅ Cursor setup complete!"
print_info "The Adwaita cursor will be applied after you restart Hyprland."
print_info "This cursor theme is specially configured to work in VM environments."
