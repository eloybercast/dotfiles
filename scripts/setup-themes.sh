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

### --- Install Sweet-Dark GTK Theme ---
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

### --- Install Tela-circle Icons (Dark + Light) ---
print_info "📦 Installing Tela-circle icons..."
if [ ! -d "$HOME/.icons/Tela-circle-dark" ]; then
    TMPDIR=$(mktemp -d)
    git clone --depth=1 https://github.com/vinceliuice/Tela-circle-icon-theme.git "$TMPDIR"
    "$TMPDIR"/install.sh -d ~/.icons -a
    rm -rf "$TMPDIR"
else
    print_info "Tela-circle icons already installed, skipping."
fi

### --- Install Bibata Cursors ---
print_info "🖱️ Installing Bibata cursors..."
if [ ! -d "$HOME/.icons/Bibata-Modern-Classic" ]; then
    TMPDIR=$(mktemp -d)
    git clone --depth=1 https://github.com/ful1e5/Bibata_Cursor.git "$TMPDIR"
    cp -r "$TMPDIR/Bibata-Modern-"* ~/.icons/
    rm -rf "$TMPDIR"
else
    print_info "Bibata cursors already installed, skipping."
fi

### --- Fonts ---
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
gtk-icon-theme-name=Tela-circle-dark
gtk-cursor-theme-name=Bibata-Modern-Classic
gtk-cursor-theme-size=24
gtk-font-name=JetBrainsMono Nerd Font 10
EOF

cp ~/.config/gtk-3.0/settings.ini ~/.config/gtk-4.0/settings.ini

cat <<EOF > ~/.gtkrc-2.0
gtk-theme-name="Sweet-Dark"
gtk-icon-theme-name="Tela-circle-dark"
gtk-cursor-theme-name="Bibata-Modern-Classic"
gtk-cursor-theme-size=24
gtk-font-name="JetBrainsMono Nerd Font 10"
EOF

print_success "✅ Themes, icons, cursors, and fonts installed and dark mode applied."

### --- Create toggle script ---
mkdir -p ~/.config/scripts
cat << 'EOF' > ~/.config/scripts/toggle-theme.sh
#!/bin/bash

DARK="Sweet-Dark"
LIGHT="Sweet"
ICON_DARK="Tela-circle-dark"
ICON_LIGHT="Tela-circle-light"
CURSOR="Bibata-Modern-Classic"
GTK3_FILE="$HOME/.config/gtk-3.0/settings.ini"
GTK4_FILE="$HOME/.config/gtk-4.0/settings.ini"
GTK2_FILE="$HOME/.gtkrc-2.0"

CURRENT=$(grep gtk-theme-name "$GTK3_FILE" | cut -d= -f2 | tr -d ' ')

if [[ "$CURRENT" == "$DARK" ]]; then
    echo "Switching to Light theme..."
    sed -i "s/gtk-theme-name=.*/gtk-theme-name=$LIGHT/" "$GTK3_FILE" "$GTK4_FILE"
    sed -i "s/gtk-icon-theme-name=.*/gtk-icon-theme-name=$ICON_LIGHT/" "$GTK3_FILE" "$GTK4_FILE"
    sed -i "s/gtk-theme-name=.*/gtk-theme-name=\"$LIGHT\"/" "$GTK2_FILE"
    sed -i "s/gtk-icon-theme-name=.*/gtk-icon-theme-name=\"$ICON_LIGHT\"/" "$GTK2_FILE"
else
    echo "Switching to Dark theme..."
    sed -i "s/gtk-theme-name=.*/gtk-theme-name=$DARK/" "$GTK3_FILE" "$GTK4_FILE"
    sed -i "s/gtk-icon-theme-name=.*/gtk-icon-theme-name=$ICON_DARK/" "$GTK3_FILE" "$GTK4_FILE"
    sed -i "s/gtk-theme-name=.*/gtk-theme-name=\"$DARK\"/" "$GTK2_FILE"
    sed -i "s/gtk-icon-theme-name=.*/gtk-icon-theme-name=\"$ICON_DARK\"/" "$GTK2_FILE"
fi

# cursor stays the same
EOF

chmod +x ~/.config/scripts/toggle-theme.sh
print_success "🔁 Theme toggle script created at ~/.config/scripts/toggle-theme.sh"
