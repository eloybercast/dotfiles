#!/bin/bash

if makoctl mode 2>/dev/null | grep -q "do-not-disturb"; then
    echo '{"text":"󰂛","tooltip":"DND ON","class":"dnd-enabled"}'
else
    echo '{"text":"󰂚","tooltip":"DND OFF","class":"dnd-disabled"}'
fi 