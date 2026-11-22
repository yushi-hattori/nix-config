# flatpak — declarative flatpaks.
#
# Manages Flatpak apps via nix-flatpak. Currently: Zoom and Bambu Studio
# (both only ship as flatpak) plus SolidCraft, which upstream ships as a
# flatpak from its own repo (not Flathub). `uninstallUnmanaged` removes any
# flatpak not declared here, keeping the list authoritative.
{ config, inputs, pkgs, ... }:
{
  imports = [ inputs.nix-flatpak.homeManagerModules.nix-flatpak ];

  services.flatpak = {
    enable = true;
    remotes = [
      { name = "flathub"; location = "https://dl.flathub.org/repo/flathub.flatpakrepo"; }
      { name = "solidcraft"; location = "https://docs.solidcraft.io/flatpak/solidcraft.flatpakrepo"; }
    ];
    packages = [
      "us.zoom.Zoom"
      "com.bambulab.BambuStudio"
      { appId = "io.tangencylabs.solidcraft"; origin = "solidcraft"; }
    ];
    uninstallUnmanaged = true;
    update.auto.enable = false;
  };

  home.packages = [ pkgs.flatpak ];

  xdg.systemDirs.data = [
    "/var/lib/flatpak/exports/share"
    "${config.home.homeDirectory}/.local/share/flatpak/exports/share"
  ];
}
