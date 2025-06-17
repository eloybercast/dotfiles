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

print_info "🎨 Configuring Firefox to follow system theme..."

FIREFOX_DIR="$HOME/.mozilla/firefox"
if [ -d "$FIREFOX_DIR" ]; then
    PROFILE_DIR=$(find "$FIREFOX_DIR" -name "*.default-release" -type d | head -n 1)
    
    if [ -z "$PROFILE_DIR" ]; then
        PROFILE_DIR=$(find "$FIREFOX_DIR" -name "*.default*" -type d | head -n 1)
    fi
    
    if [ -n "$PROFILE_DIR" ]; then
        mkdir -p "$PROFILE_DIR/chrome"
        
        cat <<EOF > "$PROFILE_DIR/user.js"
user_pref("browser.theme.toolbar-theme", 0);
user_pref("browser.theme.content-theme", 0);
user_pref("browser.uidensity", 0);
user_pref("browser.theme.dark-private-windows", true);
user_pref("ui.systemUsesDarkTheme", 1);
user_pref("widget.content.allow-gtk-dark-theme", true);
EOF
        print_success "✅ Firefox configured to follow system theme."
    else
        print_warning "⚠️ Firefox profile directory not found. Run Firefox once to create a profile."
    fi
else
    print_warning "⚠️ Firefox directory not found. Run Firefox once to create configuration."
fi
