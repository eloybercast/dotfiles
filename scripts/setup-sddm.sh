#!/bin/bash

source "$(dirname "$0")/utils.sh"

print_info "Setting up SDDM with Chili theme..."

if ! command -v sddm &> /dev/null; then
    print_warning "Installing SDDM..."
    sudo pacman -S --noconfirm sddm
fi

sudo mkdir -p /etc/sddm.conf.d

print_info "Enabling SDDM service..."
sudo systemctl enable sddm.service

if ! command -v git &> /dev/null; then
    print_warning "Installing git..."
    sudo pacman -S --noconfirm git
fi

print_info "Installing Chili theme..."
TEMP_DIR=$(mktemp -d)
git clone https://github.com/MarianArlt/kde-plasma-chili.git "$TEMP_DIR/chili"

sudo mkdir -p /usr/share/sddm/themes

sudo cp -r "$TEMP_DIR/chili" /usr/share/sddm/themes/

print_info "Configuring SDDM to use Chili theme..."
cat << EOF | sudo tee /etc/sddm.conf.d/10-theme.conf
[Theme]
Current=chili
EOF

rm -rf "$TEMP_DIR"

print_success "SDDM setup with Chili theme completed!" 