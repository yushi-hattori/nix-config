# DankMaterialShell — the desktop shell (home-manager side).
#
# Enables DMS as a user service (systemd) and wires its niri keybinds. Replaces
# walker/swaync/wayle/kanshi/hyprlock/hypridle/cliphist. DMS's lock screen is
# the login gate.
{ inputs, ... }:
{
  imports = [
    inputs.dms.homeModules.dank-material-shell
    inputs.dms.homeModules.niri
  ];

  programs.dank-material-shell = {
    enable = true;
    niri = {
      enableKeybinds = true;
    };
  };
}
