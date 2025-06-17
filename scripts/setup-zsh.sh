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

install_oh_my_posh() {
    if ! command -v oh-my-posh &>/dev/null; then
        print_warning "Installing oh-my-posh..."
        install_package oh-my-posh
    else
        print_success "oh-my-posh already installed"
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
    print_info "Applying pastel color palette using sed..."
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
# Custom zsh config with oh-my-posh and plugins

ZSH_CUSTOM="\$HOME/.zsh"

# Syntax highlighting
source \$ZSH_CUSTOM/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Autosuggestions
source \$ZSH_CUSTOM/zsh-autosuggestions/zsh-autosuggestions.zsh

# z jumping
source \$ZSH_CUSTOM/z/z.sh

# oh-my-posh prompt
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

    require_dependency git curl sed

    install_package zsh
    install_oh_my_posh
    setup_plugins
    pastel_theme_path=$(setup_theme)
    write_zshrc "$pastel_theme_path"

    print_success "Setup complete! You can change your shell to zsh with:"
    echo "  chsh -s \$(which zsh)"
    echo "Then restart your terminal or run:"
    echo "  source ~/.zshrc"
}

main
