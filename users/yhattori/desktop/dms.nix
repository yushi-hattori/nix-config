# DankMaterialShell — the desktop shell (home-manager side).
#
# Enables DMS as a user service (systemd). DMS's lock screen is the login gate.
#
# DMS's settings.json is kept declarative: `dms-pull` (shell/zsh/functions.nix)
# copies the live file into ./dms/settings.json before every `uphm`, and the
# activation below writes it back out as a real (writable) file. We can't use a
# home-manager symlink here because DMS needs to write to it at runtime.
{ inputs, pkgs, lib, ... }:
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

  home.activation.dms-settings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD ${pkgs.coreutils}/bin/install -D -m644 \
      ${./dms/settings.json} "$HOME/.config/dms/settings.json"
  '';
}
