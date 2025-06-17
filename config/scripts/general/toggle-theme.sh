#!/bin/bash
set -e

CURRENT_THEME=$(gsettings get org.gnome.desktop.interface color-scheme)

if [[ $CURRENT_THEME == *"prefer-dark"* ]]; then
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
    gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita'
    gsettings set org.gnome.desktop.interface icon-theme 'Papirus'
    
    sed -i 's/gtk-application-prefer-dark-theme=1/gtk-application-prefer-dark-theme=0/' ~/.config/gtk-3.0/settings.ini
    sed -i 's/gtk-application-prefer-dark-theme=1/gtk-application-prefer-dark-theme=0/' ~/.config/gtk-4.0/settings.ini
    
    echo "Switched to light theme"
else
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
    gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
    gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'
    
    sed -i 's/gtk-application-prefer-dark-theme=0/gtk-application-prefer-dark-theme=1/' ~/.config/gtk-3.0/settings.ini
    sed -i 's/gtk-application-prefer-dark-theme=0/gtk-application-prefer-dark-theme=1/' ~/.config/gtk-4.0/settings.ini
    
    echo "Switched to dark theme"
fi

if pgrep -x "firefox" > /dev/null; then
    echo "Firefox is running. You may need to restart it for theme changes to take effect."
fi 