#!/bin/bash

source scripts/utils.sh

setup_sddm_theme() {
    print_warning "Setting up SDDM Sugar Dark Theme..."
    
    local temp_dir=$(mktemp -d)
    
    print_info "Downloading SDDM Sugar Dark Theme..."
    git clone https://github.com/MarianArlt/sddm-sugar-dark.git "$temp_dir"
    
    if [ ! -d "$temp_dir" ]; then
        print_error "Failed to download SDDM Sugar Dark theme"
        rm -rf "$temp_dir"
        exit 1
    fi
    
    local sddm_themes_dir="/usr/share/sddm/themes"
    if [ ! -d "$sddm_themes_dir" ]; then
        print_info "Creating SDDM themes directory..."
        sudo mkdir -p "$sddm_themes_dir"
    fi
    
    if [ -d "$sddm_themes_dir/sugar-dark" ]; then
        print_info "SDDM Sugar Dark theme is already installed. Removing old version..."
        sudo rm -rf "$sddm_themes_dir/sugar-dark"
    fi
    
    print_info "Installing theme to $sddm_themes_dir/sugar-dark..."
    sudo mkdir -p "$sddm_themes_dir/sugar-dark"
    sudo cp -r "$temp_dir"/* "$sddm_themes_dir/sugar-dark/"
    
    print_info "Setting custom wallpaper (Room1.png)..."
    if [ -f "assets/wallpapers/Room1.png" ]; then
        sudo cp "assets/wallpapers/Room1.png" "$sddm_themes_dir/sugar-dark/Background.jpg"
        print_success "Custom wallpaper set successfully"
    else
        print_warning "Custom wallpaper not found at assets/wallpapers/Room1.png, using default"
    fi
    
    print_info "Updating theme configuration..."
    if [ -f "$sddm_themes_dir/sugar-dark/theme.conf" ]; then
        if grep -q "^ScreenWidth=" "$sddm_themes_dir/sugar-dark/theme.conf"; then
            sudo sed -i 's|^ScreenWidth=.*|ScreenWidth=1920|g' "$sddm_themes_dir/sugar-dark/theme.conf"
        else
            echo "ScreenWidth=1920" | sudo tee -a "$sddm_themes_dir/sugar-dark/theme.conf" > /dev/null
        fi
        
        if grep -q "^ScreenHeight=" "$sddm_themes_dir/sugar-dark/theme.conf"; then
            sudo sed -i 's|^ScreenHeight=.*|ScreenHeight=1080|g' "$sddm_themes_dir/sugar-dark/theme.conf"
        else
            echo "ScreenHeight=1080" | sudo tee -a "$sddm_themes_dir/sugar-dark/theme.conf" > /dev/null
        fi
        
        if grep -q "^BackgroundMode=" "$sddm_themes_dir/sugar-dark/theme.conf"; then
            sudo sed -i 's|^BackgroundMode=.*|BackgroundMode=fill|g' "$sddm_themes_dir/sugar-dark/theme.conf"
        else
            echo "BackgroundMode=fill" | sudo tee -a "$sddm_themes_dir/sugar-dark/theme.conf" > /dev/null
        fi
    else
        print_warning "Theme configuration file not found, wallpaper may not be applied correctly"
    fi
    
    local sddm_conf_dir="/etc/sddm.conf.d"
    if [ ! -d "$sddm_conf_dir" ]; then
        print_info "Creating SDDM configuration directory..."
        sudo mkdir -p "$sddm_conf_dir"
    fi
    
    local sddm_conf="$sddm_conf_dir/10-theme.conf"
    print_info "Updating SDDM configuration at $sddm_conf..."
    
    echo "[Theme]
Current=sugar-dark" | sudo tee "$sddm_conf" > /dev/null
    
    if [ -f "/etc/sddm.conf" ]; then
        print_info "Checking main SDDM configuration..."
        if grep -q "\[Theme\]" "/etc/sddm.conf"; then
            if grep -q "^Current=" "/etc/sddm.conf"; then
                print_warning "Updating theme in /etc/sddm.conf..."
                sudo sed -i 's|^Current=.*|Current=sugar-dark|g' "/etc/sddm.conf"
            else
                print_warning "Adding theme to existing Theme section in /etc/sddm.conf..."
                sudo sed -i '/\[Theme\]/a Current=sugar-dark' "/etc/sddm.conf"
            fi
        else
            print_warning "Adding Theme section to /etc/sddm.conf..."
            echo -e "\n[Theme]\nCurrent=sugar-dark" | sudo tee -a "/etc/sddm.conf" > /dev/null
        fi
    else
        print_info "Creating /etc/sddm.conf..."
        echo -e "[Theme]\nCurrent=sugar-dark" | sudo tee "/etc/sddm.conf" > /dev/null
    fi
    
    if ! command -v sddm &>/dev/null; then
        print_warning "SDDM is not installed. Installing SDDM..."
        sudo pacman -S --noconfirm sddm
        
        print_info "Enabling SDDM service..."
        sudo systemctl enable sddm
    fi
    
    local dependencies=("qt5-quickcontrols2" "qt5-graphicaleffects" "qt5-svg")
    for dep in "${dependencies[@]}"; do
        if ! pacman -Qi "$dep" &>/dev/null; then
            print_warning "Installing dependency: $dep..."
            sudo pacman -S --noconfirm "$dep"
        fi
    done
    
    rm -rf "$temp_dir"
    
    print_success "SDDM Sugar Dark Theme has been installed successfully!"
    print_info "Your login screen will use the Sugar Dark theme with the Room1.png wallpaper on next boot."
    print_info "Note: If you're using both GRUB and SDDM themes, they are configured separately and won't conflict."
}

setup_sddm_theme 