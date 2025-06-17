#!/bin/bash
set -e

source scripts/utils.sh

backup_and_copy() {
    local src_path=$1
    local dest_path=$2

    if [ -e "$dest_path" ]; then
        print_warning "Backing up existing config at $dest_path"
        mv "$dest_path" "${dest_path}.bak-$(date +%F_%T)"
    fi

    mkdir -p "$(dirname "$dest_path")"

    if [ -d "$src_path" ]; then
        cp -r "$src_path" "$dest_path"
    else
        cp "$src_path" "$dest_path"
    fi
    print_success "Copied $src_path to $dest_path"
}

copy_recursive() {
    local base_src_dir=$1
    local base_dest_dir=$2

    shopt -s dotglob nullglob
    for path in "$base_src_dir"/* "$base_src_dir"/.*; do
        local name=$(basename "$path")

        if [[ "$name" == "." || "$name" == ".." || "$name" == "scripts" ]]; then
            continue
        fi

        local rel_path="${path#$base_src_dir/}"
        local dest_path="$base_dest_dir/$rel_path"

        backup_and_copy "$path" "$dest_path"
    done
}

main() {
    local config_dir="config"
    local target_dir="$HOME/.config"

    if [ ! -d "$config_dir" ]; then
        print_error "Config directory '$config_dir' does not exist."
        exit 1
    fi

    copy_recursive "$config_dir" "$target_dir"
}

main
