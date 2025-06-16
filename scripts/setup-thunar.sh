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

print_warning "Installing Thunar and related packages..."

sudo pacman -Syu --noconfirm thunar thunar-archive-plugin thunar-volman xarchiver


xfconf-query -c thunar -p /last-show-hidden -s true || true
xfconf-query -c thunar -p /default-view -s 1 || true  

xdg-mime default Thunar.desktop inode/directory application/x-gnome-saved-search

print_success "Thunar and related utilities installed and basic configuration done."
