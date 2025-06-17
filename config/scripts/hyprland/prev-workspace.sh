#!/bin/bash

MAX=5
current=$(hyprctl activeworkspace -j | jq '.id')
prev=$(( (current - 2 + MAX) % MAX + 1 ))

hyprctl dispatch workspace "$prev"
