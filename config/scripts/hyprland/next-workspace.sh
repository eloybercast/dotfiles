#!/bin/bash

MAX=5
current=$(hyprctl activeworkspace -j | jq '.id')
next=$(( (current % MAX) + 1 ))

hyprctl dispatch workspace "$next"
