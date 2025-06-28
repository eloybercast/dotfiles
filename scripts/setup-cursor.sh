#!/bin/bash

source $(dirname "$0")/utils.sh

CURSOR_NAME="volantes-cursors"
CURSOR_REPO="https://github.com/varlesh/volantes-cursors.git"
CURSOR_DIR="$HOME/.local/share/icons"
ASSETS_DIR="$(dirname "$(dirname "$0")")/assets/cursors"

install_volantes_cursors() {
    print_info "Installing Volantes Cursors..."
    
    mkdir -p "$CURSOR_DIR"
    
    if [ -d "$ASSETS_DIR/Volantes_Cursors" ] && [ -d "$ASSETS_DIR/Volantes_Cursors_White" ]; then
        print_info "Using cursor files from assets directory"
        cp -r "$ASSETS_DIR/Volantes_Cursors" "$CURSOR_DIR/"
        cp -r "$ASSETS_DIR/Volantes_Cursors_White" "$CURSOR_DIR/"
    else
        print_info "Downloading cursor files from GitHub"
        TMP_DIR=$(mktemp -d)
        
        git clone "$CURSOR_REPO" "$TMP_DIR"
        
        cd "$TMP_DIR"
        
        mkdir -p "$ASSETS_DIR"
        
        cp -r "$TMP_DIR/dist/Volantes_Cursors" "$ASSETS_DIR/"
        cp -r "$TMP_DIR/dist/Volantes_Cursors_White" "$ASSETS_DIR/"
        
        cp -r "$TMP_DIR/dist/Volantes_Cursors" "$CURSOR_DIR/"
        cp -r "$TMP_DIR/dist/Volantes_Cursors_White" "$CURSOR_DIR/"
        
        rm -rf "$TMP_DIR"
    fi
    
    if [ -f "$HOME/.icons/default/index.theme" ]; then
        mkdir -p "$HOME/.icons/default"
    fi
    
    cat > "$HOME/.icons/default/index.theme" << EOF
[Icon Theme]
Inherits=Volantes_Cursors
EOF
    
    print_success "Volantes Cursors installed successfully!"
}

install_volantes_cursors
