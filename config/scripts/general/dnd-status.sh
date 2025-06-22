#!/bin/bash

if makoctl mode | grep -q "do-not-disturb"; then
    echo '{"text":"󰂛","tooltip":"Do Not Disturb: ON","class":"dnd-enabled"}'
else
    echo '{"text":"󰂚","tooltip":"Do Not Disturb: OFF","class":"dnd-disabled"}'
fi 