#!/usr/bin/env bash

ACTION=$1
SLOT=$2

case $SLOT in
1) TARGET="BOE NE135A1M-NY1 Unknown" ;;
2)
  # Main Monitor: kanshi swaps it between the dock's DP port (identified by
  # EDID) and a direct cable (no EDID, so niri reports it as
  # "Unknown Unknown Unknown"). Unlike kanshi's config criteria, niri's own
  # focus-monitor/move-*-to-monitor actions silently no-op on that
  # description string -- they need the literal connector name. That name
  # isn't stable across reboots/replugs, so look it up at runtime instead of
  # hardcoding it.
  UNKNOWN_CONNECTOR=$(niri msg outputs 2>/dev/null | sed -n 's/^Output "Unknown Unknown Unknown" (\(.*\))$/\1/p')
  if [ -n "$UNKNOWN_CONNECTOR" ]; then
    TARGET="$UNKNOWN_CONNECTOR"
  else
    TARGET="Dell Inc. DELL S2721DGF FVM4093"
  fi
  ;;
3) TARGET="Dell Inc. DELL S2721D 1PVGP43" ;;
esac

if [ "$ACTION" == "focus" ]; then
  niri msg action focus-monitor "$TARGET"
elif [ "$ACTION" == "move" ]; then
  niri msg action move-column-to-monitor "$TARGET"
fi
