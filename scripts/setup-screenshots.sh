#!/bin/bash

source "$(dirname "$0")/utils.sh"

print_info "🖼️ Setting up screenshot functionality..."

print_info "Creating Screenshots directory..."
mkdir -p ~/Images/Screenshots

print_info "Installing dependencies for screenshots..."
sudo pacman -S --noconfirm --needed grim slurp wl-clipboard

print_info "Setting up screenshot script..."
mkdir -p ~/.config/scripts/general/
cp "$(dirname "$0")/../config/scripts/general/screenshot.sh" ~/.config/scripts/general/
chmod +x ~/.config/scripts/general/screenshot.sh

print_success "✅ Screenshot functionality set up successfully!"

exit 0 