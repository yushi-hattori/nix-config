#!/usr/bin/env bash
CENTER_FILE="$HOME/.config/niri/centering.kdl"

if grep -q '"always"' "$CENTER_FILE" 2>/dev/null; then
    echo 'layout { center-focused-column "never"; }' > "$CENTER_FILE"
else
    echo 'layout { center-focused-column "always"; }' > "$CENTER_FILE"
fi

niri msg action load-config-file
