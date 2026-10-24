# qt — Qt app theming.
#
# Point Qt apps at qtengine (overlays/qtengine.nix) so they follow DMS's
# *dynamic* Material 3 palette — teal accent, surface tones, etc. — instead of
# the static GTK theme. qtengine reads ~/.config/qtengine/config.json, pointing
# it at DMS's matugen-generated KColorScheme (DankMatugen.colors), so Qt apps
# re-theme live with wallpaper/theme changes. Installed for both Qt6 (`out`)
# and Qt5 (`qt5`) so older apps like VLC are covered too.
#
# The config.json is written here declaratively (a regular file, not a symlink)
# because DMS's matugen skips the qtengine sync on the stock/custom theme path;
# the colorScheme path never changes — DMS regenerates the .colors file in
# place — so a fixed path always tracks the live theme.
#
# Note: this themes the palette/fonts/icons/dialogs. Apps that set their own
# palette (VLC with `qt-dark-palette=1`) keep their own colours; it mainly
# helps other Qt apps (OBS, etc.) match DMS. It does NOT affect window title
# bars — those are Qt's hardcoded-light CSD or, for X11 apps, xwayland-satellite
# (see overlays/xwayland-satellite-dark.nix).
{ pkgs, config, ... }:
let
  colorScheme = "${config.home.homeDirectory}/.local/share/color-schemes/DankMatugen.colors";
in
{
  qt = {
    enable = true;
    platformTheme = {
      name = "qtengine";
      package = [ pkgs.qtengine pkgs.qtengine.qt5 ];
    };
  };

  xdg.configFile."qtengine/config.json".text = builtins.toJSON {
    theme = {
      inherit colorScheme;
      iconTheme = "Tela-circle-dark";
    };
  };
}
