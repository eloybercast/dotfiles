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

print_info "Applying VM-specific fixes..."

sudo chmod -R 755 "$CURSORS_DIR/Volantes_Cursors" 2>/dev/null || chmod -R 755 "$CURSORS_DIR/Volantes_Cursors" 2>/dev/null

mkdir -p "$HOME/.icons/default"
mkdir -p "/usr/share/icons/default" 2>/dev/null || true

ln -sf "$CURSORS_DIR/Volantes_Cursors" "$HOME/.icons/Volantes_Cursors" 2>/dev/null || true

cat > "$HOME/.icons/default/index.theme" << EOF
[Icon Theme]
Name=Default
Comment=Default Cursor Theme
Inherits=Volantes_Cursors
EOF

for gtk_ver in "gtk-3.0" "gtk-4.0"; do
    GTK_DIR="$HOME/.config/$gtk_ver"
    GTK_SETTINGS="$GTK_DIR/settings.ini"
    
    mkdir -p "$GTK_DIR"
    
    if [ -f "$GTK_SETTINGS" ]; then
        # Update existing settings
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

SCRIPT_PATH="$HOME/.local/bin"
mkdir -p "$SCRIPT_PATH"

cat > "$SCRIPT_PATH/fix-cursor.sh" << 'EOF'
#!/bin/bash
gsettings set org.gnome.desktop.interface cursor-theme 'Volantes_Cursors'
gsettings set org.gnome.desktop.interface cursor-size 24
hyprctl setcursor Volantes_Cursors 24
EOF

chmod +x "$SCRIPT_PATH/fix-cursor.sh"

print_success "✅ Volantes cursor setup complete!"
print_info "The cursor will be applied after you restart your Hyprland session."
print_info "If you're in a VM and still don't see the cursor:"
print_info "1. Run '$HOME/.local/bin/fix-cursor.sh'"
print_info "2. Check that WLR_NO_HARDWARE_CURSORS=1 is in your env.conf"
