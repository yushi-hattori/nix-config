# Inkcut — vinyl cutter controller.
#
# Ships a desktop entry + icon so it shows up in the launcher (DMS). The
# upstream package only provides the `inkcut` binary, no .desktop file.
{ pkgs, ... }:
{
  home.packages = [ pkgs.inkcut ];

  xdg.dataFile."icons/hicolor/128x128/apps/inkcut.png".source = ./inkcut/inkcut.png;

  xdg.desktopEntries.inkcut = {
    name = "Inkcut";
    exec = "inkcut";
    icon = "inkcut";
    comment = "Vinyl cutter / plotter controller";
    categories = [ "Graphics" ];
    terminal = false;
    type = "Application";
  };
}
