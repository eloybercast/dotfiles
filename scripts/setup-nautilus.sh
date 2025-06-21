#!/bin/bash
set -e

print_success() {
    echo -e "\e[32m$1\e[0m"
}
print_warning() {
    echo -e "\e[33m$1\e[0m"
}
print_error() {
    echo -e "\e[31m$1\e[0m"
}

if command -v nautilus &> /dev/null; then
    print_success "Nautilus is already installed."
else
    print_warning "Installing Nautilus and related packages..."
    sudo pacman -Syu --noconfirm nautilus gvfs gvfs-smb gvfs-afc gvfs-google
    print_success "Nautilus installed successfully."
fi

xdg-mime default nautilus.desktop inode/directory application/x-gnome-saved-search

print_success "Nautilus and related utilities configured."
