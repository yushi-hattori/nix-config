{ pkgs, ... }:
# put this directly into your home-manager config or into a home-manager import
{
  services.wayle = {
    enable = true;

    # Whether to automatically install soft dependencies used by wayle that
    # will be required based on your config.
    autoInstallDependencies = true;

    # tip: you can automatically translate your TOML config to Nix by running
    # nix-instantiate --eval --expr 'builtins.fromTOML (builtins.readFile ./config.toml)' | nixfmt
    settings = {
      bar = {
        background-opacity = 75;
        border-location = "top";
        button-label-weight = "medium";
        button-opacity = 80;
        button-rounding = "full";
        button-variant = "basic";
        dropdown-opacity = 100;
        inset-edge = 0.35;
        inset-ends = 0.35;
        layout = [
          {
            center = [
              "media"
              "clock"
              "weather"
            ];
            left = [
              "niri-workspaces"
              "cpu"
              "storage"
              "ram"
              "netstat"
            ];
            monitor = "*";
            right = [
              "bluetooth"
              "microphone"
              "volume"
              "network"
              "battery"
              "idle-inhibit"
              "notifications"
              "dashboard"
            ];
            show = true;
          }
        ];
        padding-ends = 1.5;
        rounding = "lg";
        scale = 0.8;
      };
      general = {
        font-sans = "JetBrainsMonoNL Nerd Font Propo";
      };
      modules = {
        battery = {
          border-color = "accent";
          border-show = true;
          icon-bg-color = "accent";
          icon-color = "accent";
          label-color = "accent";
        };
        bluetooth = {
          border-color = "accent";
          border-show = true;
          icon-bg-color = "accent";
          icon-color = "accent";
          label-color = "accent";
        };
        brightness = {
          border-color = "accent";
          border-show = true;
          icon-bg-color = "accent";
          label-color = "accent";
        };
        clock = {
          border-color = "fg-default";
          border-show = true;
          format = "%a %b %-d | %-I:%M %p | Day %-j/365";
          icon-bg-color = "fg-default";
          icon-color = "fg-default";
          label-color = "fg-default";
        };
        cpu = {
          border-color = "accent";
          border-show = true;
          icon-bg-color = "accent";
          icon-color = "accent";
          label-color = "accent";
        };
        dashboard = {
          border-color = "accent";
          border-show = true;
          icon-bg-color = "accent";
          icon-color = "accent";
        };
        idle-inhibit = {
          border-color = "accent";
          border-show = true;
          icon-bg-color = "accent";
          icon-color = "accent";
          label-color = "accent";
        };
        media = {
          border-color = "accent";
          border-show = true;
          icon-bg-color = "accent";
          icon-color = "accent";
          label-color = "accent";
        };
        microphone = {
          border-color = "accent";
          border-show = true;
          icon-bg-color = "accent";
          icon-color = "accent";
          label-color = "accent";
        };
        netstat = {
          border-color = "accent";
          border-show = true;
          icon-bg-color = "accent";
          icon-color = "accent";
          label-color = "accent";
        };
        network = {
          border-show = true;
          icon-color = "accent";
        };
        notifications = {
          border-color = "accent";
          border-show = true;
          icon-bg-color = "accent";
          icon-color = "accent";
          label-color = "accent";
        };
        power = {
          border-show = true;
        };
        ram = {
          border-color = "accent";
          border-show = true;
          icon-bg-color = "accent";
          icon-color = "accent";
          label-color = "accent";
        };
        storage = {
          border-color = "accent";
          border-show = true;
          icon-bg-color = "accent";
          icon-color = "accent";
          label-color = "accent";
        };
        systray = {
          border-show = true;
        };
        volume = {
          border-color = "accent";
          border-show = true;
          icon-bg-color = "accent";
          icon-color = "accent";
          label-color = "accent";
        };
        weather = {
          border-color = "fg-default";
          border-show = true;
          icon-bg-color = "fg-default";
          icon-color = "fg-default";
          label-color = "fg-default";
        };
      };
      osd = {
        margin = 0;
        position = "top-right";
      };
      styling = {
        palette = {
          bg = "#0a0a0a";
          blue = "#33b1ff";
          elevated = "#1f1f1f";
          fg = "#f2f4f8";
          fg-muted = "#a8aab1";
          green = "#25be6a";
          primary = "#78a9ff";
          red = "#ee5396";
          surface = "#161616";
          yellow = "#08bdba";
        };
      };
      wallpaper = {
        # Needed for autoInstallDependencies to pull in and start the awww
        # (swww-compatible) wallpaper daemon; without it, per-monitor
        # wallpapers below silently fail with "neither awww nor swww found
        # in PATH".
        engine-enabled = true;
        monitors = [
          {
            fit-mode = "fill";
            name = "DP-8";
            wallpaper = toString ../../../../files/wallpapers/apollo-wallpaper.jpg;

          }
          {
            fit-mode = "fill";
            name = "DP-10";
            wallpaper = toString ../../../../files/wallpapers/wedding-wallpaper.jpg;
          }
        ];
      };
    };
  };
}
