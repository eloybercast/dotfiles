#!/bin/bash
set -e

source scripts/utils.sh

print_info "📊 Setting up Waybar..."

print_info "Installing Waybar and dependencies..."
sudo pacman -S --needed --noconfirm waybar \
    pamixer pulseaudio-alsa pavucontrol alsa-utils \
    brightnessctl \
    networkmanager network-manager-applet nm-connection-editor \
    bluez bluez-utils blueman \
    playerctl cava \
    wofi ttf-firacode-nerd \
    libnotify

print_info "Enabling and starting system services..."
sudo systemctl enable --now NetworkManager.service
sudo systemctl enable --now bluetooth.service

print_info "Setting up scripts..."

if [ -f "config/scripts/general/toggle-theme.sh" ]; then
    chmod +x config/scripts/general/toggle-theme.sh
    print_info "Made theme toggle script executable."
fi

if [ -d "config/scripts/waybar" ]; then
    chmod +x config/scripts/waybar/*.sh
    print_info "Made waybar control scripts executable."
fi

TIMEZONE=$(timedatectl show --property=Timezone --value)
print_info "Detected system timezone: $TIMEZONE"

if [ -f "config/waybar/config.jsonc" ]; then
    sed -i "s/\"timezone\": \".*\"/\"timezone\": \"$TIMEZONE\"/" config/waybar/config.jsonc
    print_info "Updated Waybar config with system timezone: $TIMEZONE"
fi

mkdir -p ~/.config/waybar
mkdir -p ~/.config/scripts/general
mkdir -p ~/.config/scripts/waybar

cp -rf config/waybar/* ~/.config/waybar/

if [ -f "config/scripts/general/toggle-theme.sh" ]; then
    cp config/scripts/general/toggle-theme.sh ~/.config/scripts/general/
    chmod +x ~/.config/scripts/general/toggle-theme.sh
fi

if [ -d "config/scripts/waybar" ]; then
    cp -rf config/scripts/waybar/* ~/.config/scripts/waybar/
    chmod +x ~/.config/scripts/waybar/*.sh
fi

print_info "Copied Waybar configuration and scripts to user config directory."

print_info "Adding Waybar autostart to Hyprland config..."
if [ -f "config/hyprland/user.conf" ]; then
    if ! grep -q "waybar" "config/hyprland/user.conf"; then
        echo -e "\n# Start Waybar\nexec-once = waybar" >> config/hyprland/user.conf
    fi
fi

if pgrep -x "waybar" > /dev/null; then
    killall waybar
    waybar &
    print_info "Restarted Waybar with new configuration."
fi

print_success "✅ Waybar setup complete with all scripts properly organized."
