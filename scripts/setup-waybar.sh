#!/bin/bash
set -e

source scripts/utils.sh

print_info "📊 Setting up Waybar..."

print_info "Installing Waybar and dependencies..."
sudo pacman -S --needed --noconfirm waybar pamixer pulseaudio-alsa pavucontrol brightnessctl networkmanager bluez bluez-utils playerctl cava

if [ -f "config/scripts/general/powermenu.sh" ]; then
    chmod +x config/scripts/general/powermenu.sh
    print_info "Made power menu script executable."
fi

print_info "Adding Waybar autostart to Hyprland config..."
if [ -f "config/hyprland/user.conf" ]; then
    if ! grep -q "waybar" "config/hyprland/user.conf"; then
        echo -e "\n# Start Waybar\nexec-once = waybar" >> config/hyprland/user.conf
    fi
fi

print_success "✅ Waybar setup complete with audio visualizer, system info, and power menu."
