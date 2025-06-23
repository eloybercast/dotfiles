#!/bin/bash
set -e

source scripts/utils.sh

print_info "📦 Setting up kitty terminal..."

if ! command -v kitty &>/dev/null; then
    print_info "Installing kitty terminal..."
    sudo pacman -S --needed --noconfirm kitty
    print_success "✅ kitty installed."
else
    print_info "kitty is already installed, skipping installation."
fi

mkdir -p ~/.config/kitty

print_info "Creating kitty launch wrapper..."

mkdir -p ~/.local/bin

cat > ~/.local/bin/kitty-launch <<EOF
#!/bin/bash
export PATH="\$HOME/.local/bin:\$PATH"
exec kitty "\$@"
EOF

chmod +x ~/.local/bin/kitty-launch

print_info "Ensuring ~/.local/bin is in PATH..."

if ! grep -q 'PATH="$HOME/.local/bin:$PATH"' ~/.profile 2>/dev/null && \
   ! grep -q 'PATH="$HOME/.local/bin:$PATH"' ~/.zprofile 2>/dev/null && \
   ! grep -q 'PATH="$HOME/.local/bin:$PATH"' ~/.bash_profile 2>/dev/null; then
    
    PROFILE_FILE=~/.profile
    if [ -f ~/.zprofile ]; then
        PROFILE_FILE=~/.zprofile
    elif [ -f ~/.bash_profile ]; then
        PROFILE_FILE=~/.bash_profile
    fi
    
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$PROFILE_FILE"
    print_info "Added ~/.local/bin to PATH in $PROFILE_FILE"
fi

mkdir -p ~/.config/hypr
if [ ! -f ~/.config/hypr/env.conf ] || ! grep -q '.local/bin' ~/.config/hypr/env.conf; then
    echo 'env = PATH,$HOME/.local/bin:$PATH' >> ~/.config/hypr/env.conf
    print_info "Added ~/.local/bin to Hyprland environment"
fi

if [ ! -f /usr/local/bin/kitty-launch ]; then
    print_info "Creating symlink to kitty-launch in /usr/local/bin..."
    sudo ln -sf ~/.local/bin/kitty-launch /usr/local/bin/kitty-launch
fi

if [ -f "config/hypr/keybinds.conf" ]; then
    print_info "Updating Hyprland keybinds to use kitty-launch..."
    sed -i 's/\$terminal = kitty/\$terminal = kitty-launch/g' config/hypr/keybinds.conf
fi

print_info "Checking for FiraCode Nerd Font..."
if ! fc-list | grep -i "FiraCode Nerd Font" &>/dev/null; then
    print_info "Installing FiraCode Nerd Font..."
    
    mkdir -p ~/.local/share/fonts
    
    print_info "Downloading Nerd Font files..."
    
    curl -sL "https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/FiraCode/Regular/complete/Fira%20Code%20Regular%20Nerd%20Font%20Complete%20Mono.ttf" -o ~/.local/share/fonts/FiraCodeNerdFontMono-Regular.ttf
    curl -sL "https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/FiraCode/Bold/complete/Fira%20Code%20Bold%20Nerd%20Font%20Complete%20Mono.ttf" -o ~/.local/share/fonts/FiraCodeNerdFontMono-Bold.ttf
    
    print_info "Updating font cache..."
    fc-cache -f
    
    print_success "✅ FiraCode Nerd Font installed."
else
    print_info "FiraCode Nerd Font is already installed."
fi

print_success "✅ kitty terminal setup complete." 
print_info "Please restart your Hyprland session or run 'source ~/.profile' to ensure kitty-launch is in your PATH." 
