# flatpak — declarative flatpaks.
#
# Manages Flatpak apps via nix-flatpak. Currently: Zoom and Bambu Studio
# (both only ship as flatpak). `uninstallUnmanaged` removes any flatpak not
# declared here, keeping the list authoritative.
{ config, inputs, pkgs, ... }:
{
  imports = [ inputs.nix-flatpak.homeManagerModules.nix-flatpak ];

  services.flatpak = {
    enable = true;
    packages = [
      "us.zoom.Zoom"
      "com.bambulab.BambuStudio"
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
