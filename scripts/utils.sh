#!/bin/bash

print_success() {
    echo -e "\e[32m$1\e[0m" >&2
}

print_error() {
    echo -e "\e[31m$1\e[0m" >&2
}

print_warning() {
    echo -e "\e[33m$1\e[0m" >&2
}

print_info() {
    echo -e "\e[36m$1\e[0m" >&2
}

print_ascii_art() {
    echo -e "\e[34m" >&2
    echo "▗▄▄▄▖▗▖    ▗▄▖▗▖  ▗▖    ▗▄▄▖ ▗▄▄▄▖▗▄▄▖ ▗▖  ▗▖▗▄▄▄▖   ▗▖ ▗▄▖ " >&2
    echo "▐▌   ▐▌   ▐▌ ▐▌▝▚▞▘     ▐▌ ▐▌▐▌   ▐▌ ▐▌▐▛▚▞▜▌▐▌      ▐▌▐▌ ▐▌" >&2
    echo "▐▛▀▀▘▐▌   ▐▌ ▐▌ ▐▌      ▐▛▀▚▖▐▛▀▀▘▐▛▀▚▖▐▌  ▐▌▐▛▀▀▘   ▐▌▐▌ ▐▌" >&2
    echo "▐▙▄▄▖▐▙▄▄▖▝▚▄▞▘ ▐▌      ▐▙▄▞▘▐▙▄▄▖▐▌ ▐▌▐▌  ▐▌▐▙▄▄▖▗▄▄▞▘▝▚▄▞▘" >&2
    echo -e "\e[0m" >&2
}

ask_selection() {
    local prompt="$1"
    shift
    local options=("$@")

    echo -e "\n\e[36m$prompt\e[0m"
    select opt in "${options[@]}"; do
        if [[ -n "$opt" ]]; then
            echo "$opt"
            return 0
        else
            print_error "Invalid option. Please try again."
        fi
    done
}

require_dependency() {
    for dep in "$@"; do
        if ! command -v "$dep" &>/dev/null; then
            print_error "Missing dependency: $dep"
            exit 1
        fi
    done
}

confirm() {
    read -r -p "$(echo -e "\e[33m$1 (y/n): \e[0m")" response
    case "$response" in
        [yY][eE][sS]|[yY]) return 0 ;;
        *) return 1 ;;
    esac
}
