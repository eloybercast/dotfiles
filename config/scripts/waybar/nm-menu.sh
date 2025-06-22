#!/bin/bash


connect_wifi() {
    local ssid="$1"
    local password

    if nmcli -t -f NAME connection show | grep -q "^$ssid$"; then
        nmcli connection up "$ssid" > /dev/null 2>&1
        notify-send "WiFi" "Connected to $ssid"
        return
    fi

    password=$(wofi --dmenu --prompt "Enter password for $ssid" --password --lines 1)
    
    if [[ -n "$password" ]]; then
        if nmcli device wifi connect "$ssid" password "$password"; then
            notify-send "WiFi" "Connected to $ssid"
        else
            notify-send "WiFi" "Failed to connect to $ssid" --urgency=critical
        fi
    fi
}

toggle_wifi() {
    current_state=$(nmcli radio wifi)
    
    if [[ "$current_state" == "enabled" ]]; then
        nmcli radio wifi off
        notify-send "WiFi" "WiFi disabled"
    else
        nmcli radio wifi on
        notify-send "WiFi" "WiFi enabled"
    fi
}

refresh_networks() {
    nmcli device wifi rescan
    notify-send "WiFi" "Rescanned for networks"
}

get_available_networks() {
    echo "$(nmcli -g IN-USE,SIGNAL,SECURITY,SSID device wifi list | sort -nr -k2 -t: | sed 's/^://')"
}

ethernet_connected() {
    nmcli -t -f DEVICE,STATE device | grep -q "^eth.*:connected$"
}

create_menu() {
    local menu=""
    local wifi_state=$(nmcli radio wifi)
    
    if [[ "$wifi_state" == "enabled" ]]; then
        menu+="󰤨 Turn WiFi off\n"
    else
        menu+="󰤭 Turn WiFi on\n"
    fi
    
    menu+="󰑓 Refresh networks\n"
    
    if ethernet_connected; then
        menu+="󰈀 Ethernet connected\n"
    fi
    
    menu+="──────────────────\n"
    
    if [[ "$wifi_state" == "enabled" ]]; then
        local networks=$(get_available_networks)
        
        while IFS= read -r line; do
            local in_use=$(echo "$line" | cut -d ':' -f 1)
            local signal=$(echo "$line" | cut -d ':' -f 2)
            local security=$(echo "$line" | cut -d ':' -f 3)
            local ssid=$(echo "$line" | cut -d ':' -f 4)
            
            [[ -z "$ssid" ]] && continue
            
            local signal_icon=""
            if [[ $signal -ge 75 ]]; then
                signal_icon="󰤨"
            elif [[ $signal -ge 50 ]]; then
                signal_icon="󰤥"
            elif [[ $signal -ge 25 ]]; then
                signal_icon="󰤢"
            else
                signal_icon="󰤟"
            fi
            
            local prefix=""
            if [[ "$in_use" == "*" ]]; then
                prefix="  "
            else
                prefix="    "
            fi
            
            local security_icon=""
            if [[ -n "$security" && "$security" != "--" ]]; then
                security_icon=" 󰌾"
            fi
            
            menu+="${prefix}${signal_icon} ${ssid}${security_icon}\n"
        done <<< "$networks"
    else
        menu+="    WiFi is disabled\n"
    fi
    
    menu+="──────────────────\n"
    menu+=" Open Network Settings"
    
    echo -e "$menu"
}

menu=$(create_menu)
selection=$(echo -e "$menu" | wofi --dmenu --prompt "Networks" --width 350 --height 500 --cache-file /dev/null)

case "$selection" in
    *"Turn WiFi on"*)
        toggle_wifi
        ;;
    *"Turn WiFi off"*)
        toggle_wifi
        ;;
    *"Refresh networks"*)
        refresh_networks
        ;;
    *"Ethernet connected"*)
        ;;
    *"Open Network Settings"*)
        nm-connection-editor
        ;;
    *"WiFi is disabled"*)
        ;;
    "──────────────────")
        ;;
    *)
        if [[ -n "$selection" ]]; then
            ssid=$(echo "$selection" | sed 's/^[ \t]*[^ ]* //' | sed 's/ 󰌾$//')
            connect_wifi "$ssid"
        fi
        ;;
esac

exit 0 
