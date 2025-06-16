#!/bin/bash
set -e

source ~/.config/scripts/utils.sh 2>/dev/null || true

print_warning "🎨 Installing themes, icons, cursors, and fonts..."

# Ensure required tools are present
for cmd in curl tar git; do
    if ! command -v $cmd &>/dev/null; then
        echo "❌ Missing required tool: $cmd"
        exit 1
    fi
done

print_info "📥 Installing lxappearance..."
if ! command -v lxappearance &>/dev/null; then
    sudo pacman -S --noconfirm lxappearance
else
    print_info "lxappearance already installed, skipping."
fi

mkdir -p ~/.themes ~/.icons ~/.local/share/fonts

### --- Install GTK Theme ---
print_info "📦 Installing Sweet GTK theme (Dark variant)..."
if [ ! -d "$HOME/.themes/Sweet-Dark" ]; then
    TMPDIR=$(mktemp -d)
    curl -L https://github.com/EliverLara/Sweet/releases/download/v6.0/Sweet-Dark.tar.xz -o "$TMPDIR/Sweet-Dark.tar.xz"
    tar -xf "$TMPDIR/Sweet-Dark.tar.xz" -C "$TMPDIR"
    mv "$TMPDIR/Sweet-Dark" ~/.themes/
    rm -rf "$TMPDIR"
else
    print_info "Sweet-Dark GTK theme already installed, skipping."
fi

### --- Install Papirus Icon Theme (Dark and Light variants supported) ---
print_info "🎨 Installing Papirus icon theme..."
if [ ! -d "$HOME/.icons/Papirus-Dark" ]; then
    git clone https://github.com/PapirusDevelopmentTeam/papirus-icon-theme.git /tmp/papirus
    mkdir -p ~/.icons
    cp -r /tmp/papirus/Papirus* ~/.icons/
    rm -rf /tmp/papirus
else
    print_info "Papirus icon theme already installed, skipping."
fi

### --- Install Bibata Cursor (Modern, smooth, light/dark support) ---
print_info "🖱️ Installing Bibata cursor theme..."
if [ ! -d "$HOME/.icons/Bibata-Modern-Ice" ]; then
    git clone https://github.com/ful1e5/Bibata_Cursor.git /tmp/bibata
    mkdir -p ~/.icons
    cp -r /tmp/bibata/Bibata-* ~/.icons/
    rm -rf /tmp/bibata
else
    print_info "Bibata cursor already installed, skipping."
fi

### --- Install Fonts ---
print_info "🔤 Installing recommended fonts..."

font_installed() {
    fc-list | grep -i "$1" &>/dev/null
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

### --- Apply GTK Settings ---
print_info "🌓 Applying Dark theme defaults for GTK 3/4 and cursor..."
mkdir -p ~/.config/gtk-3.0 ~/.config/gtk-4.0

cat <<EOF > ~/.config/gtk-3.0/settings.ini
[Settings]
gtk-theme-name=Sweet-Dark
gtk-icon-theme-name=Papirus-Dark
gtk-cursor-theme-name=Bibata-Modern-Ice
gtk-cursor-theme-size=24
gtk-font-name=JetBrainsMono Nerd Font 10
EOF

cp ~/.config/gtk-3.0/settings.ini ~/.config/gtk-4.0/settings.ini

cat <<EOF > ~/.gtkrc-2.0
gtk-theme-name="Sweet-Dark"
gtk-icon-theme-name="Papirus-Dark"
gtk-cursor-theme-name="Bibata-Modern-Ice"
gtk-cursor-theme-size=24
gtk-font-name="JetBrainsMono Nerd Font 10"
EOF

### --- Enable Thunar 'Show Hidden Files' ---
print_info "📁 Enabling 'Show Hidden Files' in Thunar..."
xfconf-query -c thunar -p /misc-show-hidden -s true || print_warning "⚠️ Could not set Thunar 'Show Hidden Files'. Skipping."

print_success "✅ Themes, icons, cursors, fonts installed and dark mode applied."

### --- Theme Toggle Script ---
print_info "🔁 Creating toggle script..."
mkdir -p ~/.config/scripts
cat << 'EOF' > ~/.config/scripts/toggle-theme.sh
#!/bin/bash

DARK_THEME="Sweet-Dark"
LIGHT_THEME="Sweet"
DARK_ICON="Papirus-Dark"
LIGHT_ICON="Papirus"
CURSOR="Bibata-Modern-Ice"

GTK3="$HOME/.config/gtk-3.0/settings.ini"
GTK4="$HOME/.config/gtk-4.0/settings.ini"
GTK2="$HOME/.gtkrc-2.0"

CURRENT=$(grep gtk-theme-name "$GTK3" | cut -d= -f2 | tr -d ' ')

if [[ "$CURRENT" == "$DARK_THEME" ]]; then
    echo "🔆 Switching to Light theme..."
    sed -i "s/gtk-theme-name=.*/gtk-theme-name=$LIGHT_THEME/" "$GTK3" "$GTK4"
    sed -i "s/gtk-theme-name=.*/gtk-theme-name=\"$LIGHT_THEME\"/" "$GTK2"
    sed -i "s/gtk-icon-theme-name=.*/gtk-icon-theme-name=$LIGHT_ICON/" "$GTK3" "$GTK4"
    sed -i "s/gtk-icon-theme-name=.*/gtk-icon-theme-name=\"$LIGHT_ICON\"/" "$GTK2"
else
    echo "🌙 Switching to Dark theme..."
    sed -i "s/gtk-theme-name=.*/gtk-theme-name=$DARK_THEME/" "$GTK3" "$GTK4"
    sed -i "s/gtk-theme-name=.*/gtk-theme-name=\"$DARK_THEME\"/" "$GTK2"
    sed -i "s/gtk-icon-theme-name=.*/gtk-icon-theme-name=$DARK_ICON/" "$GTK3" "$GTK4"
    sed -i "s/gtk-icon-theme-name=.*/gtk-icon-theme-name=\"$DARK_ICON\"/" "$GTK2"
fi
EOF

chmod +x ~/.config/scripts/toggle-theme.sh
print_success "🔁 Theme toggle script created at ~/.config/scripts/toggle-theme.sh"
