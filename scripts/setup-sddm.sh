#!/bin/bash

source "$(dirname "$0")/utils.sh"

print_info "Setting up SDDM with Chili theme..."

if ! command -v sddm &> /dev/null; then
    print_warning "Installing SDDM..."
    sudo pacman -S --noconfirm sddm
fi

if ! pacman -Q sddm-kcm &> /dev/null; then
    print_warning "Installing SDDM KCM..."
    sudo pacman -S --noconfirm sddm-kcm
fi

if ! command -v git &> /dev/null; then
    print_warning "Installing git..."
    sudo pacman -S --noconfirm git
fi

sudo mkdir -p /usr/lib/sddm/sddm.conf.d/

print_info "Installing Chili theme..."
TEMP_DIR=$(mktemp -d)
git clone https://github.com/MarianArlt/kde-plasma-chili.git "$TEMP_DIR/kde-plasma-chili"

sudo mkdir -p /usr/share/sddm/themes

print_info "Copying theme files..."
sudo cp -r "$TEMP_DIR/kde-plasma-chili" /usr/share/sddm/themes/plasma-chili

print_info "Configuring SDDM to use Chili theme..."
cat << EOF | sudo tee /usr/lib/sddm/sddm.conf.d/10-theme.conf
[Theme]
Current=plasma-chili
EOF

if [ -f "/etc/sddm.conf" ]; then
    print_info "Updating /etc/sddm.conf..."
    if grep -q "^\[Theme\]" /etc/sddm.conf; then
        sudo sed -i '/^\[Theme\]/,/^\[/ s/^Current=.*/Current=plasma-chili/' /etc/sddm.conf
    else
        echo -e "\n[Theme]\nCurrent=plasma-chili" | sudo tee -a /etc/sddm.conf > /dev/null
    fi
fi

print_info "Enabling SDDM service..."
sudo systemctl enable sddm.service

rm -rf "$TEMP_DIR"

print_success "SDDM setup with Chili theme completed!"
print_info "Note: If you want to customize the theme, edit /usr/share/sddm/themes/plasma-chili/theme.conf" 