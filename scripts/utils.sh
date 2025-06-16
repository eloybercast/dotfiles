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

spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

print_ascii_art() {
    echo -e "\e[34m"
    echo "▗▄▄▄▖▗▖    ▗▄▖▗▖  ▗▖    ▗▄▄▖ ▗▄▄▄▖▗▄▄▖ ▗▖  ▗▖▗▄▄▄▖   ▗▖ ▗▄▖ "
    echo "▐▌   ▐▌   ▐▌ ▐▌▝▚▞▘     ▐▌ ▐▌▐▌   ▐▌ ▐▌▐▛▚▞▜▌▐▌      ▐▌▐▌ ▐▌"
    echo "▐▛▀▀▘▐▌   ▐▌ ▐▌ ▐▌      ▐▛▀▚▖▐▛▀▀▘▐▛▀▚▖▐▌  ▐▌▐▛▀▀▘   ▐▌▐▌ ▐▌"
    echo "▐▙▄▄▖▐▙▄▄▖▝▚▄▞▘ ▐▌      ▐▙▄▞▘▐▙▄▄▖▐▌ ▐▌▐▌  ▐▌▐▙▄▄▖▗▄▄▞▘▝▚▄▞▘"
    echo -e "\e[0m"
}