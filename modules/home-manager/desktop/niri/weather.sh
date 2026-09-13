#!/bin/sh
# Weather line for the hyprlock screen.
# Pattern adapted from JaKooLit/Hyprland-Dots (config/hypr/UserScripts/Weather.sh):
# query wttr.in once and cache the result for an hour, so hyprlock's hourly
# refresh (and every lock) doesn't hammer the API or stall on a slow request.
#
# hyprlock is spawned by hypridle, whose systemd service sets a minimal PATH
# (no bash/curl), so use /bin/sh and set a usable PATH ourselves.
PATH="/run/current-system/sw/bin:${HOME}/.nix-profile/bin:/etc/profiles/per-user/${USER}/bin:${PATH}"
export PATH

set -u

cache="${XDG_CACHE_HOME:-$HOME/.cache}/hyprlock-weather"
max_age=3600

if [ -s "$cache" ]; then
    age=$(( $(date +%s) - $(stat -c %Y "$cache" 2>/dev/null || echo 0) ))
    if [ "$age" -lt "$max_age" ]; then
        cat "$cache"
        exit 0
    fi
fi

# %c = condition emoji, %t = temperature, %C = condition text (location by IP)
data=$(curl -fsS --max-time 8 "https://wttr.in/?format=%c+%t+%C" 2>/dev/null || true)

if [ -z "$data" ]; then
    # Offline: reuse the last good value, else show a neutral placeholder.
    if [ -s "$cache" ]; then
        cat "$cache"
    else
        printf '%s\n' "🌡️  --  weather unavailable"
    fi
    exit 0
fi

printf '%s\n' "$data" | tee "$cache"
