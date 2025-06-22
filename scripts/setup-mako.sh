#!/bin/bash
set -e

source scripts/utils.sh

setup_mako() {
    print_info "Setting up Mako notification daemon..."
    
    if ! command -v mako &> /dev/null; then
        print_info "Installing mako..."
        if command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm mako
        elif command -v apt &> /dev/null; then
            sudo apt install -y mako
        else
            print_error "Unsupported package manager. Please install mako manually."
            return 1
        fi
    else
        print_success "Mako is already installed"
    fi
    
    mkdir -p "$HOME/.config/mako"
    
    if [ -d "config/mako" ]; then
        cp -r config/mako/* "$HOME/.config/mako/"
        print_success "Mako configuration copied"
    else
        print_error "Mako configuration not found"
        return 1
    fi
    
    mkdir -p "$HOME/.config/systemd/user"
    cat > "$HOME/.config/systemd/user/mako.service" << EOF
[Unit]
Description=Mako notification daemon
Documentation=man:mako(1)
PartOf=graphical-session.target

[Service]
Type=simple
ExecStart=/usr/bin/mako
ExecReload=/usr/bin/makoctl reload

[Install]
WantedBy=graphical-session.target
EOF
    
    systemctl --user daemon-reload
    systemctl --user enable mako.service
    systemctl --user restart mako.service
    
    print_success "✅ Mako setup complete"
}

main() {
    setup_mako
}

main 