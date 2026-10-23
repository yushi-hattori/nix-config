#!/usr/bin/env bash
CENTER_FILE="$HOME/.config/niri/centering.kdl"

# home-manager symlinks this file into the read-only Nix store, so replace the
# symlink with a real file we can write to.
if [ -L "$CENTER_FILE" ]; then
    rm "$CENTER_FILE"
    echo 'layout { center-focused-column "always"; }' > "$CENTER_FILE"
fi

if grep -q '"always"' "$CENTER_FILE" 2>/dev/null; then
    echo 'layout { center-focused-column "never"; }' > "$CENTER_FILE"
else
    echo 'layout { center-focused-column "always"; }' > "$CENTER_FILE"
fi

niri msg action load-config-file
