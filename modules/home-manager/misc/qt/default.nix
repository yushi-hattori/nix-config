{
  config,
  lib,
  pkgs,
  ...
}:
let
  qtCtAppearanceConfig = (pkgs.formats.ini { }).generate "qtct-config" {
    Appearance = {
      icon_theme = config.gtk.iconTheme.name;
      style = "kvantum";
      standard_dialogs = "default";
    };
  };
in
{
  home.packages = with pkgs; [
    # Support both Qt5 and Qt6
    libsForQt5.qtstyleplugin-kvantum
    libsForQt5.qt5ct
    kdePackages.qtstyleplugin-kvantum
    kdePackages.qt6ct
  ];

  qt = {
    enable = true;
    platformTheme.name = "qtct";
    style.name = "kvantum";
  };

  # Use catppuccin nix module for kvantum and qt5ct theming
  catppuccin.kvantum.enable = true;
  catppuccin.qt5ct.enable = true;

  home.sessionVariables = {
    # Force Kvantum for Qt apps to ensure correct colors
    QT_STYLE_OVERRIDE = "kvantum";
  };

  xdg.configFile = {
    # qt5ct is handled by catppuccin module
    # qt6ct is handled manually for now
    "qt6ct/qt6ct.conf".source = lib.mkForce qtCtAppearanceConfig;
  };
}
