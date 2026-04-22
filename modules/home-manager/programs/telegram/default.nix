{
  config,
  pkgs,
  lib,
  ...
}:
{
  home.packages = [ pkgs.telegram-desktop ];

  xdg = lib.mkIf (!pkgs.stdenv.isDarwin) {
    mimeApps = {
      defaultApplicationPackages = [ pkgs.telegram-desktop ];
    };
  };
}
