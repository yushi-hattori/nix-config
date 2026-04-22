{
  config,
  lib,
  nhModules,
  pkgs,
  ...
}:
{
  imports = [
    "${nhModules}/misc/gtk"
    "${nhModules}/misc/qt"
    "${nhModules}/misc/wallpaper"
    "${nhModules}/misc/xdg"
    "${nhModules}/programs/swappy"
    "${nhModules}/programs/wofi" # or walker, but keeping existing imports if any
    "${nhModules}/services/cliphist"
    "${nhModules}/services/kanshi"
    "${nhModules}/services/swaync"
    "${nhModules}/services/waybar"
  ];

  # Consistent cursor theme
  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.yaru-theme;
    name = "Yaru";
    size = 24;
  };

  # Niri config is handled via xdg.configFile below

  # Enables kde connect
  services.kdeconnect = {
    enable = true;
    package = pkgs.kdePackages.kdeconnect-kde;
    indicator = true;
  };

  # Source niri config
  xdg.configFile."niri/config.kdl" = {
    source = ./config.kdl;
  };

  # Source hypridle config
  xdg.configFile."hypr/hypridle.conf" = {
    text = ''
      general {
        lock_cmd = pidof hyprlock || $HOME/.local/bin/dynamic-hyprlock
        before_sleep_cmd = loginctl lock-session
        after_sleep_cmd = "niri msg action load-config-file && systemctl --user restart kanshi.service && niri msg action power-on-monitors"
      }

      listener {
        timeout = 900
        on-timeout = loginctl suspend
      }
    '';
  };

  # Set GNOME-like desktop settings
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      "color-scheme" = "prefer-dark";
      "cursor-theme" = "Yaru";
      "font-name" = "Roboto 11";
      "icon-theme" = "Tela-circle-dark";
    };

    "org/gnome/desktop/wm/preferences" = {
      "button-layout" = lib.mkForce "";
    };

    "org/gnome/nautilus/preferences" = {
      "default-folder-viewer" = "list-view";
      "migrated-gtk-settings" = true;
      "search-filter-time-type" = "last_modified";
      "search-view" = "list-view";
    };

    "org/gtk/gtk4/settings/file-chooser" = {
      "show-hidden" = true;
    };

    "org/gtk/settings/file-chooser" = {
      "show-hidden" = true;
    };
  };

  # Niri-specific environment variables
  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    GDK_BACKEND = "wayland";
    QT_QPA_PLATFORM = "wayland";
    SDL_VIDEODRIVER = "wayland";
    CLUTTER_BACKEND = "wayland";
  };
}
