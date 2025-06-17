#!/bin/bash
set -e

source scripts/utils.sh

print_info "📦 Setting up kitty terminal..."

if ! command -v kitty &>/dev/null; then
    print_info "Installing kitty terminal..."
    sudo pacman -S --needed --noconfirm kitty
    print_success "✅ kitty installed."
else
    print_info "kitty is already installed, skipping installation."
fi

mkdir -p ~/.config/kitty

mkdir -p config/kitty

if [ ! -f "config/kitty/kitty.conf" ]; then
    print_info "Creating kitty.conf..."
    cat > config/kitty/kitty.conf <<EOF
# Set the default shell to zsh
shell /usr/bin/zsh

# Font configuration
font_family      FiraCode Nerd Font
bold_font        FiraCode Nerd Font Bold
italic_font      FiraCode Nerd Font Italic
bold_italic_font FiraCode Nerd Font Bold Italic
font_size 12.0

# Window settings
window_padding_width 4
hide_window_decorations yes
remember_window_size  no
initial_window_width  80c
initial_window_height 24c
enable_audio_bell no

# Theme
background_opacity 0.95
dynamic_background_opacity yes

# Color scheme
foreground #f1faee
background rgb(0, 0, 0)

# Black
color0 #1d3557
color8 #457b9d

# Red
color1 #e63946
color9 #e63946

# Green
color2  #2a9d8f
color10 #2a9d8f

# Yellow
color3  #e9c46a
color11 #e9c46a

# Blue
color4  #a8dadc
color12 #a8dadc

# Magenta
color5  #cdb4db
color13 #cdb4db

# Cyan
color6  #48cae4
color14 #48cae4

# White
color7  #f1faee
color15 #f1faee

# Tab bar
tab_bar_edge bottom
tab_bar_style powerline

# Keyboard shortcuts
map ctrl+shift+c copy_to_clipboard
map ctrl+shift+v paste_from_clipboard
map ctrl+shift+equal change_font_size all +1.0
map ctrl+shift+minus change_font_size all -1.0
map ctrl+shift+0 change_font_size all 0
EOF
fi

print_info "Checking for FiraCode Nerd Font..."
if ! fc-list | grep -i "FiraCode Nerd Font" &>/dev/null; then
    print_info "Installing FiraCode Nerd Font..."
    
    tmp_dir=$(mktemp -d)
    cd "$tmp_dir"
    
    wget -q "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/FiraCode.zip"
    unzip -q FiraCode.zip -d firacode
    
    mkdir -p ~/.local/share/fonts
    
    cp -f firacode/*.ttf ~/.local/share/fonts/
    
    fc-cache -f
    
    cd - > /dev/null
    rm -rf "$tmp_dir"
    
    print_success "✅ FiraCode Nerd Font installed."
else
    print_info "FiraCode Nerd Font is already installed."
fi

print_success "✅ kitty terminal setup complete. Configuration will be applied by setup-config-files.sh" 