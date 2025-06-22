#!/bin/bash
set -e

CURRENT_THEME=$(gsettings get org.gnome.desktop.interface color-scheme)

if [[ $CURRENT_THEME == *"prefer-dark"* ]]; then
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
    gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita'
    gsettings set org.gnome.desktop.interface icon-theme 'candy-icons'
    
    sed -i 's/gtk-application-prefer-dark-theme=1/gtk-application-prefer-dark-theme=0/' ~/.config/gtk-3.0/settings.ini
    sed -i 's/gtk-application-prefer-dark-theme=1/gtk-application-prefer-dark-theme=0/' ~/.config/gtk-4.0/settings.ini
    
    echo "Switched to light theme with Candy icons"
else
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
    gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
    gsettings set org.gnome.desktop.interface icon-theme 'candy-icons'
    
    sed -i 's/gtk-application-prefer-dark-theme=0/gtk-application-prefer-dark-theme=1/' ~/.config/gtk-3.0/settings.ini
    sed -i 's/gtk-application-prefer-dark-theme=0/gtk-application-prefer-dark-theme=1/' ~/.config/gtk-4.0/settings.ini
    
    echo "Switched to dark theme with Candy icons"
fi

if pgrep -x "firefox" > /dev/null; then
    echo "Firefox is running. You may need to restart it for theme changes to take effect."
fi 
