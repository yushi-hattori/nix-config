{
  config,
  lib,
  pkgs,
  ...
}:
{
  xdg = {
    enable = true;

    mimeApps = {
      enable = true;

      defaultApplicationPackages = [
        pkgs.gnome-text-editor
        pkgs.loupe
        pkgs.totem
      ];

      defaultApplications = {
        "application/xhtml+xml" = [ "zen-twilight.desktop" ];
        "text/html" = [ "zen-twilight.desktop" ];
        "x-scheme-handler/about" = [ "zen-twilight.desktop" ];
        "x-scheme-handler/http" = [ "zen-twilight.desktop" ];
        "x-scheme-handler/https" = [ "zen-twilight.desktop" ];
        "x-scheme-handler/unknown" = [ "zen-twilight.desktop" ];
      };
    };

    userDirs = {
      enable = true;
      createDirectories = true;
      setSessionVariables = true;
    };
  };
}
