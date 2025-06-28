#!/bin/bash

source $(dirname "$0")/utils.sh

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
DOTFILES_DIR=$(dirname "$SCRIPT_DIR")

print_info "Setting up Volantes cursors..."

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

HYPR_USER_CONF="$HOME/.config/hypr/user.conf"
HYPR_DOTFILES_CONF="$DOTFILES_DIR/config/hypr/user.conf"

print_info "Configuring Hyprland cursor settings..."

CURSOR_CONFIG=$(cat << 'EOF'

# Cursor settings
env = XCURSOR_THEME,Volantes_Cursors
env = XCURSOR_SIZE,24

exec-once = hyprctl setcursor Volantes_Cursors 24
EOF
)

if [ -f "$HYPR_USER_CONF" ]; then
    if ! grep -q "XCURSOR_THEME,Volantes_Cursors" "$HYPR_USER_CONF"; then
        echo "$CURSOR_CONFIG" >> "$HYPR_USER_CONF"
        print_info "Added cursor settings to $HYPR_USER_CONF"
    else
        print_info "Cursor settings already exist in user config"
    fi
fi

if ! grep -q "XCURSOR_THEME,Volantes_Cursors" "$HYPR_DOTFILES_CONF"; then
    echo "$CURSOR_CONFIG" >> "$HYPR_DOTFILES_CONF"
    print_info "Added cursor settings to $HYPR_DOTFILES_CONF"
fi

GTK_CONFIG_DIR="$HOME/.config/gtk-3.0"
GTK_SETTINGS="$GTK_CONFIG_DIR/settings.ini"

mkdir -p "$GTK_CONFIG_DIR"

if [ -f "$GTK_SETTINGS" ]; then
    if grep -q "gtk-cursor-theme-name" "$GTK_SETTINGS"; then
        sed -i 's/gtk-cursor-theme-name=.*/gtk-cursor-theme-name=Volantes_Cursors/' "$GTK_SETTINGS"
    else
        echo "gtk-cursor-theme-name=Volantes_Cursors" >> "$GTK_SETTINGS"
    fi
else
    echo "[Settings]" > "$GTK_SETTINGS"
    echo "gtk-cursor-theme-name=Volantes_Cursors" >> "$GTK_SETTINGS"
fi

print_success "✅ Volantes cursor setup complete!"
print_info "The new cursor will be applied after you restart your Hyprland session."
