#!/usr/bin/env bash
# move_column.sh <direction>
# Move the focused column to the adjacent monitor (left/right/up/down/next),
# then reset the window height to "automatic".
#
# Workaround for a niri bug: a column moved to a monitor with a different
# scale/resolution keeps its previous height until something forces a relayout
# (e.g. switching workspace), leaving the window short of full height.
# reset-window-height puts the window back to automatic (full height).
niri msg action "move-column-to-monitor-$1"
niri msg action reset-window-height
