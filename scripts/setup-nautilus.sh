#!/bin/bash
set -e

source scripts/utils.sh

setup_nautilus() {
    print_info "Setting up Nautilus file manager..."
    
    if command -v nautilus &> /dev/null; then
        print_success "Nautilus is already installed."
    else
        print_warning "Installing Nautilus and related packages..."
        sudo pacman -Syu --noconfirm nautilus gvfs gvfs-smb gvfs-afc gvfs-google
        print_success "Nautilus installed successfully."
    fi
    
    xdg-mime default nautilus.desktop inode/directory application/x-gnome-saved-search
    
    if [ -d "$HOME/.config/gtk-3.0" ]; then
        print_info "Ensuring Nautilus uses the correct icon theme..."
        
        if ! [ -d "$HOME/.local/share/icons/candy-icons" ]; then
            print_warning "Candy icons not found. Installing them first..."
            bash scripts/setup-themes.sh
        fi
        
        if command -v gsettings &> /dev/null; then
            gsettings set org.gnome.nautilus.icon-view default-zoom-level 'standard'
            gsettings set org.gnome.nautilus.preferences show-hidden-files true
            print_info "Nautilus preferences configured."
        fi
    fi
    
    print_success "✅ Nautilus and related utilities configured."
}

setup_nautilus
