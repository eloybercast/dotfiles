#!/bin/bash

source "$(dirname "$0")/utils.sh"

mkdir -p "$HOME/.config/sddm"
mkdir -p "$HOME/Documents/eloybercast/dotfiles/config/sddm"

print_info "Installing SDDM and dependencies..."
sudo pacman -S --needed --noconfirm sddm qt5-graphicaleffects qt5-quickcontrols2 qt5-svg plasma-framework plasma-workspace kde-cli-tools

print_info "Installing Chili theme for SDDM..."
TEMP_DIR=$(mktemp -d)
git clone https://github.com/MarianArlt/kde-plasma-chili.git "$TEMP_DIR/chili"

sudo mkdir -p /usr/share/sddm/themes
sudo cp -r "$TEMP_DIR/chili" /usr/share/sddm/themes/

cp -r "$TEMP_DIR/chili" "$HOME/Documents/eloybercast/dotfiles/config/sddm/"

rm -rf "$TEMP_DIR"

ln -sf "$HOME/Documents/eloybercast/dotfiles/config/sddm/theme.conf" "$HOME/.config/sddm/theme.conf"

print_info "Configuring SDDM to use Chili theme..."
sudo mkdir -p /etc/sddm.conf.d
cat << EOF | sudo tee /etc/sddm.conf.d/10-theme.conf
[Theme]
Current=chili
EOF

if [ ! -f "/usr/share/backgrounds/Room1.png" ]; then
    print_info "Copying Room1.png wallpaper to system backgrounds..."
    sudo mkdir -p /usr/share/backgrounds
    sudo cp "$HOME/Documents/eloybercast/dotfiles/assets/wallpapers/Room1.png" /usr/share/backgrounds/
fi

print_info "Enabling SDDM service..."
sudo systemctl enable sddm.service

print_success "SDDM setup complete with Chili theme!" 