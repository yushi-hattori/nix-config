# DankMaterialShell — the desktop shell (NixOS side).
#
# System-level integration (PAM for the lock screen, fingerprint via fprintd).
# The shell itself runs as a user service via the home-manager module.
{ inputs, ... }:
{
  imports = [ inputs.dms.nixosModules.dank-material-shell ];

  programs.dank-material-shell.enable = true;
}
