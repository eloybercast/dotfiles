#!/bin/bash

source scripts/utils.sh

# Display welcome message and step-by-step guidance
show_welcome() {
    print_ascii_art
    echo -e "\e[34m🎉 Welcome to Eloy Bermejo's Arch Hyprland Dotfiles Setup! 🎉\e[0m"
    echo -e "\e[33mPress any key to start the setup (or Ctrl+C to cancel)...\e[0m"
    read -n 1 -s
    echo
}

# Component setup functions
setup_hyprland() {
    print_warning "⚙️ Step 1: Setting up Hyprland..."
    bash scripts/setup-hyprland.sh
    print_success "✅ Hyprland setup complete"
}

setup_waybar() {
    print_warning "⚙️ Step 2: Setting up Waybar..."
    bash scripts/setup-waybar.sh
    print_success "✅ Waybar setup complete"
}

setup_zsh() {
    print_warning "⚙️ Step 3: Setting up Zsh..."
    bash scripts/setup-zsh.sh
    print_success "✅ Zsh setup complete"
}

setup_nautilus() {
    print_warning "⚙️ Step 4: Setting up Nautilus..."
    bash scripts/setup-nautilus.sh
    print_success "✅ Nautilus setup complete"
}


setup_apps() {
    print_warning "⚙️ Step 5: Setting up Apps..."
    bash scripts/setup-apps.sh
    print_success "✅ Apps setup complete"
}

setup_themes() {
    print_warning "⚙️ Step 6: Setting up Themes..."
    bash scripts/setup-themes.sh
    print_success "✅ Themes setup complete"
}

setup_all() {
    show_welcome
    setup_hyprland
    setup_waybar
    setup_zsh
    setup_nautilus
    setup_apps
    setup_themes
}

# Interactive mode with menu
interactive_mode() {
    show_welcome
    echo "Select components to install:"
    options=("Hyprland" "Waybar" "Zsh" "Nautilus" "Apps" "Themes" "All" "Quit")
    select opt in "${options[@]}"; do
        case $opt in
            "Hyprland") setup_hyprland ;;
            "Waybar") setup_waybar ;;
            "Zsh") setup_zsh ;;
            "Nautilus") setup_nautilus ;;
            "Apps") setup_apps ;;
            "Themes") setup_themes ;;
            "All") setup_all; break ;;
            "Quit") break ;;
            *) echo "Invalid option" ;;
        esac
    done
}

# Help message
show_help() {
    print_ascii_art
    echo -e "\e[34mEloy Bermejo's Arch Hyprland Dotfiles Setup\e[0m"
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  --all         Install all components (Hyprland, Waybar, Zsh, Nautilus, Apps, Themes)"
    echo "  --hyprland    Install Hyprland and keybindings"
    echo "  --waybar      Install Waybar with icons and visualizer"
    echo "  --zsh         Install Zsh and terminal emulator"
    echo "  --nautilus    Install Nautilus file manager"
    echo "  --apps        Install browser, editor, and dev tools"
    echo "  --themes      Install wallpapers, music, and themes"
    echo "  --interactive Interactive mode with menu"
    echo "  --help        Show this help message"
}

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --all) setup_all; shift ;;
        --hyprland) setup_hyprland; shift ;;
        --waybar) setup_waybar; shift ;;
        --zsh) setup_zsh; shift ;;
        --nautilus) setup_nautilus; shift ;;
        --apps) setup_apps; shift ;;
        --themes) setup_themes; shift ;;
        --interactive) interactive_mode; shift ;;
        --help) show_help; exit 0 ;;
        *) print_error "Unknown option: $1"; show_help; exit 1 ;;
    esac
done