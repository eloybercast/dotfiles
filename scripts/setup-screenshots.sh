#!/bin/bash

source $(dirname "$0")/utils.sh

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
DOTFILES_DIR=$(dirname "$SCRIPT_DIR")
CONFIG_DIR="$DOTFILES_DIR/config"

print_info "Setting up screenshot functionality..."

mkdir -p "$HOME/Images/Screenshots"
print_info "Created Screenshots directory at $HOME/Images/Screenshots"

print_info "Installing required packages..."
if command -v pacman &> /dev/null; then
    sudo pacman -S --needed --noconfirm grim slurp wl-clipboard pulseaudio-utils xdg-utils
elif command -v apt &> /dev/null; then
    sudo apt install -y grim slurp wl-clipboard pulseaudio-utils xdg-utils
fi

print_info "Setting up screenshot script..."
mkdir -p "$HOME/.config/scripts/general"
cp "$CONFIG_DIR/scripts/general/screenshot.sh" "$HOME/.config/scripts/general/"
chmod +x "$HOME/.config/scripts/general/screenshot.sh"

print_success "Screenshot functionality setup completed!" 