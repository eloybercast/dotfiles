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

# Create config directory placeholder if it doesn't exist
# The actual config will be copied by setup-config-files.sh
mkdir -p ~/.config/kitty

print_success "✅ kitty terminal installed. Configuration will be applied by setup-config-files.sh" 