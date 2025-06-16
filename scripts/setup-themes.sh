#!/bin/bash

# Utilities
source ~/.config/scripts/utils.sh 2>/dev/null || true

print_warning "🎨 Installing themes (GTK, icons, cursor)..."

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

# === Set initial theme to Dark ===
print_info "🌓 Applying Dark theme by default..."
gsettings set org.gnome.desktop.interface gtk-theme "Sweet-Dark"
gsettings set org.gnome.desktop.wm.preferences theme "Sweet-Dark"
gsettings set org.gnome.desktop.interface icon-theme "Candy"
gsettings set org.gnome.desktop.interface cursor-theme "Sweet-cursors"
gsettings set org.gnome.desktop.interface cursor-size 24
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'

print_success "✅ Themes installed and applied (Dark mode)"

# === Create toggle script ===
mkdir -p ~/.config/scripts
cat << 'EOF' > ~/.config/scripts/toggle-theme.sh
#!/bin/bash

DARK="Sweet-Dark"
LIGHT="Sweet"
ICON="Candy"
CURSOR="Sweet-cursors"

CURRENT=$(gsettings get org.gnome.desktop.interface gtk-theme | tr -d "'")

if [ "$CURRENT" == "$DARK" ]; then
    echo "Switching to Light theme..."
    gsettings set org.gnome.desktop.interface gtk-theme "$LIGHT"
    gsettings set org.gnome.desktop.wm.preferences theme "$LIGHT"
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
else
    echo "Switching to Dark theme..."
    gsettings set org.gnome.desktop.interface gtk-theme "$DARK"
    gsettings set org.gnome.desktop.wm.preferences theme "$DARK"
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
fi

# Reapply icon and cursor
gsettings set org.gnome.desktop.interface icon-theme "$ICON"
gsettings set org.gnome.desktop.interface cursor-theme "$CURSOR"
gsettings set org.gnome.desktop.interface cursor-size 24
EOF

chmod +x ~/.config/scripts/toggle-theme.sh
print_success "🔁 Theme toggle available at ~/.config/scripts/toggle-theme.sh"
