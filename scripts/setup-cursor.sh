#!/bin/bash

source $(dirname "$0")/utils.sh

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
DOTFILES_DIR=$(dirname "$SCRIPT_DIR")

print_info "Setting up Volantes cursors..."

print_info "Installing required packages..."
if command -v pacman &> /dev/null; then
    sudo pacman -S --needed --noconfirm curl unzip xcursor-themes adwaita-icon-theme
elif command -v apt &> /dev/null; then
    sudo apt install -y curl unzip xcursor-themes adwaita-icon-theme
fi

CURSORS_DIR="$HOME/.local/share/icons"
mkdir -p "$CURSORS_DIR"

if [ -d "$CURSORS_DIR/Volantes_Cursors" ]; then
    print_info "Volantes cursors are already installed, removing old version..."
    rm -rf "$CURSORS_DIR/Volantes_Cursors"
fi

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
    mkdir -p "$CURSORS_DIR/Volantes_Cursors"
    cp -r dist/* "$CURSORS_DIR/"
fi

print_info "Applying VM-specific fixes..."

# Ensure proper permissions
sudo chmod -R 755 "$CURSORS_DIR/Volantes_Cursors" 2>/dev/null || chmod -R 755 "$CURSORS_DIR/Volantes_Cursors" 2>/dev/null

mkdir -p "$HOME/.icons/default"
sudo mkdir -p "/usr/share/icons/default" 2>/dev/null || true

# Create additional symlinks to ensure the cursor is found
mkdir -p "$HOME/.icons"
ln -sf "$CURSORS_DIR/Volantes_Cursors" "$HOME/.icons/Volantes_Cursors" 2>/dev/null || true
ln -sf "$CURSORS_DIR/Volantes_Cursors" "$HOME/.local/share/icons/default" 2>/dev/null || true

# Set as default for all users
cat > "$HOME/.icons/default/index.theme" << EOF
[Icon Theme]
Name=Default
Comment=Default Cursor Theme
Inherits=Volantes_Cursors
EOF

# Configure GTK settings
for gtk_ver in "gtk-3.0" "gtk-4.0"; do
    GTK_DIR="$HOME/.config/$gtk_ver"
    GTK_SETTINGS="$GTK_DIR/settings.ini"
    
    mkdir -p "$GTK_DIR"
    
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
        cat > "$GTK_SETTINGS" << EOF
[Settings]
gtk-cursor-theme-name=Volantes_Cursors
gtk-cursor-theme-size=24
EOF
    fi
done

# Update Xresources
XRESOURCES="$HOME/.Xresources"
if [ -f "$XRESOURCES" ]; then
    if ! grep -q "Xcursor.theme" "$XRESOURCES"; then
        echo "Xcursor.theme: Volantes_Cursors" >> "$XRESOURCES"
        echo "Xcursor.size: 24" >> "$XRESOURCES"
    else
        sed -i 's/Xcursor.theme:.*/Xcursor.theme: Volantes_Cursors/' "$XRESOURCES"
        sed -i 's/Xcursor.size:.*/Xcursor.size: 24/' "$XRESOURCES"
    fi
else
    echo "Xcursor.theme: Volantes_Cursors" > "$XRESOURCES"
    echo "Xcursor.size: 24" >> "$XRESOURCES"
fi

xrdb -merge "$XRESOURCES" 2>/dev/null || true

ENV_CONF="$HOME/.config/hypr/env.conf"
DOTFILES_ENV_CONF="$DOTFILES_DIR/config/hypr/env.conf"

print_info "Updating Hyprland environment settings for cursor in VM..."
mkdir -p "$(dirname "$ENV_CONF")"

if [ ! -f "$ENV_CONF" ] && [ -f "$DOTFILES_ENV_CONF" ]; then
    cp "$DOTFILES_ENV_CONF" "$ENV_CONF"
fi

# Create powerful fix-cursor script for manual use
SCRIPT_PATH="$HOME/.local/bin"
mkdir -p "$SCRIPT_PATH"

cat > "$SCRIPT_PATH/fix-cursor.sh" << 'EOF'
#!/bin/bash

# Define cursor theme and size
CURSOR_THEME="Volantes_Cursors"
CURSOR_SIZE=24

# Apply via gsettings (for GNOME/GTK apps)
gsettings set org.gnome.desktop.interface cursor-theme "$CURSOR_THEME"
gsettings set org.gnome.desktop.interface cursor-size $CURSOR_SIZE

# Apply via Hyprland
hyprctl setcursor "$CURSOR_THEME" $CURSOR_SIZE

# Update GTK settings
for gtk_ver in "gtk-3.0" "gtk-4.0"; do
    GTK_SETTINGS="$HOME/.config/$gtk_ver/settings.ini"
    if [ -f "$GTK_SETTINGS" ]; then
        sed -i "s/gtk-cursor-theme-name=.*/gtk-cursor-theme-name=$CURSOR_THEME/" "$GTK_SETTINGS"
        sed -i "s/gtk-cursor-theme-size=.*/gtk-cursor-theme-size=$CURSOR_SIZE/" "$GTK_SETTINGS"
    fi
done

echo "Cursor theme set to $CURSOR_THEME with size $CURSOR_SIZE"
echo "Please restart your session or applications for changes to take effect"
EOF

chmod +x "$SCRIPT_PATH/fix-cursor.sh"

# Create startup script for Hyprland
mkdir -p "$HOME/.config/hypr/startup"
cat > "$HOME/.config/hypr/startup/cursor.sh" << 'EOF'
#!/bin/bash
sleep 1
gsettings set org.gnome.desktop.interface cursor-theme "Volantes_Cursors"
gsettings set org.gnome.desktop.interface cursor-size 24
hyprctl setcursor Volantes_Cursors 24
EOF

chmod +x "$HOME/.config/hypr/startup/cursor.sh"

# Add to hyprland.conf if not already there
if [ -f "$HOME/.config/hypr/hyprland.conf" ]; then
    if ! grep -q "exec-once = ~/.config/hypr/startup/cursor.sh" "$HOME/.config/hypr/hyprland.conf"; then
        echo "exec-once = ~/.config/hypr/startup/cursor.sh" >> "$HOME/.config/hypr/hyprland.conf"
        print_info "Added cursor startup script to hyprland.conf"
    fi
fi

print_success "✅ Volantes cursor setup complete!"
print_info "The cursor will be applied after you restart your Hyprland session."
print_info "If you still don't see the Volantes cursor:"
print_info "1. Run '$HOME/.local/bin/fix-cursor.sh'"
print_info "2. Make sure your VM settings allow custom cursors"
