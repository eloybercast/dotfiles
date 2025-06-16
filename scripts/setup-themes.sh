#!/bin/bash

# Utilities
source ~/.config/scripts/utils.sh 2>/dev/null || true

print_warning "🎨 Installing themes (GTK, icons, cursor)..."

# === Install lxappearance for theming ===
print_info "📥 Installing lxappearance..."
sudo pacman -S --noconfirm lxappearance

# === Setup directories ===
mkdir -p ~/.themes ~/.icons

# === Install Sweet GTK Theme ===
print_info "📦 Installing Sweet GTK theme..."
if [ ! -d "$HOME/.themes/Sweet-Dark" ]; then
    git clone https://github.com/EliverLara/Sweet.git /tmp/Sweet
    cp -r /tmp/Sweet/* ~/.themes/
    rm -rf /tmp/Sweet
fi

# === Install Candy Icons ===
print_info "📦 Installing Candy icons..."
if [ ! -d "$HOME/.icons/Candy" ]; then
    git clone https://github.com/EliverLara/candy-icons.git ~/.icons/Candy
fi

# === Install Sweet Cursors ===
print_info "🖱️ Installing Sweet cursors..."
if [ ! -d "$HOME/.icons/Sweet-cursors" ]; then
    git clone https://github.com/EliverLara/Sweet.git /tmp/SweetCursor
    cp -r /tmp/Sweet/cursors/Sweet-cursors ~/.icons/
    rm -rf /tmp/SweetCursor
fi

# === Apply dark theme defaults (manually via settings.ini) ===
print_info "🌓 Applying Dark theme defaults for GTK 3/4 and cursor..."
mkdir -p ~/.config/gtk-3.0
mkdir -p ~/.config/gtk-4.0

cat <<EOF > ~/.config/gtk-3.0/settings.ini
[Settings]
gtk-theme-name=Sweet-Dark
gtk-icon-theme-name=Candy
gtk-cursor-theme-name=Sweet-cursors
gtk-cursor-theme-size=24
gtk-font-name=Noto Sans 10
EOF

cp ~/.config/gtk-3.0/settings.ini ~/.config/gtk-4.0/settings.ini

cat <<EOF > ~/.gtkrc-2.0
gtk-theme-name="Sweet-Dark"
gtk-icon-theme-name="Candy"
gtk-cursor-theme-name="Sweet-cursors"
gtk-cursor-theme-size=24
gtk-font-name="Noto Sans 10"
EOF

print_success "✅ Themes installed and applied (Dark mode)"

# === Create toggle script for dark/light ===
mkdir -p ~/.config/scripts
cat << 'EOF' > ~/.config/scripts/toggle-theme.sh
#!/bin/bash

DARK="Sweet-Dark"
LIGHT="Sweet"
ICON="Candy"
CURSOR="Sweet-cursors"
GTK3_FILE="$HOME/.config/gtk-3.0/settings.ini"
GTK4_FILE="$HOME/.config/gtk-4.0/settings.ini"
GTK2_FILE="$HOME/.gtkrc-2.0"

CURRENT=$(grep gtk-theme-name "$GTK3_FILE" | cut -d= -f2)

if [[ "$CURRENT" == "$DARK" ]]; then
    echo "Switching to Light theme..."
    sed -i "s/gtk-theme-name=.*/gtk-theme-name=$LIGHT/" "$GTK3_FILE" "$GTK4_FILE"
    sed -i "s/gtk-theme-name=.*/gtk-theme-name=\"$LIGHT\"/" "$GTK2_FILE"
else
    echo "Switching to Dark theme..."
    sed -i "s/gtk-theme-name=.*/gtk-theme-name=$DARK/" "$GTK3_FILE" "$GTK4_FILE"
    sed -i "s/gtk-theme-name=.*/gtk-theme-name=\"$DARK\"/" "$GTK2_FILE"
fi
EOF

chmod +x ~/.config/scripts/toggle-theme.sh
print_success "🔁 Theme toggle available at ~/.config/scripts/toggle-theme.sh"
