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

print_info "Creating kitty launch wrapper..."

mkdir -p ~/.local/bin

cat > ~/.local/bin/kitty-launch <<EOF
#!/bin/bash
export PATH="\$HOME/.local/bin:\$PATH"
exec kitty "\$@"
EOF

chmod +x ~/.local/bin/kitty-launch

if [ -f "config/hyprland/keybinds.conf" ]; then
    print_info "Updating Hyprland keybinds to use kitty-launch..."
    sed -i 's/\$terminal = kitty/\$terminal = kitty-launch/g' config/hyprland/keybinds.conf
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

print_success "✅ kitty terminal setup complete." 