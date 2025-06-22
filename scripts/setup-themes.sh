#!/bin/bash
set -e

source scripts/utils.sh

DARK_THEME="Adwaita-dark"
LIGHT_THEME="Adwaita"
DARK_ICON="candy-icons"
LIGHT_ICON="candy-icons"
CURSOR="Bibata-Modern-Ice"
FONT="Ubuntu 10"

setup_candy_icons() {
    print_info "Setting up Candy icons..."
    
    if ! command -v git &> /dev/null; then
        print_warning "Git is required but not installed. Installing git..."
        if command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm git
        elif command -v apt &> /dev/null; then
            sudo apt install -y git
        else
            print_error "Unsupported package manager. Please install git manually."
            return 1
        fi
    fi
    
    if [ -d "$HOME/.local/share/icons/candy-icons" ]; then
        print_info "Candy icons already installed, updating..."
        cd "$HOME/.local/share/icons/candy-icons"
        git pull
        cd - > /dev/null
    else
        print_info "Installing Candy icons..."
        mkdir -p "$HOME/.local/share/icons"
        git clone https://github.com/EliverLara/candy-icons.git "$HOME/.local/share/icons/candy-icons"
    fi
    
    if command -v gtk-update-icon-cache &> /dev/null; then
        gtk-update-icon-cache -f "$HOME/.local/share/icons/candy-icons"
    fi
    
    print_success "✅ Candy icons installed successfully"
}

setup_themes() {
    print_info "🎨 Applying Dark theme settings for GTK 3/4 and GTK 2..."
    
    setup_candy_icons
    
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
    
    print_success "✅ Dark theme applied with Ubuntu font and Candy icons. Use 'toggle-theme' command to switch between light and dark themes."
}

setup_themes
