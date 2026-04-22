#!/usr/bin/env bash

ACTION=$1
SLOT=$2

case $SLOT in
1) TARGET="BOE NE135A1M-NY1 Unknown" ;;
2) TARGET="Dell Inc. DELL S2721DGF FVM4093" ;;
3) TARGET="Dell Inc. DELL S2721D 1PVGP43" ;;
esac

if [ "$ACTION" == "focus" ]; then
  niri msg action focus-monitor "$TARGET"
elif [ "$ACTION" == "move" ]; then
  niri msg action move-column-to-monitor "$TARGET"
fi
