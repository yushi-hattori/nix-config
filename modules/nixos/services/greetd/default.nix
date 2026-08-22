{ config, pkgs, ... }:
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
  # Try password/PIN before fingerprint: fprintAuth otherwise inserts pam_fprintd
  # ahead of pam_unix, so the greeter blocks on a fingerprint scan before a typed
  # PIN is even tried. Placing fprintd right after unix lets either one succeed.
  security.pam.services.greetd.rules.auth.fprintd.order =
    config.security.pam.services.greetd.rules.auth.unix.order + 10;

  programs.regreet = {
    enable = true;
    cageArgs = [
      "-s"
      "-d"
      "-m"
      "extend"
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
