# gtk — GTK app theming.
#
# Material theme (materia) so GTK apps match DankMaterialShell's Material 3 look.
# Icon/cursor/font are carried over (Tela icons, Yaru cursor, Roboto).
# TODO: confirm the theme name/variant against the DMS palette once that lands.
{ constants, pkgs, ... }:
{
  gtk = {
    enable = true;
    theme = {
      name = "Materia-dark";
      package = pkgs.materia-theme;
    };
    iconTheme = {
      name = "Tela-circle-dark";
      package = pkgs.tela-circle-icon-theme;
    };
    cursorTheme = {
      name = "Yaru";
      package = pkgs.yaru-theme;
      size = 24;
    };
    font = {
      name = "Roboto";
      size = 11;
    };
    gtk3 = {
      bookmarks = [
        "file:///home/${constants.user.name}/projects"
        "file:///home/${constants.user.name}/Documents"
        "file:///home/${constants.user.name}/Downloads"
        "file:///home/${constants.user.name}/Pictures"
        "file:///home/${constants.user.name}/Videos"
      ];
    };
  };

  home.pointerCursor = {
    enable = true;
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.yaru-theme;
    name = "Yaru";
    size = 24;
  };
}
