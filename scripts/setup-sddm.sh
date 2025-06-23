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

# Install qt5 packages required by the theme
print_info "Installing Qt5 dependencies..."
sudo pacman -S --noconfirm qt5-graphicaleffects qt5-quickcontrols2 qt5-svg

# Clone the Chili theme
print_info "Installing Chili theme..."
TEMP_DIR=$(mktemp -d)
git clone https://github.com/MarianArlt/kde-plasma-chili.git "$TEMP_DIR/kde-plasma-chili"

# Create themes directory if it doesn't exist
sudo mkdir -p /usr/share/sddm/themes

# Remove any existing installation
sudo rm -rf /usr/share/sddm/themes/plasma-chili

# Install the theme with the correct name
print_info "Copying theme files..."
sudo cp -r "$TEMP_DIR/kde-plasma-chili" /usr/share/sddm/themes/plasma-chili

# Verify the theme files are correctly installed
if [ ! -f "/usr/share/sddm/themes/plasma-chili/Main.qml" ]; then
    print_error "Theme files not properly installed. Main.qml is missing."
    exit 1
fi

# Create both configuration directories if they don't exist
sudo mkdir -p /usr/lib/sddm/sddm.conf.d/
sudo mkdir -p /etc/sddm.conf.d/

# Configure SDDM to use the theme in all possible locations
print_info "Configuring SDDM to use Chili theme..."

# Create/update the main config file
cat << EOF | sudo tee /usr/lib/sddm/sddm.conf.d/10-theme.conf
[Theme]
Current=plasma-chili
EOF

# Also create a config in /etc
cat << EOF | sudo tee /etc/sddm.conf.d/10-theme.conf
[Theme]
Current=plasma-chili
EOF

# Also check for /etc/sddm.conf and update it if it exists
if [ -f "/etc/sddm.conf" ]; then
    print_info "Updating /etc/sddm.conf..."
    if grep -q "^\[Theme\]" /etc/sddm.conf; then
        sudo sed -i '/^\[Theme\]/,/^\[/ s/^Current=.*/Current=plasma-chili/' /etc/sddm.conf
    else
        echo -e "\n[Theme]\nCurrent=plasma-chili" | sudo tee -a /etc/sddm.conf > /dev/null
    fi
fi

# Set permissions
print_info "Setting proper permissions..."
sudo chmod -R 755 /usr/share/sddm/themes/plasma-chili

# Enable SDDM service
print_info "Enabling SDDM service..."
sudo systemctl enable sddm.service

# Clean up
rm -rf "$TEMP_DIR"

print_success "SDDM setup with Chili theme completed!"
print_info "Note: If you want to customize the theme, edit /usr/share/sddm/themes/plasma-chili/theme.conf"
print_info "You may need to restart your system for the theme changes to take effect." 