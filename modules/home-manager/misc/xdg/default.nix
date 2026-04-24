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
  pkgs.celluloid
  pkgs.vlc
  pkgs.smplayer
  pkgs.imv
  pkgs.zathura
  pkgs.kdePackages.gwenview
  pkgs.shotwell
  ];
defaultApplications = {
  "application/xhtml+xml" = [ "zen-twilight.desktop" ];
  "text/html" = [ "zen-twilight.desktop" ];
  "x-scheme-handler/about" = [ "zen-twilight.desktop" ];
  "x-scheme-handler/http" = [ "zen-twilight.desktop" ];
  "x-scheme-handler/https" = [ "zen-twilight.desktop" ];
  "x-scheme-handler/unknown" = [ "zen-twilight.desktop" ];
  "application/pdf" = [ "org.pwmt.zathura.desktop" ];
  "image/png" = [ "imv.desktop" ];
  "image/jpeg" = [ "imv.desktop" ];
  "image/gif" = [ "imv.desktop" ];
  "image/webp" = [ "imv.desktop" ];
  "video/mp4" = [ "io.github.celluloid_player.Celluloid.desktop" ];
  "video/mpeg" = [ "io.github.celluloid_player.Celluloid.desktop" ];
  "video/quicktime" = [ "io.github.celluloid_player.Celluloid.desktop" ];
  "video/webm" = [ "io.github.celluloid_player.Celluloid.desktop" ];
  "video/x-matroska" = [ "io.github.celluloid_player.Celluloid.desktop" ];
  "video/x-ms-wmv" = [ "io.github.celluloid_player.Celluloid.desktop" ];
  "video/x-msvideo" = [ "io.github.celluloid_player.Celluloid.desktop" ];
};
    };

    userDirs = {
      enable = true;
      createDirectories = true;
      setSessionVariables = true;
    };
  };
}
