#!/bin/bash
set -e

source ./utils.sh

require_dependency git base-devel xdg-settings

BROWSER=$(ask_selection "🌐 Select your preferred browser to install:" "Brave" "Chromium" "Firefox" "Google Chrome" "Quit")

if [[ "$BROWSER" == "Quit" ]]; then
    print_warning "No browser selected. Exiting."
    exit 0
fi

# Map to AUR package name
case "$BROWSER" in
    Brave)          PKG_NAME="brave-bin" ;;
    Chromium)       PKG_NAME="chromium" ;;
    Firefox)        PKG_NAME="firefox" ;;
    "Google Chrome")PKG_NAME="google-chrome" ;;
    *)              print_error "Unknown browser selection"; exit 1 ;;
esac

print_info "📦 Cloning AUR package: $PKG_NAME"
git clone "https://aur.archlinux.org/${PKG_NAME}.git"
cd "$PKG_NAME"
makepkg -si
cd ..
rm -rf "$PKG_NAME"

print_success "✅ $BROWSER installed."

# Set as default browser
BROWSER_BIN=$(command -v brave 2>/dev/null || command -v chromium 2>/dev/null || command -v firefox 2>/dev/null || command -v google-chrome-stable 2>/dev/null)

if [[ -n "$BROWSER_BIN" ]]; then
    xdg-settings set default-web-browser "$(basename "$BROWSER_BIN").desktop"
    print_success "🌐 $BROWSER set as the default browser."
else
    print_warning "⚠️ Couldn't determine the binary to set as default."
fi
