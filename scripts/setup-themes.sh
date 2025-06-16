#!/bin/bash
set -e

# Use Adwaita-dark for best compatibility
DARK_THEME="Adwaita-dark"
DARK_ICON="Papirus-Dark"
CURSOR="Bibata-Modern-Ice"
FONT="JetBrainsMono Nerd Font 10"

echo "🎨 Applying Dark theme settings for GTK 3/4 and GTK 2..."

mkdir -p ~/.config/gtk-3.0 ~/.config/gtk-4.0

cat <<EOF > ~/.config/gtk-3.0/settings.ini
[Settings]
gtk-theme-name=$DARK_THEME
gtk-icon-theme-name=$DARK_ICON
gtk-cursor-theme-name=$CURSOR
gtk-cursor-theme-size=24
gtk-font-name=$FONT
EOF

cp ~/.config/gtk-3.0/settings.ini ~/.config/gtk-4.0/settings.ini

cat <<EOF > ~/.gtkrc-2.0
gtk-theme-name="$DARK_THEME"
gtk-icon-theme-name="$DARK_ICON"
gtk-cursor-theme-name="$CURSOR"
gtk-cursor-theme-size=24
gtk-font-name="$FONT"
EOF

echo "✅ Dark theme applied."
