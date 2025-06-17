#!/bin/bash

source scripts/utils.sh

install_package() {
    local pkg=$1
    if pacman -Qi "$pkg" &>/dev/null; then
        print_success "$pkg is already installed"
    else
        print_warning "Installing $pkg..."
        sudo pacman -S --noconfirm "$pkg"
        if pacman -Qi "$pkg" &>/dev/null; then
            print_success "$pkg installed successfully"
        else
            print_error "Failed to install $pkg"
            exit 1
        fi
    fi
}

require_dependency() {
    for dep in "$@"; do
        if ! command -v "$dep" &>/dev/null; then
            print_warning "$dep is missing, installing..."
            install_package "$dep"
        else
            print_success "$dep is already installed"
        fi
    done
}

install_oh_my_posh() {
    if command -v oh-my-posh &>/dev/null; then
        print_success "oh-my-posh already installed"
        return
    fi

    if command -v yay &>/dev/null; then
        print_info "Installing oh-my-posh-bin from AUR via yay..."
        yay -S --noconfirm oh-my-posh-bin
        print_success "oh-my-posh installed"
    else
        print_warning "yay not found, installing oh-my-posh manually..."

        ARCH="amd64"

        LATEST_URL=$(curl -s https://api.github.com/repos/JanDeDobbeleer/oh-my-posh/releases/latest \
            | grep "browser_download_url.*linux-$ARCH" \
            | cut -d : -f 2,3 \
            | tr -d \")

        if [[ -z "$LATEST_URL" ]]; then
            print_error "Failed to find oh-my-posh download URL"
            exit 1
        fi

        wget -O oh-my-posh "$LATEST_URL"
        chmod +x oh-my-posh
        sudo mv oh-my-posh /usr/local/bin/oh-my-posh

        if command -v oh-my-posh &>/dev/null; then
            print_success "oh-my-posh installed successfully"
        else
            print_error "oh-my-posh installation failed"
            exit 1
        fi
    fi
}

clone_plugin() {
    local repo_url=$1
    local target_dir=$2
    if [[ ! -d "$target_dir" ]]; then
        print_warning "Cloning plugin from $repo_url..."
        git clone "$repo_url" "$target_dir"
        print_success "Cloned to $target_dir"
    else
        print_success "Plugin already present at $target_dir"
    fi
}

setup_plugins() {
    local zsh_custom="$HOME/.zsh"

    clone_plugin https://github.com/zsh-users/zsh-syntax-highlighting.git "$zsh_custom/zsh-syntax-highlighting"
    clone_plugin https://github.com/zsh-users/zsh-autosuggestions.git "$zsh_custom/zsh-autosuggestions"
    clone_plugin https://github.com/rupa/z.git "$zsh_custom/z"
}

setup_theme() {
    local theme_dir="$HOME/.poshthemes"
    mkdir -p "$theme_dir"

    print_info "Downloading hunk theme..."
    oh-my-posh get themes/hunk > "$theme_dir/hunk.json"

    local pastel_theme="$theme_dir/hunk-pastel.json"
    print_info "Applying pastel color palette..."

    sed -e 's/#4e88eb/#a8dadc/g' \
        -e 's/#e36262/#f4a261/g' \
        -e 's/#d6d6d6/#f1faee/g' \
        -e 's/#b8bb26/#cdb4db/g' \
        -e 's/#ebdbb2/#ffe5d9/g' \
        "$theme_dir/hunk.json" > "$pastel_theme"

    echo "$pastel_theme"
}

write_zshrc() {
    local pastel_theme_path=$1

    if [[ -f "$HOME/.zshrc" ]]; then
        print_warning "Backing up existing .zshrc to .zshrc.bak"
        cp "$HOME/.zshrc" "$HOME/.zshrc.bak"
    fi

    cat > "$HOME/.zshrc" <<EOF


ZSH_CUSTOM="\$HOME/.zsh"

source \$ZSH_CUSTOM/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

source \$ZSH_CUSTOM/zsh-autosuggestions/zsh-autosuggestions.zsh

source \$ZSH_CUSTOM/z/z.sh

eval "\$(oh-my-posh init zsh --config $pastel_theme_path)"

autoload -U compinit && compinit
setopt prompt_subst

bindkey '^R' history-incremental-search-backward
zstyle ':completion:*' menu select
bindkey -v

export EDITOR=nano
EOF

    print_success ".zshrc configured successfully"
}

main() {
    print_ascii_art
    print_info "Starting zsh + oh-my-posh setup..."

    require_dependency git curl sed wget

    install_package zsh
    install_oh_my_posh
    setup_plugins
    pastel_theme_path=$(setup_theme)
    write_zshrc "$pastel_theme_path"

    print_info "Changing your default shell to zsh..."
    if chsh -s "$(which zsh)"; then
        print_success "Default shell changed to zsh. Please log out and log back in."
    else
        print_warning "Could not change the default shell automatically. Please run 'chsh -s $(which zsh)' manually."
    fi

    print_info "Switching current shell session to zsh..."
    exec "$(which zsh)" -l

    print_success "Setup complete! To start using zsh now, run:"
    echo "  source ~/.zshrc"
}

main
