#!/usr/bin/env bash

if [ "$1" = "on" ]; then
  hyprctl keyword animations:enabled 0
elif [ "$1" = "off" ]; then
  hyprctl keyword animations:enabled 1
fi 