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
    "${nhModules}/programs/wofi" # or walker, but keeping existing imports if any
    "${nhModules}/services/cliphist"
    "${nhModules}/services/kanshi"
    "${nhModules}/services/swaync"
    "${nhModules}/services/wayle"
    # "${nhModules}/services/waybar"
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
  xdg.configFile."hypr/hyprlock.conf".text = ''
    general {
        hide_cursor = true
        ignore_empty_input = true
    }

    # Concurrent password (PAM) + fingerprint (fprintd over D-Bus)
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

    # BACKGROUND
    background {
        monitor =
        path = ${config.wallpaper}
        blur_passes = 2
        contrast = 0.8916
        brightness = 0.8172
        vibrancy = 0.1696
        vibrancy_darkness = 0.0
    }

    # TIME
    label {
        monitor =
        text = cmd[update:1000] echo "<span>$(date +"%H:%M")</span>"
        color = rgba(216, 222, 233, 0.70)
        font_size = 130
        font_family = Roboto Bold
        position = 0, 240
        halign = center
        valign = center
    }

    # DAY, DATE
    label {
        monitor =
        text = cmd[update:1000] echo -e "$(date +"%A, %d %B")"
        color = rgba(216, 222, 233, 0.70)
        font_size = 30
        font_family = Roboto Bold
        position = 0, 105
        halign = center
        valign = center
    }

    # NOW PLAYING (via playerctl; blank when nothing is playing)
    label {
        monitor =
        text = cmd[update:2000] playerctl metadata --format '  {{title}} — {{artist}}' 2>/dev/null
        color = rgba(255, 255, 255, 0.7)
        font_size = 18
        font_family = Roboto
        position = 0, 60
        halign = center
        valign = bottom
    }

    # PROFILE PHOTO
    image {
        monitor =
        path = ${squareAvatar}
        border_color = 0xffdddddd
        border_size = 0
        size = 120
        rounding = -1
        rotate = 0
        reload_time = -1
        reload_cmd =
        position = 0, -20
        halign = center
        valign = center
    }

    # USER
    label {
        monitor =
        text = Hi, $USER
        color = rgba(216, 222, 233, 0.70)
        font_size = 25
        font_family = Roboto Bold
        position = 0, -130
        halign = center
        valign = center
    }

    # INPUT FIELD
    input-field {
        monitor =
        size = 250, 60
        outline_thickness = 2
        dots_size = 0.2
        dots_spacing = 0.2
        dots_center = true
        outer_color = rgba(0, 0, 0, 0)
        inner_color = rgba(100, 114, 125, 0.4)
        font_color = rgb(200, 200, 200)
        fade_on_empty = false
        font_family = Roboto Bold
        placeholder_text = <i><span foreground="##ffffff99">Password or fingerprint</span></i>
        fail_text = <i>$FAIL <b>($ATTEMPTS)</b></i>
        hide_input = false
        position = 0, -225
        halign = center
        valign = center
    }

    # FINGERPRINT STATUS
    label {
        monitor =
        text = $FPRINTPROMPT
        color = rgba(255, 255, 255, 0.5)
        font_size = 14
        font_family = Roboto
        position = 0, -300
        halign = center
        valign = center
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
