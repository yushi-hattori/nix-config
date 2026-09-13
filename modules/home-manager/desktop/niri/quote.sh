#!/usr/bin/env bash
# Hourly lock-screen quote: randomly a dad joke or a fun fact, prefixed with
# "Joke of the Day:" or "Fun Fact:". Cached for an hour; falls back to the last
# value, then to a bundled line, when offline.
set -u

cache="${XDG_CACHE_HOME:-$HOME/.cache}/hyprlock-quote"
max_age=3600

if [ -s "$cache" ]; then
    age=$(( $(date +%s) - $(stat -c %Y "$cache" 2>/dev/null || echo 0) ))
    if [ "$age" -lt "$max_age" ]; then
        cat "$cache"
        exit 0
    fi
fi

random_joke() {
    local joke
    joke=$(curl -fsSL --max-time 8 -H "Accept: text/plain" "https://icanhazdadjoke.com/" 2>/dev/null) || true
    printf '%s' "$joke"
}

random_fact() {
    local json fact
    json=$(curl -fsSL --max-time 8 "https://api.popcat.xyz/fact" 2>/dev/null) || true
    [ -z "$json" ] && return 0
    if command -v jq >/dev/null 2>&1; then
        fact=$(printf '%s' "$json" | jq -r '.fact // empty' 2>/dev/null)
    else
        fact=$(printf '%s' "$json" | sed -n 's/.*"fact": *"\(.*\)".*/\1/p')
    fi
    printf '%s' "$fact"
}

if [ $(( RANDOM % 2 )) -eq 0 ]; then
    text="Joke of the Day: $(random_joke)"
else
    text="Fun Fact: $(random_fact)"
fi

# If the chosen source came back empty, try the other one once.
case "$text" in
    "Joke of the Day: " | "Fun Fact: ")
        text="Joke of the Day: $(random_joke)"
        ;;
esac

# Still empty (offline): reuse the last quote, else a bundled line.
case "$text" in
    "Joke of the Day: " | "Fun Fact: ")
        if [ -s "$cache" ]; then
            cat "$cache"
        else
            printf '%s\n' "Fun Fact: Honey never spoils."
        fi
        exit 0
        ;;
esac

printf '%s\n' "$text" | fold -s -w 58 | tee "$cache"
