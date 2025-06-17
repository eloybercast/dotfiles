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

print_info "📦 Checking Brave browser installation..."

if command -v brave &>/dev/null || command -v brave-browser &>/dev/null; then
    print_info "Brave browser is already installed, skipping build."
else
    print_info "Brave not found, installing from AUR..."

    if [[ -d brave-bin ]]; then
        print_warning "Removing old brave-bin directory..."
        rm -rf brave-bin
    fi

    git clone https://aur.archlinux.org/brave-bin.git
    cd brave-bin
    makepkg -si --noconfirm
    cd ..
    rm -rf brave-bin

    print_success "✅ Brave installed."
fi

print_info "🌐 Setting Brave as the default browser..."

BROWSER_BIN=""

if command -v brave &>/dev/null; then
    BROWSER_BIN="brave"
elif command -v brave-browser &>/dev/null; then
    BROWSER_BIN="brave-browser"
fi

if [[ -n "$BROWSER_BIN" ]]; then
    xdg-settings set default-web-browser brave-browser.desktop
    print_success "✅ Brave set as default browser."
else
    print_error "❌ Could not find Brave binary to set default."
fi
