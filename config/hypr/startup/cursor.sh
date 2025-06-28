#!/bin/bash

# Apply directly to Hyprland
hyprctl setcursor Volantes_Cursors 24

# Apply with gsettings for GTK apps
gsettings set org.gnome.desktop.interface cursor-theme "Volantes_Cursors"
gsettings set org.gnome.desktop.interface cursor-size 24

# Apply to all GTK settings
for gtk_ver in "gtk-3.0" "gtk-4.0"; do
    GTK_SETTINGS="$HOME/.config/$gtk_ver/settings.ini"
    mkdir -p "$(dirname "$GTK_SETTINGS")"
    
    if [ -f "$GTK_SETTINGS" ]; then
        if grep -q "gtk-cursor-theme-name" "$GTK_SETTINGS"; then
            sed -i 's/gtk-cursor-theme-name=.*/gtk-cursor-theme-name=Volantes_Cursors/' "$GTK_SETTINGS"
        else
            echo "gtk-cursor-theme-name=Volantes_Cursors" >> "$GTK_SETTINGS"
        fi
        
        if grep -q "gtk-cursor-theme-size" "$GTK_SETTINGS"; then
            sed -i 's/gtk-cursor-theme-size=.*/gtk-cursor-theme-size=24/' "$GTK_SETTINGS"
        else
            echo "gtk-cursor-theme-size=24" >> "$GTK_SETTINGS"
        fi
    else
        echo "[Settings]" > "$GTK_SETTINGS"
        echo "gtk-cursor-theme-name=Volantes_Cursors" >> "$GTK_SETTINGS"
        echo "gtk-cursor-theme-size=24" >> "$GTK_SETTINGS"
    fi
done

# Apply to XDG settings
mkdir -p "$HOME/.icons/default"
cat > "$HOME/.icons/default/index.theme" << EOF
[Icon Theme]
Name=Default
Comment=Default Cursor Theme
Inherits=Volantes_Cursors
EOF

# Apply to Xresources
echo "Xcursor.theme: Volantes_Cursors" > "$HOME/.Xresources"
echo "Xcursor.size: 24" >> "$HOME/.Xresources"
xrdb -merge "$HOME/.Xresources" 2>/dev/null || true

# Force Qt settings
mkdir -p "$HOME/.config/qt5ct/qt5ct.conf"
cat > "$HOME/.config/qt5ct/qt5ct.conf" << EOF
[Appearance]
cursor_theme=Volantes_Cursors
EOF

# Final direct application
sleep 1
hyprctl setcursor Volantes_Cursors 24 