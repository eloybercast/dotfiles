#!/bin/bash

entries="⏻ Shutdown\n⭮ Reboot\n⏾ Suspend\n⎋ Logout"

selected=$(echo -e $entries | wofi --width 250 --height 210 --dmenu --cache-file /dev/null | awk '{print tolower($2)}')

case $selected in
  shutdown)
    systemctl poweroff
    ;;
  reboot)
    systemctl reboot
    ;;
  logout)
    hyprctl dispatch exit
    ;;
esac 
