#!/bin/bash

source scripts/utils.sh

show_welcome() {
    print_ascii_art
    echo -e "\e[34m🎉 Welcome to Eloy Bermejo's Arch Hyprland Dotfiles Setup! 🎉\e[0m"
    echo -e "\e[33mPress any key to start the setup (or Ctrl+C to cancel)...\e[0m"
    read -n 1 -s
    echo
}

setup_browser() {
    print_warning "⚙️ Setting up Browser..."
    bash scripts/setup-browser.sh
    print_success "✅ Browser setup complete"
}

setup_hyprland() {
    print_warning "⚙️ Setting up Hyprland..."
    bash scripts/setup-hyprland.sh
    print_success "✅ Hyprland setup complete"
}

setup_waybar() {
    print_warning "⚙️ Setting up Waybar..."
    bash scripts/setup-waybar.sh
    print_success "✅ Waybar setup complete"
}

setup_wofi() {
    print_warning "⚙️ Setting up Wofi..."
    bash scripts/setup-wofi.sh
    print_success "✅ Wofi setup complete"
}

setup_zsh() {
    print_warning "⚙️ Setting up Zsh and Oh My Posh..."
    bash scripts/setup-zsh.sh
    print_success "✅ Zsh and Oh My Posh setup complete"
}

setup_kitty() {
    print_warning "⚙️ Setting up Kitty terminal..."
    bash scripts/setup-kitty.sh
    print_success "✅ Kitty terminal setup complete"
}

setup_nautilus() {
    print_warning "⚙️ Setting up Nautilus..."
    bash scripts/setup-nautilus.sh
    print_success "✅ Nautilus setup complete"
}

setup_themes() {
    print_warning "⚙️ Setting up Themes..."
    bash scripts/setup-themes.sh
    print_success "✅ Themes setup complete"
}

setup_wallpapers() {
    print_warning "⚙️ Setting up Wallpapers..."
    bash scripts/setup-wallpapers.sh
    print_success "✅ Wallpapers setup complete"
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

setup_mako() {
    print_warning "⚙️ Setting up Mako notifications..."
    bash scripts/setup-mako.sh
    print_success "✅ Mako notifications setup complete"
}

setup_all() {
    show_welcome
    
    setup_zsh
    setup_browser
    
    setup_hyprland
    
    setup_kitty
    setup_themes
    setup_nautilus
    setup_scripts
    setup_mako
    
    setup_waybar
    setup_wofi
    
    setup_wallpapers
    
    setup_config_files
    
    print_success "✅✅✅ All components installed successfully! ✅✅✅"
    print_info "Please log out and log back in to start using your new environment."
    print_info "Or run 'exec zsh' to start using zsh in the current session."
}

interactive_mode() {
    show_welcome
    echo "Select components to install:"
    options=("Browser" "Hyprland" "Waybar" "Wofi" "Zsh" "Kitty" "Nautilus" "Themes" "Wallpapers" "Scripts" "Mako" "Config Files" "All" "Quit")
    select opt in "${options[@]}"; do
        case $opt in
            "Browser") setup_browser ;;
            "Hyprland") setup_hyprland ;;
            "Waybar") setup_waybar ;;
            "Wofi") setup_wofi ;;
            "Zsh") setup_zsh ;;
            "Kitty") setup_kitty ;;
            "Nautilus") setup_nautilus ;;
            "Themes") setup_themes ;;
            "Wallpapers") setup_wallpapers ;;
            "Scripts") setup_scripts ;;
            "Mako") setup_mako ;;
            "Config Files") setup_config_files ;;
            "All") setup_all; break ;;
            "Quit") break ;;
            *) echo "Invalid option" ;;
        esac
    done
}

show_help() {
    print_ascii_art
    echo -e "\e[34mEloy Bermejo's Arch Hyprland Dotfiles Setup\e[0m"
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  --all         Install all components (Browser, Hyprland, Waybar, Wofi, Zsh, Kitty, Nautilus, Themes, Wallpapers, Scripts, Mako)"
    echo "  --browser     Install Browser"
    echo "  --hyprland    Install Hyprland and keybindings"
    echo "  --waybar      Install Waybar with icons and visualizer"
    echo "  --wofi        Install Wofi app launcher and power menu"
    echo "  --zsh         Install Zsh and terminal emulator"
    echo "  --kitty       Install Kitty terminal with zsh integration"
    echo "  --nautilus    Install Nautilus file manager"
    echo "  --themes      Install wallpapers, music, and themes"
    echo "  --wallpapers  Install wallpapers"
    echo "  --scripts     Install scripts to user config directory"
    echo "  --mako        Install Mako notification daemon"
    echo "  --config-files Install config files to user config directory"
    echo "  --interactive Interactive mode with menu"
    echo "  --help        Show this help message"
}

while [[ $# -gt 0 ]]; do
    case $1 in
        --all) setup_all; shift ;;
        --browser) setup_browser; shift ;;
        --hyprland) setup_hyprland; shift ;;
        --waybar) setup_waybar; shift ;;
        --wofi) setup_wofi; shift ;;
        --zsh) setup_zsh; shift ;;
        --kitty) setup_kitty; shift ;;
        --nautilus) setup_nautilus; shift ;;
        --themes) setup_themes; shift ;;
        --wallpapers) setup_wallpapers; shift ;;
        --scripts) setup_scripts; shift ;;
        --mako) setup_mako; shift ;;
        --config-files) setup_config_files; shift ;;
        --interactive) interactive_mode; shift ;;
        --help) show_help; exit 0 ;;
        *) print_error "Unknown option: $1"; show_help; exit 1 ;;
    esac
done
