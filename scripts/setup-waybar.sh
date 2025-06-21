#!/bin/bash
set -e

source scripts/utils.sh

print_info "📊 Setting up Waybar..."

print_info "Installing Waybar and dependencies..."
sudo pacman -S --needed --noconfirm waybar \
    pamixer pulseaudio-alsa pavucontrol \
    brightnessctl \
    networkmanager network-manager-applet nm-connection-editor \
    bluez bluez-utils blueman \
    playerctl cava \
    wofi

print_info "Enabling and starting system services..."
sudo systemctl enable --now NetworkManager.service
sudo systemctl enable --now bluetooth.service

if [ -f "config/scripts/general/powermenu.sh" ]; then
    chmod +x config/scripts/general/powermenu.sh
    print_info "Made power menu script executable."
fi

TIMEZONE=$(timedatectl show --property=Timezone --value)
print_info "Detected system timezone: $TIMEZONE"

if [ -f "config/waybar/config.jsonc" ]; then
    sed -i "s/\"timezone\": \".*\"/\"timezone\": \"$TIMEZONE\"/" config/waybar/config.jsonc
    print_info "Updated Waybar config with system timezone: $TIMEZONE"
fi

mkdir -p ~/.config/waybar

cp -rf config/waybar/* ~/.config/waybar/
print_info "Copied Waybar configuration to user config directory."

print_info "Adding Waybar autostart to Hyprland config..."
if [ -f "config/hyprland/user.conf" ]; then
    if ! grep -q "waybar" "config/hyprland/user.conf"; then
        echo -e "\n# Start Waybar\nexec-once = waybar" >> config/hyprland/user.conf
    fi
fi

print_success "✅ Waybar setup complete with audio, networking, bluetooth, and power menu."
