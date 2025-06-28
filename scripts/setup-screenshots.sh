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
    sudo pacman -S --needed --noconfirm grim slurp wl-clipboard pulseaudio-utils xdg-utils mako libnotify
elif command -v apt &> /dev/null; then
    sudo apt install -y grim slurp wl-clipboard pulseaudio-utils xdg-utils mako libnotify-bin
fi

print_info "Setting up screenshot script..."
mkdir -p "$HOME/.config/scripts/general"
cp "$CONFIG_DIR/scripts/general/screenshot.sh" "$HOME/.config/scripts/general/"
chmod +x "$HOME/.config/scripts/general/screenshot.sh"

print_info "Adding sound files..."
if [ ! -d "/usr/share/sounds/freedesktop/stereo" ]; then
    sudo mkdir -p /usr/share/sounds/freedesktop/stereo
fi

if [ ! -f "/usr/share/sounds/freedesktop/stereo/screen-capture.oga" ]; then
    print_info "Downloading screenshot sound file..."
    TEMP_DIR=$(mktemp -d)
    wget -q -O "$TEMP_DIR/screen-capture.oga" "https://raw.githubusercontent.com/freedesktop/sound-theme-freedesktop/master/stereo/screen-capture.oga"
    sudo cp "$TEMP_DIR/screen-capture.oga" /usr/share/sounds/freedesktop/stereo/
    rm -rf "$TEMP_DIR"
    print_info "Screenshot sound installed"
fi

print_success "Screenshot functionality setup completed!" 