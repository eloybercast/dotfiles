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

setup_browser() {
    print_warning "⚙️ Step 1: Setting up Browser..."
    bash scripts/setup-browser.sh
    print_success "✅ Browser setup complete"
}

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

setup_kitty() {
    print_warning "⚙️ Step 4: Setting up Kitty terminal..."
    bash scripts/setup-kitty.sh
    print_success "✅ Kitty terminal setup complete"
}

setup_nautilus() {
    print_warning "⚙️ Step 5: Setting up Nautilus..."
    bash scripts/setup-nautilus.sh
    print_success "✅ Nautilus setup complete"
}

setup_themes() {
    print_warning "⚙️ Step 6: Setting up Themes..."
    bash scripts/setup-themes.sh
    print_success "✅ Themes setup complete"
}

setup_scripts() {
    print_warning "⚙️ Setting up Scripts..."
    bash scripts/setup-scripts.sh
    print_success "✅ Scripts setup complete"
}

setup_config_files() {
    print_warning "⚙️ Setting up Config Files..."
    bash scripts/setup-config-files.sh
    print_success "✅ Config Files setup complete"
}

setup_all() {
    show_welcome
    setup_browser
    setup_hyprland
    setup_waybar
    setup_zsh
    setup_kitty
    setup_nautilus
    setup_themes
    setup_scripts
    setup_config_files
}

# Interactive mode with menu
interactive_mode() {
    show_welcome
    echo "Select components to install:"
    options=("Browser" "Hyprland" "Waybar" "Zsh" "Kitty" "Nautilus" "Themes" "Scripts" "Config Files" "All" "Quit")
    select opt in "${options[@]}"; do
        case $opt in
            "Browser") setup_browser ;;
            "Hyprland") setup_hyprland ;;
            "Waybar") setup_waybar ;;
            "Zsh") setup_zsh ;;
            "Kitty") setup_kitty ;;
            "Nautilus") setup_nautilus ;;
            "Themes") setup_themes ;;
            "Scripts") setup_scripts ;;
            "Config Files") setup_config_files ;;
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
    echo "  --all         Install all components (Browser, Hyprland, Waybar, Zsh, Kitty, Nautilus, Themes, Scripts)"
    echo "  --browser     Install Browser"
    echo "  --hyprland    Install Hyprland and keybindings"
    echo "  --waybar      Install Waybar with icons and visualizer"
    echo "  --zsh         Install Zsh and terminal emulator"
    echo "  --kitty       Install Kitty terminal with zsh integration"
    echo "  --nautilus    Install Nautilus file manager"
    echo "  --themes      Install wallpapers, music, and themes"
    echo "  --scripts     Install scripts to user config directory"
    echo "  --config-files Install config files to user config directory"
    echo "  --interactive Interactive mode with menu"
    echo "  --help        Show this help message"
}

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --all) setup_all; shift ;;
        --browser) setup_browser; shift ;;
        --hyprland) setup_hyprland; shift ;;
        --waybar) setup_waybar; shift ;;
        --zsh) setup_zsh; shift ;;
        --kitty) setup_kitty; shift ;;
        --nautilus) setup_nautilus; shift ;;
        --themes) setup_themes; shift ;;
        --scripts) setup_scripts; shift ;;
        --config-files) setup_config_files; shift ;;
        --interactive) interactive_mode; shift ;;
        --help) show_help; exit 0 ;;
        *) print_error "Unknown option: $1"; show_help; exit 1 ;;
    esac
done