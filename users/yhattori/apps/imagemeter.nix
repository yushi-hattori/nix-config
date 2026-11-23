# ImageMeter — photo measurement & annotation (Qt6 AppImage, wrapped).
#
# Not in nixpkgs; upstream only ships an AppImage (or .deb) for Linux. wrapType2
# extracts the AppImage and runs it in a buildFHSEnv bubblewrap sandbox, which
# supplies the X11/Wayland/GL/Qt libraries it expects. Commercial app with a
# 14-day trial (Pro/Business license).
{ pkgs, ... }:
let
  imagemeter = pkgs.appimageTools.wrapType2 {
    pname = "imagemeter";
    version = "26.10.0";
    src = pkgs.fetchurl {
      url = "https://imagemeter.com/data/imagemeter-v26.10.0-x86_64.AppImage";
      sha256 = "coHT2vdLLLmeWbp64HpIHxyzc5t2WQ2317gU8rxSkJk=";
    };
  };
in
{
  home.packages = [ imagemeter ];

  # AppImage only ships a 72x72 icon; install it so the launcher (DMS) shows it.
  xdg.dataFile."icons/hicolor/72x72/apps/imagemeter.png".source = ./imagemeter/imagemeter.png;

  xdg.desktopEntries.imagemeter = {
    name = "ImageMeter";
    exec = "imagemeter %F";
    icon = "imagemeter";
    comment = "Photo measurement and annotation";
    categories = [ "Graphics" "Photography" ];
    terminal = false;
    type = "Application";
  };
}
