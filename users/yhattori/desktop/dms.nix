# DankMaterialShell — the desktop shell (home-manager side).
#
# Enables DMS as a user service (systemd). DMS's lock screen is the login gate.
{ inputs, ... }:
{
  imports = [ inputs.dms.homeModules.dank-material-shell ];

  programs.dank-material-shell = {
    enable = true;

    # The shell runs as a user service (systemd). Defaults to false, so opt in.
    systemd.enable = true;

    # Disable optional integrations (they pull in extra deps we don't use):
    enableCalendarEvents = false; # khal (also has a broken sandbox man build)
    enableVPN = false;
    enableAudioWavelength = false; # cava
    enableSystemMonitoring = false; # dgop
  };
}
