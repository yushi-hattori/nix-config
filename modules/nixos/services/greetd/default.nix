{ pkgs, ... }:
let
  regreetCss = builtins.replaceStrings [
    "@WALLPAPER@"
  ] [
    "file://${../../../home-manager/misc/wallpaper/space.png}"
  ] (builtins.readFile ./regreet.css);
in
{
  services.greetd.enable = true;
  security.pam.services.greetd.fprintAuth = true;

  programs.regreet = {
    enable = true;
    cageArgs = [
      "-s"
      "-d"
      "-m"
      "last"
    ];
    theme = {
      package = pkgs.gnome-themes-extra;
      name = "Adwaita-dark";
    };
    iconTheme = {
      package = pkgs.adwaita-icon-theme;
      name = "Adwaita";
    };
    font = {
      package = pkgs.roboto;
      name = "Roboto";
      size = 14;
    };
    cursorTheme = {
      package = pkgs.yaru-theme;
      name = "Yaru";
    };
    extraCss = regreetCss;
  };
}
