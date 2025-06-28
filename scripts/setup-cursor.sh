#!/bin/bash

source $(dirname "$0")/utils.sh

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
DOTFILES_DIR=$(dirname "$SCRIPT_DIR")

print_info "Setting up Volantes cursors..."

print_info "Installing required packages..."
if command -v pacman &> /dev/null; then
    sudo pacman -S --needed --noconfirm curl unzip
elif command -v apt &> /dev/null; then
    sudo apt install -y curl unzip
fi

CURSORS_DIR="$HOME/.local/share/icons"
mkdir -p "$CURSORS_DIR"

if [ -d "$CURSORS_DIR/Volantes_Cursors" ]; then
    print_info "Volantes cursors are already installed"
else
    print_info "Downloading Volantes cursor theme..."
    TMP_DIR=$(mktemp -d)
    VOLANTES_DOWNLOAD_URL="https://github.com/varlesh/volantes-cursors/archive/refs/heads/master.zip"
    
    curl -L "$VOLANTES_DOWNLOAD_URL" -o "$TMP_DIR/volantes.zip"
    
    print_info "Extracting cursor theme..."
    unzip -q "$TMP_DIR/volantes.zip" -d "$TMP_DIR"
    
    print_info "Installing the cursor theme..."
    cd "$TMP_DIR/volantes-cursors-master"
    if command -v make &> /dev/null; then
        make install PREFIX="$HOME/.local"
    else
        mkdir -p "$CURSORS_DIR"
        cp -r dist/* "$CURSORS_DIR/"
    fi
    
    rm -rf "$TMP_DIR"
fi

# Ensure proper permissions
chmod -R 755 "$CURSORS_DIR/Volantes_Cursors"

# Add to index.theme if it exists
if [ -f "$CURSORS_DIR/default/index.theme" ]; then
    print_info "Updating index.theme..."
    ln -sf "$CURSORS_DIR/Volantes_Cursors" "$CURSORS_DIR/default"
fi

# Update xsettingsd for Xorg applications
XSETTINGS_DIR="$HOME/.config/xsettingsd"
XSETTINGS_FILE="$XSETTINGS_DIR/xsettingsd.conf"
mkdir -p "$XSETTINGS_DIR"

if [ -f "$XSETTINGS_FILE" ]; then
    if ! grep -q "Xcursor/theme" "$XSETTINGS_FILE"; then
        echo 'Xcursor/theme "Volantes_Cursors"' >> "$XSETTINGS_FILE"
    else
        sed -i 's/Xcursor\/theme.*/Xcursor\/theme "Volantes_Cursors"/' "$XSETTINGS_FILE"
    fi
else
    echo 'Xcursor/theme "Volantes_Cursors"' > "$XSETTINGS_FILE"
    echo 'Xcursor/size 24' >> "$XSETTINGS_FILE"
fi

# Configure GTK settings
GTK_CONFIG_DIR="$HOME/.config/gtk-3.0"
GTK_SETTINGS="$GTK_CONFIG_DIR/settings.ini"

mkdir -p "$GTK_CONFIG_DIR"

if [ -f "$GTK_SETTINGS" ]; then
    if grep -q "gtk-cursor-theme-name" "$GTK_SETTINGS"; then
        sed -i 's/gtk-cursor-theme-name=.*/gtk-cursor-theme-name=Volantes_Cursors/' "$GTK_SETTINGS"
    else
        echo "gtk-cursor-theme-name=Volantes_Cursors" >> "$GTK_SETTINGS"
    fi
    
    if grep -q "gtk-cursor-theme-size" "$GTK_SETTINGS"; then
        sed -i 's/gtk-cursor-theme-size=.*/gtk-cursor-theme-size=24/' "$GTK_SETTINGS"
    else
        echo "gtk-cursor-theme-size=24" >> "$GTK_SETTINGS"
    fi
else
    echo "[Settings]" > "$GTK_SETTINGS"
    echo "gtk-cursor-theme-name=Volantes_Cursors" >> "$GTK_SETTINGS"
    echo "gtk-cursor-theme-size=24" >> "$GTK_SETTINGS"
fi

# Create/update GTK-4.0 settings as well
GTK4_CONFIG_DIR="$HOME/.config/gtk-4.0"
GTK4_SETTINGS="$GTK4_CONFIG_DIR/settings.ini"
mkdir -p "$GTK4_CONFIG_DIR"
cp "$GTK_SETTINGS" "$GTK4_SETTINGS"

# Create symlinks to ensure applications find the cursor theme
mkdir -p "$HOME/.icons"
ln -sf "$CURSORS_DIR/Volantes_Cursors" "$HOME/.icons/Volantes_Cursors" 2>/dev/null

# Create a global override
print_info "Creating global settings for cursor..."
GLOBAL_CURSOR_CONFIG=$(cat << 'EOF'
[Icon Theme]
Name=Volantes_Cursors
Inherits=Volantes_Cursors
EOF
)

echo "$GLOBAL_CURSOR_CONFIG" > "$HOME/.icons/default/index.theme"

# Create user autostart script for cursor
AUTOSTART_DIR="$HOME/.config/autostart"
mkdir -p "$AUTOSTART_DIR"

CURSOR_AUTOSTART=$(cat << 'EOF'
[Desktop Entry]
Name=Cursor Theme Apply
Comment=Apply cursor theme at startup
Exec=gsettings set org.gnome.desktop.interface cursor-theme 'Volantes_Cursors'
Type=Application
X-GNOME-Autostart-enabled=true
EOF
)

echo "$CURSOR_AUTOSTART" > "$AUTOSTART_DIR/cursor-theme.desktop"

# Explicitly set cursor in Hyprland configuration
HYPR_USER_CONF="$HOME/.config/hypr/user.conf"
HYPR_DOTFILES_CONF="$DOTFILES_DIR/config/hypr/user.conf"

print_info "Configuring Hyprland cursor settings..."

# Create hyprland theme config
CURSOR_CONFIG=$(cat << 'EOF'

# Cursor settings
env = XCURSOR_THEME,Volantes_Cursors
env = XCURSOR_SIZE,24

exec-once = hyprctl setcursor Volantes_Cursors 24
# Force reload cursor theme
exec-once = gsettings set org.gnome.desktop.interface cursor-theme 'Volantes_Cursors'
EOF
)

# Update user's hyprland.conf to set cursor on startup
HYPR_CONFIG="$HOME/.config/hypr/hyprland.conf"
if [ -f "$HYPR_CONFIG" ]; then
    if ! grep -q "XCURSOR_THEME,Volantes_Cursors" "$HYPR_CONFIG"; then
        echo "$CURSOR_CONFIG" >> "$HYPR_CONFIG"
        print_info "Added cursor settings to $HYPR_CONFIG"
    fi
fi

# Update local user.conf with cursor settings
if [ -f "$HYPR_USER_CONF" ]; then
    if ! grep -q "XCURSOR_THEME,Volantes_Cursors" "$HYPR_USER_CONF"; then
        echo "$CURSOR_CONFIG" >> "$HYPR_USER_CONF"
        print_info "Added cursor settings to $HYPR_USER_CONF"
    else
        print_info "Cursor settings already exist in user config"
    fi
fi

# Update dotfiles user.conf with cursor settings
if ! grep -q "XCURSOR_THEME,Volantes_Cursors" "$HYPR_DOTFILES_CONF"; then
    echo "$CURSOR_CONFIG" >> "$HYPR_DOTFILES_CONF"
    print_info "Added cursor settings to $HYPR_DOTFILES_CONF"
fi

print_success "✅ Volantes cursor setup complete!"
print_info "The new cursor will be applied after you restart your Hyprland session."
print_info "If cursor is still not showing up, try running: 'gsettings set org.gnome.desktop.interface cursor-theme Volantes_Cursors'"
