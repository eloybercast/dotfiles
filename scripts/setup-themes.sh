#!/bin/bash

source ~/.config/scripts/utils.sh 2>/dev/null || true

print_warning "🎨 Installing themes, icons, cursors, and fonts..."

print_info "📥 Installing lxappearance..."
if ! command -v lxappearance >/dev/null 2>&1; then
    sudo pacman -S --noconfirm lxappearance
else
    print_info "lxappearance already installed, skipping."
fi

mkdir -p ~/.themes ~/.icons ~/.local/share/fonts

print_info "📦 Installing Sweet GTK theme..."
if [ ! -d "$HOME/.themes/Sweet-Dark" ]; then
    git clone https://github.com/EliverLara/Sweet.git /tmp/Sweet
    cp -r /tmp/Sweet/* ~/.themes/
    rm -rf /tmp/Sweet
else
    print_info "Sweet GTK theme already installed, skipping."
fi

print_info "📦 Installing Candy icons..."
if [ ! -d "$HOME/.icons/Candy" ]; then
    git clone https://github.com/EliverLara/candy-icons.git ~/.icons/Candy
else
    print_info "Candy icons already installed, skipping."
fi

print_info "🖱️ Installing Sweet cursors..."
if [ ! -d "$HOME/.icons/Sweet-cursors" ]; then
    git clone https://github.com/EliverLara/Sweet.git /tmp/SweetCursor
    cp -r /tmp/Sweet/cursors/Sweet-cursors ~/.icons/
    rm -rf /tmp/SweetCursor
else
    print_info "Sweet cursors already installed, skipping."
fi

print_info "🔤 Installing recommended fonts..."

font_installed() {
    fc-list | grep -i "$1" >/dev/null 2>&1
}

if ! font_installed "JetBrainsMono Nerd Font"; then
    print_info "Installing JetBrains Mono Nerd Font..."
    sudo pacman -S --noconfirm ttf-jetbrains-mono-nerd
else
    print_info "JetBrains Mono Nerd Font already installed."
fi

if ! font_installed "Noto Sans"; then
    print_info "Installing Noto fonts (Sans, CJK, Emoji)..."
    sudo pacman -S --noconfirm noto-fonts noto-fonts-cjk noto-fonts-emoji
else
    print_info "Noto fonts already installed."
fi

if ! font_installed "Fira Code"; then
    print_info "Installing Fira Code and Fira Sans..."
    sudo pacman -S --noconfirm ttf-fira-code ttf-fira-sans
else
    print_info "Fira fonts already installed."
fi

print_info "🌓 Applying Dark theme defaults for GTK 3/4 and cursor..."
mkdir -p ~/.config/gtk-3.0 ~/.config/gtk-4.0

cat <<EOF > ~/.config/gtk-3.0/settings.ini
[Settings]
gtk-theme-name=Sweet-Dark
gtk-icon-theme-name=Candy
gtk-cursor-theme-name=Sweet-cursors
gtk-cursor-theme-size=24
gtk-font-name=JetBrainsMono Nerd Font 10
EOF

cp ~/.config/gtk-3.0/settings.ini ~/.config/gtk-4.0/settings.ini

cat <<EOF > ~/.gtkrc-2.0
gtk-theme-name="Sweet-Dark"
gtk-icon-theme-name="Candy"
gtk-cursor-theme-name="Sweet-cursors"
gtk-cursor-theme-size=24
gtk-font-name="JetBrainsMono Nerd Font 10"
EOF

print_success "✅ Themes, icons, cursors, and fonts installed and dark mode applied."

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

CURRENT=$(grep gtk-theme-name "$GTK3_FILE" | cut -d= -f2 | tr -d ' ')

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
print_success "🔁 Theme toggle script created at ~/.config/scripts/toggle-theme.sh"
