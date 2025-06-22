#!/bin/bash

toggle_dnd() {
    if makoctl mode | grep -q "do-not-disturb"; then
        makoctl mode -r do-not-disturb
        notify-send "DND OFF" -a "System" -i dialog-information -t 500
    else
        makoctl mode -a do-not-disturb
        notify-send "DND ON" -a "System" -i dialog-information -t 500
    fi
}

dismiss_all() {
    makoctl dismiss -a
}

show_history() {
    makoctl list | jq -r '.data | sort_by(.time.tv_sec) | .[] | "\(.summary): \(.body)"' | wofi --dmenu --prompt "Notification History" --width 500 --height 400
}

main() {
    case "$1" in
        toggle-dnd)
            toggle_dnd
            ;;
        dismiss-all)
            dismiss_all
            ;;
        history)
            show_history
            ;;
        *)
            echo "Usage: $0 {toggle-dnd|dismiss-all|history}"
            exit 1
            ;;
    esac
}

main "$@" 