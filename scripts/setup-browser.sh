#!/bin/bash
set -e

source ./utils.sh

require_dependency git base-devel xdg-settings

print_info "📦 Installing Brave browser from the AUR..."

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

print_info "🌐 Setting Brave as the default browser..."

if command -v brave &>/dev/null; then
    xdg-settings set default-web-browser brave-browser.desktop
    print_success "✅ Brave set as default browser."
else
    print_error "❌ Could not find brave binary to set default."
fi
