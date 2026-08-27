{
  config,
  lib,
  nhModules,
  pkgs,
  ...
}:
let
  # hyprlock's `image` widget doesn't crop to square: it scales so the SHORTER
  # source dimension matches `size`, leaving the longer dimension to overflow
  # (see hyprlock's Image.cpp, texbox scaled by max(size/w, size/h) on both
  # axes). Apollo.jpg is a 2268x4032 portrait photo, so with `rounding = -1`
  # (circular) that rendered a stadium/oval, not a circle. Center-cropping to
  # a square here guarantees hyprlock always gets a square source.
  squareAvatar = pkgs.runCommand "avatar-square.jpg" { nativeBuildInputs = [ pkgs.imagemagick ]; } ''
    convert ${../../../../files/avatar/Apollo.jpg} -gravity center -extent 2268x2268 "$out"
  '';
in
{
  imports = [
    "${nhModules}/misc/gtk"
    "${nhModules}/misc/qt"
    "${nhModules}/misc/wallpaper"
    "${nhModules}/misc/xdg"
    "${nhModules}/programs/swappy"
    "${nhModules}/services/cliphist"
    "${nhModules}/services/kanshi"
    "${nhModules}/services/swaync"
    "${nhModules}/services/wayle"
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

  xdg.configFile."niri/centering.kdl" = {
    source = ./centering.kdl;
  };

  # Source hypridle config
  xdg.configFile."hypr/hypridle.conf" = {
    source = ./hypridle.conf;
  };

  # hyprlock: the lock screen that also serves as the login gate. Password (PAM)
  # and fingerprint (fprintd D-Bus) run concurrently, so either unlocks at any
  # time. Layout is "Style-9" from MrVivekRajan/Hyprlock-Styles, adapted to be
  # self-contained: repo wallpaper/avatar, an installed font (Roboto in place of
  # SF Pro), playerctl for now-playing (in place of the repo's script), and our
  # concurrent auth block added (upstream Style-9 has no fingerprint support).
  xdg.configFile."hypr/hyprlock.conf".text = builtins.replaceStrings
    [ "@WALLPAPER@" "@AVATAR@" ]
    [ "${config.wallpaper}" "${squareAvatar}" ]
    (builtins.readFile ./hyprlock.conf);

  services.hypridle = {
    enable = true;
  };

  # Source some extra scripts
  xdg.configFile."niri/monitor_action.sh" = {
    source = ./monitor_action.sh;
    executable = true;
  };

  xdg.configFile."niri/toggle_center.sh" = {
    source = ./toggle_center.sh;
    executable = true;
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
      "button-layout" = lib.mkForce ":close";
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
    GTK_USE_PORTAL = "1";
    QT_QPA_PLATFORM = "wayland";
    SDL_VIDEODRIVER = "wayland";
    CLUTTER_BACKEND = "wayland";
    WALLPAPER = "${config.wallpaper}";
  };
}
