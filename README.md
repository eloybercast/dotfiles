# Eloy's Arch Linux Dotfiles

A modern, elegant, and functional Hyprland configuration for Arch Linux.

![Hyprland Desktop](assets/wallpapers/wallhaven-ymz61d_2560x1440.png)

## Overview

This repository contains my personal dotfiles for Arch Linux with Hyprland. The setup includes:

- **Hyprland**: A dynamic tiling Wayland compositor
- **Waybar**: Highly customizable status bar
- **Mako**: Lightweight notification daemon
- **Kitty**: Fast, feature-rich terminal emulator
- **Wofi**: Application launcher and menu
- **Zsh**: Shell with Oh My Posh for beautiful prompts

## Features

- Clean, modern design with consistent styling across all components
- Notification system with Do Not Disturb toggle
- Custom keybindings for efficient workflow
- Beautiful wallpapers and color schemes
- Optimized for productivity

## Installation

### Quick Install

Run the setup script to install all components:

```bash
git clone https://github.com/eloybercast/dotfiles.git
cd dotfiles
./setup.sh --all
```

### Selective Installation

You can also install specific components:

```bash
./setup.sh --interactive  # Interactive menu
# Or install specific components
./setup.sh --hyprland --waybar --mako
```

### Available Components

- `--browser`: Firefox with system theme integration
- `--hyprland`: Hyprland window manager and keybindings
- `--waybar`: Status bar with custom modules
- `--wofi`: Application launcher and menus
- `--zsh`: Zsh shell with Oh My Posh
- `--kitty`: Terminal with custom configuration
- `--nautilus`: File manager
- `--themes`: System themes and wallpapers
- `--scripts`: Utility scripts
- `--mako`: Notification daemon
- `--config-files`: All configuration files

## Keybindings

| Keybinding          | Action                     |
| ------------------- | -------------------------- |
| Super + Return      | Open terminal              |
| Super + Q           | Close active window        |
| Super + D           | Open application launcher  |
| Super + P           | Open power menu            |
| Super + 1-5         | Switch to workspace        |
| Super + Shift + 1-5 | Move window to workspace   |
| Super + N           | Dismiss all notifications  |
| Super + Shift + N   | Toggle Do Not Disturb mode |

## Customization

Configuration files are organized by component in the `config/` directory:

- `config/hypr/`: Hyprland configuration
- `config/waybar/`: Waybar status bar
- `config/mako/`: Notification settings
- `config/kitty/`: Terminal configuration
- `config/wofi/`: Application launcher
- `config/scripts/`: Utility scripts

## Credits

- Wallpapers from [Wallhaven](https://wallhaven.cc/) by [lucasdt](https://wallhaven.cc/user/lucasdt) and [GreenFox](https://wallhaven.cc/user/GreenFox)

## License

MIT License
