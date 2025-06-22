#!/bin/bash

toggle_dnd() {
    if makoctl mode | grep -q "do-not-disturb"; then
        makoctl mode -r do-not-disturb
        notify-send "Notifications" "Do Not Disturb mode disabled" -a "System" -i dialog-information
    else
        notify-send "Notifications" "Do Not Disturb mode enabled" -a "System" -i dialog-information
        sleep 2
        makoctl mode -a do-not-disturb
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