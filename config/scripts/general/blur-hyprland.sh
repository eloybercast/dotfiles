#!/usr/bin/env bash

HYPRLAND_BLUR_PASS="blur,kawase 8,1,1,1"

if [ "$1" = "on" ]; then
  hyprctl keyword decoration:blur true
  hyprctl keyword decoration:blur_size 20
  hyprctl keyword decoration:blur_passes 5
  hyprctl keyword animations:enabled 0
  hyprctl keyword decoration:drop_shadow false
elif [ "$1" = "off" ]; then
  hyprctl keyword decoration:blur true
  hyprctl keyword decoration:blur_size 8
  hyprctl keyword decoration:blur_passes 1
  hyprctl keyword animations:enabled 1
  hyprctl keyword decoration:drop_shadow true
fi 