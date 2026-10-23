# xdg — XDG user directories + default app associations.
#
# Creates/uses the standard ~/Documents, ~/Downloads, ~/Pictures, ~/Videos etc.
# and exports them to the session, plus pins default apps for links (zen),
# images (loupe), PDFs (zathura) and video (vlc).
{ ... }:
{
  xdg = {
    enable = true;
    mimeApps = {
      enable = true;
      defaultApplications = {
        "application/xhtml+xml" = [ "zen-twilight.desktop" ];
        "text/html" = [ "zen-twilight.desktop" ];
        "x-scheme-handler/about" = [ "zen-twilight.desktop" ];
        "x-scheme-handler/http" = [ "zen-twilight.desktop" ];
        "x-scheme-handler/https" = [ "zen-twilight.desktop" ];
        "x-scheme-handler/unknown" = [ "zen-twilight.desktop" ];
        "application/pdf" = [ "org.pwmt.zathura.desktop" ];
        "image/png" = [ "org.gnome.Loupe.desktop" ];
        "image/jpeg" = [ "org.gnome.Loupe.desktop" ];
        "image/gif" = [ "org.gnome.Loupe.desktop" ];
        "image/webp" = [ "org.gnome.Loupe.desktop" ];
        "video/mp4" = [ "vlc.desktop" ];
        "video/mpeg" = [ "vlc.desktop" ];
        "video/quicktime" = [ "vlc.desktop" ];
        "video/webm" = [ "vlc.desktop" ];
        "video/x-matroska" = [ "vlc.desktop" ];
        "video/x-ms-wmv" = [ "vlc.desktop" ];
        "video/x-msvideo" = [ "vlc.desktop" ];
      };
    };
    userDirs = {
      enable = true;
      createDirectories = true;
      setSessionVariables = true;
    };
  };
}
