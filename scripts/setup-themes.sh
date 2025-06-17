#!/bin/bash
set -e

DARK_THEME="Adwaita-dark"
LIGHT_THEME="Adwaita"
DARK_ICON="Papirus-Dark"
LIGHT_ICON="Papirus"
CURSOR="Bibata-Modern-Ice"
FONT="Ubuntu 10"

echo "🎨 Applying Dark theme settings for GTK 3/4 and GTK 2..."

if command -v gsettings &> /dev/null; then
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
    gsettings set org.gnome.desktop.interface gtk-theme "$DARK_THEME"
    gsettings set org.gnome.desktop.interface icon-theme "$DARK_ICON"
fi

mkdir -p ~/.config/gtk-3.0 ~/.config/gtk-4.0

cat <<EOF > ~/.config/gtk-3.0/settings.ini
[Settings]
gtk-theme-name=$DARK_THEME
gtk-icon-theme-name=$DARK_ICON
gtk-cursor-theme-name=$CURSOR
gtk-cursor-theme-size=24
gtk-font-name=$FONT
gtk-application-prefer-dark-theme=1
EOF

cp ~/.config/gtk-3.0/settings.ini ~/.config/gtk-4.0/settings.ini

cat <<EOF > ~/.gtkrc-2.0
gtk-theme-name="$DARK_THEME"
gtk-icon-theme-name="$DARK_ICON"
gtk-cursor-theme-name="$CURSOR"
gtk-cursor-theme-size=24
gtk-font-name="$FONT"
EOF

mkdir -p ~/.local/bin
if [ ! -L ~/.local/bin/toggle-theme ]; then
    ln -sf ~/.config/scripts/general/toggle-theme.sh ~/.local/bin/toggle-theme
    chmod +x ~/.local/bin/toggle-theme
fi

echo "✅ Dark theme applied with Ubuntu font. Use 'toggle-theme' command to switch between light and dark themes."
