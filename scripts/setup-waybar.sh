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
    wofi ttf-firacode-nerd \
    libnotify \
    pulseaudio-utils

print_info "Enabling and starting system services..."
sudo systemctl enable --now NetworkManager.service
sudo systemctl enable --now bluetooth.service

print_info "Setting up scripts..."
chmod +x config/scripts/general/powermenu.sh
if [ -f "config/scripts/general/nm-menu.sh" ]; then
    chmod +x config/scripts/general/nm-menu.sh
    print_info "Made network menu script executable."
fi

TIMEZONE=$(timedatectl show --property=Timezone --value)
print_info "Detected system timezone: $TIMEZONE"

if [ -f "config/waybar/config.jsonc" ]; then
    sed -i "s/\"timezone\": \".*\"/\"timezone\": \"$TIMEZONE\"/" config/waybar/config.jsonc
    print_info "Updated Waybar config with system timezone: $TIMEZONE"
fi

mkdir -p ~/.config/waybar
mkdir -p ~/.config/scripts/general

cp -rf config/waybar/* ~/.config/waybar/
cp -rf config/scripts/general/powermenu.sh ~/.config/scripts/general/
cp -rf config/scripts/general/nm-menu.sh ~/.config/scripts/general/
chmod +x ~/.config/scripts/general/powermenu.sh
chmod +x ~/.config/scripts/general/nm-menu.sh
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

# Set up default volume limits
print_info "Setting default volume limits..."
if [ -f ~/.config/pulse/daemon.conf ]; then
    # Backup existing config
    cp ~/.config/pulse/daemon.conf ~/.config/pulse/daemon.conf.bak
    # Update or add max volume setting
    if grep -q "max-volume =" ~/.config/pulse/daemon.conf; then
        sed -i 's/max-volume =.*/max-volume = 150/' ~/.config/pulse/daemon.conf
    else
        echo "max-volume = 150" >> ~/.config/pulse/daemon.conf
    fi
else
    # Create config directory and file if they don't exist
    mkdir -p ~/.config/pulse
    echo "max-volume = 150" > ~/.config/pulse/daemon.conf
fi

print_info "Reloading PulseAudio to apply volume settings..."
pulseaudio -k || true  # Kill PulseAudio if it's running
sleep 1
pulseaudio --start     # Restart PulseAudio

print_success "✅ Waybar setup complete with modern design, custom menus, and volume controls."
