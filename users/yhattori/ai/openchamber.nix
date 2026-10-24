# OpenChamber Desktop — the Electron GUI for OpenCode sessions.
#
# Ships the desktop entry (openchamber.desktop) + icon so it shows up in the
# launcher. Package comes from the openchamber overlay (overlays/openchamber.nix).
{ pkgs, ... }:
{
  home.packages = [ pkgs.openchamber-desktop ];
}
