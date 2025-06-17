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
    print_info "Installing Oh My Posh..."
    
    mkdir -p "$HOME/.local/bin"
    
    local ARCH="amd64"
    if [[ $(uname -m) == "aarch64" ]]; then
        ARCH="arm64"
    fi
    
    print_info "Downloading oh-my-posh for Linux $ARCH..."
    local DOWNLOAD_URL="https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-$ARCH"
    
    curl -sL "$DOWNLOAD_URL" -o "$HOME/.local/bin/oh-my-posh"
    chmod +x "$HOME/.local/bin/oh-my-posh"
    
    if ! grep -q "PATH=\"\$HOME/.local/bin:\$PATH\"" "$HOME/.zshrc" 2>/dev/null; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.zshrc"
    fi
    
    if [ -x "$HOME/.local/bin/oh-my-posh" ]; then
        print_success "oh-my-posh installed successfully"
    else
        print_error "oh-my-posh installation failed"
        exit 1
    fi
}

clone_plugin() {
    local repo_url=$1
    local target_dir=$2
    if [[ ! -d "$target_dir" ]]; then
        print_warning "Cloning plugin from $repo_url..."
        git clone --depth=1 "$repo_url" "$target_dir"
        print_success "Cloned to $target_dir"
    else
        print_success "Plugin already present at $target_dir"
    fi
}

setup_plugins() {
    local zsh_custom="$HOME/.zsh"
    mkdir -p "$zsh_custom"

    clone_plugin https://github.com/zsh-users/zsh-syntax-highlighting.git "$zsh_custom/zsh-syntax-highlighting"
    clone_plugin https://github.com/zsh-users/zsh-autosuggestions.git "$zsh_custom/zsh-autosuggestions"
    clone_plugin https://github.com/rupa/z.git "$zsh_custom/z"
}

setup_theme() {
    local theme_dir="$HOME/.poshthemes"
    mkdir -p "$theme_dir"

    print_info "Creating custom theme..."
    
    cat > "$theme_dir/eloy-theme.json" <<EOF
{
  "$schema": "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/schema.json",
  "blocks": [
    {
      "alignment": "left",
      "segments": [
        {
          "background": "#2a9d8f",
          "foreground": "#000000",
          "leading_diamond": "\ue0b6",
          "style": "diamond",
          "template": " {{ .UserName }}@{{ .HostName }} ",
          "trailing_diamond": "\ue0b0",
          "type": "session"
        },
        {
          "background": "#a8dadc",
          "foreground": "#000000",
          "powerline_symbol": "\ue0b0",
          "properties": {
            "style": "full"
          },
          "style": "powerline",
          "template": " {{ .Path }} ",
          "type": "path"
        },
        {
          "background": "#cdb4db",
          "background_templates": [
            "{{ if or (.Working.Changed) (.Staging.Changed) }}#f4a261{{ end }}",
            "{{ if and (gt .Ahead 0) (gt .Behind 0) }}#e63946{{ end }}",
            "{{ if gt .Ahead 0 }}#2a9d8f{{ end }}",
            "{{ if gt .Behind 0 }}#e9c46a{{ end }}"
          ],
          "foreground": "#000000",
          "powerline_symbol": "\ue0b0",
          "properties": {
            "branch_icon": "\ue725 ",
            "fetch_stash_count": true,
            "fetch_status": true,
            "fetch_upstream_icon": true
          },
          "style": "powerline",
          "template": " {{ .HEAD }}{{ if .BranchStatus }} {{ .BranchStatus }}{{ end }}{{ if .Working.Changed }} \uf044 {{ .Working.String }}{{ end }}{{ if and (.Working.Changed) (.Staging.Changed) }} |{{ end }}{{ if .Staging.Changed }} \uf046 {{ .Staging.String }}{{ end }} ",
          "type": "git"
        }
      ],
      "type": "prompt"
    },
    {
      "alignment": "right",
      "segments": [
        {
          "background": "#f1faee",
          "foreground": "#000000",
          "leading_diamond": "\ue0b2",
          "style": "diamond",
          "template": " {{ .CurrentDate | date .Format }} ",
          "trailing_diamond": "\ue0b4",
          "type": "time"
        }
      ],
      "type": "prompt"
    },
    {
      "alignment": "left",
      "newline": true,
      "segments": [
        {
          "foreground": "#e63946",
          "foreground_templates": [
            "{{ if gt .Code 0 }}#e63946{{ else }}#2a9d8f{{ end }}"
          ],
          "properties": {
            "always_enabled": true
          },
          "style": "plain",
          "template": "\u276f ",
          "type": "exit"
        }
      ],
      "type": "prompt"
    }
  ],
  "final_space": true,
  "version": 2
}
EOF

    echo "$theme_dir/eloy-theme.json"
}

write_zshrc() {
    local theme_path=$1

    if [[ -f "$HOME/.zshrc" ]]; then
        print_warning "Backing up existing .zshrc to .zshrc.bak"
        cp "$HOME/.zshrc" "$HOME/.zshrc.bak"
    fi

    cat > "$HOME/.zshrc" <<EOF
# ZSH Configuration for Eloy Bermejo's dotfiles

# Add local bin to PATH
export PATH="\$HOME/.local/bin:\$PATH"

# Set ZSH custom directory
ZSH_CUSTOM="\$HOME/.zsh"

# Load plugins
[ -f "\$ZSH_CUSTOM/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ] && source "\$ZSH_CUSTOM/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
[ -f "\$ZSH_CUSTOM/zsh-autosuggestions/zsh-autosuggestions.zsh" ] && source "\$ZSH_CUSTOM/zsh-autosuggestions/zsh-autosuggestions.zsh"
[ -f "\$ZSH_CUSTOM/z/z.sh" ] && source "\$ZSH_CUSTOM/z/z.sh"

# Initialize oh-my-posh with theme
if [ -x "\$HOME/.local/bin/oh-my-posh" ]; then
    eval "\$(\$HOME/.local/bin/oh-my-posh init zsh --config $theme_path)"
else
    echo "Warning: oh-my-posh not found in \$HOME/.local/bin"
fi

# Completion system
autoload -U compinit && compinit
setopt prompt_subst

# Key bindings
bindkey '^R' history-incremental-search-backward
zstyle ':completion:*' menu select
bindkey -v

# Environment variables
export EDITOR=nano

# Aliases
alias ls='ls --color=auto'
alias ll='ls -la'
alias la='ls -a'
alias grep='grep --color=auto'
EOF

    print_success ".zshrc configured successfully"
}

install_nerd_fonts() {
    print_info "Installing Nerd Fonts for proper symbol rendering..."
    
    tmp_dir=$(mktemp -d)
    cd "$tmp_dir"
    
    wget -q "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/FiraCode.zip"
    unzip -q FiraCode.zip -d firacode
    
    mkdir -p ~/.local/share/fonts
    
    cp -f firacode/*.ttf ~/.local/share/fonts/
    
    fc-cache -f
    
    cd - > /dev/null
    rm -rf "$tmp_dir"
    
    print_success "✅ Nerd Fonts installed for proper symbol rendering."
}

main() {
    print_ascii_art
    print_info "Starting zsh + oh-my-posh setup..."

    require_dependency git curl sed wget

    install_package zsh
    install_oh_my_posh
    setup_plugins
    theme_path=$(setup_theme)
    write_zshrc "$theme_path"
    install_nerd_fonts

    print_info "Changing your default shell to zsh..."
    if chsh -s "$(which zsh)"; then
        print_success "Default shell changed to zsh."
    else
        print_warning "Could not change the default shell automatically. Please run 'chsh -s $(which zsh)' manually."
    fi

    print_success "✅ Zsh setup complete! You will need to log out and log back in for the shell change to take effect."
    print_info "Alternatively, you can start using zsh now by running: zsh"
}

main
