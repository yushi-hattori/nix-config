#!/usr/bin/env bash

ACTION=$1
SLOT=$2

LAPTOP="BOE NE135A1M-NY1 Unknown"
SIDE="Dell Inc. DELL S2721D 1PVGP43"

OUTPUTS=$(niri msg outputs 2>/dev/null)

# Main Monitor: kanshi swaps it between the dock's DP port (identified by
# EDID) and a direct cable (no EDID, so niri reports it as
# "Unknown Unknown Unknown"). Unlike kanshi's config criteria, niri's own
# focus-monitor/move-*-to-monitor actions silently no-op on that
# description string -- they need the literal connector name. That name
# isn't stable across reboots/replugs, so look it up at runtime instead of
# hardcoding it.
UNKNOWN_CONNECTOR=$(echo "$OUTPUTS" | sed -n 's/^Output "Unknown Unknown Unknown" (\(.*\))$/\1/p')
if [ -n "$UNKNOWN_CONNECTOR" ]; then
  MAIN="$UNKNOWN_CONNECTOR"
else
  MAIN="Dell Inc. DELL S2721DGF FVM4093"
fi

# Clamshell detection: kanshi disables the laptop screen when the lid is
# closed, so niri reports a "Disabled" line directly under its header. In that
# case only the two external monitors are active, so shift them down to slots
# 1 and 2 (the laptop normally occupies slot 1).
if echo "$OUTPUTS" | grep -F -A1 "Output \"$LAPTOP\"" | grep -q '^[[:space:]]*Disabled'; then
  CLAMSHELL=1
fi

if [ "$CLAMSHELL" = "1" ]; then
  case $SLOT in
    1) TARGET="$MAIN" ;;
    2) TARGET="$SIDE" ;;
    *) exit 0 ;;
  esac
else
  case $SLOT in
    1) TARGET="$LAPTOP" ;;
    2) TARGET="$MAIN" ;;
    3) TARGET="$SIDE" ;;
    *) exit 0 ;;
  esac
fi

if [ "$ACTION" == "focus" ]; then
  niri msg action focus-monitor "$TARGET"
elif [ "$ACTION" == "move" ]; then
  niri msg action move-column-to-monitor "$TARGET"
fi
