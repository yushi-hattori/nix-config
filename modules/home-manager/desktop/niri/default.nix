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

  xdg.configFile."niri/centering.kdl" = {
    source = ./centering.kdl;
  };

  # Source hypridle config
  xdg.configFile."hypr/hypridle.conf" = {
    source = ./hypridle.conf;
  };

  # hyprlock: the lock screen that also serves as the login gate. Password (PAM)
  # and fingerprint (fprintd D-Bus) are both enabled and run concurrently, so
  # either unlocks at any time. An empty `monitor =` draws each widget on every
  # output, so the prompt appears on all screens.
  xdg.configFile."hypr/hyprlock.conf".text = ''
    general {
        hide_cursor = true
        ignore_empty_input = true
    }

    background {
        monitor =
        path = ${config.wallpaper}
        blur_passes = 3
        contrast = 0.8916
        brightness = 0.8172
        vibrancy = 0.1696
        vibrancy_darkness = 0.0
    }

    auth {
        pam {
            enabled = true
        }
        fingerprint {
            enabled = true
            ready_message = Scan fingerprint or type password
            present_message = Scanning fingerprint...
        }
    }

    input-field {
        monitor =
        size = 400, 90
        outline_thickness = 2
        dots_size = 0.2
        dots_spacing = 0.2
        dots_center = true
        outer_color = rgba(0, 0, 0, 0)
        inner_color = rgba(0, 0, 0, 0.5)
        font_color = rgb(200, 200, 200)
        fade_on_empty = false
        placeholder_text = <i>Password or fingerprint</i>
        fail_text = <i>$FAIL <b>($ATTEMPTS)</b></i>
        position = 0, -120
        halign = center
        valign = center
    }

    label {
        monitor =
        text = cmd[update:1000] echo "$(date '+%H:%M')"
        color = rgba(255, 255, 255, 0.8)
        font_size = 120
        font_family = JetBrains Mono Nerd Font Mono ExtraBold
        position = 0, -300
        halign = center
        valign = top
    }

    label {
        monitor =
        text = cmd[update:1000] echo "$(date '+%A, %d %B')"
        color = rgba(255, 255, 255, 0.8)
        font_size = 24
        font_family = JetBrains Mono Nerd Font Mono ExtraBold
        position = 0, -170
        halign = center
        valign = top
    }
  '';

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
