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

print_info "Configuring kitty terminal..."
cp -r config/kitty/* ~/.config/kitty/

print_success "✅ kitty terminal configured with zsh as default shell." 