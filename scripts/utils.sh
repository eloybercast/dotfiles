#!/bin/bash

print_success() {
    echo -e "\e[32m$1\e[0m"
}

print_error() {
    echo -e "\e[31m$1\e[0m"
}

print_warning() {
    echo -e "\e[33m$1\e[0m"
}

print_info() {
    echo -e "\e[36m$1\e[0m"
}

print_ascii_art() {
    echo -e "\e[34m"
    echo "▗▄▄▄▖▗▖    ▗▄▖▗▖  ▗▖    ▗▄▄▖ ▗▄▄▄▖▗▄▄▖ ▗▖  ▗▖▗▄▄▄▖   ▗▖ ▗▄▖ "
    echo "▐▌   ▐▌   ▐▌ ▐▌▝▚▞▘     ▐▌ ▐▌▐▌   ▐▌ ▐▌▐▛▚▞▜▌▐▌      ▐▌▐▌ ▐▌"
    echo "▐▛▀▀▘▐▌   ▐▌ ▐▌ ▐▌      ▐▛▀▚▖▐▛▀▀▘▐▛▀▚▖▐▌  ▐▌▐▛▀▀▘   ▐▌▐▌ ▐▌"
    echo "▐▙▄▄▖▐▙▄▄▖▝▚▄▞▘ ▐▌      ▐▙▄▞▘▐▙▄▄▖▐▌ ▐▌▐▌  ▐▌▐▙▄▄▖▗▄▄▞▘▝▚▄▞▘"
    echo -e "\e[0m"
}