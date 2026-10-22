# DankMaterialShell — the desktop shell (NixOS side).
#
# System-level integration (PAM for the lock screen, fingerprint via fprintd).
# The shell itself runs as a user service via the home-manager module.
{ inputs, ... }:
{
  imports = [ inputs.dms.nixosModules.dank-material-shell ];

  programs.dank-material-shell = {
    enable = true;

    # The user service is provided by the home-manager module. If the NixOS
    # module also enables it, systemd sees two dms.service units claiming the
    # same org.freedesktop.Notifications bus name and refuses to start.
    systemd.enable = false;

    # Same optional integrations as the home-manager side (off here too so the
    # NixOS module's `common.packages` doesn't pull khal/cava/dgop):
    enableCalendarEvents = false; # khal (also has a broken sandbox man build)
    enableVPN = false;
    enableAudioWavelength = false; # cava
    enableSystemMonitoring = false; # dgop
  };
}
