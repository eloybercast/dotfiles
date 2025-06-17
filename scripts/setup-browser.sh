#!/bin/bash
set -e

source scripts/utils.sh

install_dependency() {
    if ! command -v "$1" &>/dev/null; then
        print_info "Installing dependency: $1"
        sudo pacman -S --needed --noconfirm "$1"
    else
        print_info "Dependency $1 already installed."
    fi
}

install_dependency git
install_dependency base-devel
install_dependency xdg-utils

print_info "📦 Checking Firefox browser installation..."

if command -v firefox &>/dev/null; then
    print_info "Firefox is already installed, skipping installation."
else
    print_info "Firefox not found, installing with pacman..."
    sudo pacman -S --needed --noconfirm firefox
    print_success "✅ Firefox installed."
fi

print_info "🌐 Setting Firefox as the default browser..."

if command -v firefox &>/dev/null; then
    xdg-settings set default-web-browser firefox.desktop
    print_success "✅ Firefox set as default browser."
else
    print_error "❌ Could not find Firefox binary to set default."
fi
