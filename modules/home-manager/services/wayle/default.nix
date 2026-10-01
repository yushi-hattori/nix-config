{ pkgs, ... }:
let
  # Emits the current niri windows as a wayle custom-module JSON payload.
  # `text` lists open apps in niri's scrolling-layout order, with a divider
  # between monitors; `tooltip` shows the same grouped by monitor.
  niri-windows = pkgs.writeShellApplication {
    name = "niri-windows";
    runtimeInputs = [
      pkgs.niri
      pkgs.jq
    ];
    text = ''
      {
        niri msg -j workspaces
        niri msg -j windows
      } | jq -s -r '
        def pretty:
          (.app_id // "?")
          | split(".")
          | last
          | gsub("_"; " ")
          | gsub("-twilight$"; "");
        def dedup:
          reduce .[] as $x ([]; if ([.[] | select(. == $x)] | length) == 0 then . + [$x] else . end);

        .[0] as $ws
        | .[1] as $wins
        | ($ws | map({ (.id | tostring): .output }) | add) as $out
        | ($ws | map({ (.id | tostring): .idx }) | add) as $wsidx
        | ($ws | map(select(.is_focused) | .output) | first // "") as $focusout
        | ($ws | map(select(.is_focused) | .active_window_id) | map(select(. != null)) | first // null) as $focusid
        | ($wins | map({
              id: .id,
              out: ($out[.workspace_id | tostring] // "?"),
              wsidx: ($wsidx[.workspace_id | tostring] // 0),
              col: ((.layout.pos_in_scrolling_layout // [0, 0])[0]),
              tile: ((.layout.pos_in_scrolling_layout // [0, 0])[1]),
              app: pretty,
              title: .title,
              f: (.id == $focusid)
            })) as $rows
        | ($rows | sort_by((if .out == $focusout then 0 else 1 end), .out, .wsidx, .col, .tile)) as $sorted
        | if ($sorted | length) == 0 then
            { text: "", tooltip: "No open windows" }
          else
            ([$sorted[] | select(.f) | .app] | first // "") as $focusapp
            | ($sorted | map(.out) | dedup) as $monitors
            | ($monitors | map(. as $m | ($sorted | map(select(.out == $m) | .app) | dedup))) as $monapps
            | ([$monitors, $monapps] | transpose | map(
                  .[0] + "\n" + (.[1] | map("  " + (if . == $focusapp then "● " else "· " end) + .) | join("\n"))
                )) as $blocks
            | {
                text: ($monapps | map(map(if . == $focusapp then "● " + . else . end) | join("  ")) | join("  │  ")),
                tooltip: (["Windows"] + $blocks | join("\n\n"))
              }
          end
      '
    '';
  };
in
# put this directly into your home-manager config or into a home-manager import
{
  # awww panics instead of clearing a stale socket left behind by an unclean
  # exit (e.g. dock/undock flapping racing a `systemctl --user restart wayle`
  # right after resume), then RestartSec=10 loops forever since nothing ever
  # removes the file. Clear it before each start so the loop can't get stuck.
  systemd.user.services.awww.Service.ExecStartPre = [
    "${pkgs.findutils}/bin/find %t -maxdepth 1 -name 'wayland-*-awww-daemon.sock' -delete"
  ];

  # Style custom-module tooltips to match wayle's native dropdown panels
  # (dark elevated card with rounded corners). The `tooltip` node is GTK4's
  # standard tooltip widget; `tooltip.background` is its inner background box.
  xdg.configFile."wayle/styles/index.scss".text = ''
    // Custom Wayle styles. Anything here overrides the built-in styling.
    // Use @import "name" to bring in _name.scss from this folder.

    tooltip {
      border-radius: 14px;
      box-shadow: 0 8px 24px rgba(0, 0, 0, 0.45);
    }

    tooltip.background {
      background-color: var(--palette-elevated);
      color: var(--palette-fg);
      border: 1px solid rgba(255, 255, 255, 0.07);
      padding: 10px 14px;
    }
  '';

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
              "clock"
              "weather"
            ];
            left = [
              "custom-launcher"
              "custom-windows"
              "media"
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
        custom = [
          {
            id = "launcher";
            icon-name = "view-app-grid-symbolic";
            label-show = false;
            left-click = "${pkgs.niri}/bin/niri msg action toggle-overview";
            border-color = "accent";
            border-show = true;
            icon-bg-color = "accent";
            icon-color = "accent";
          }
          {
            id = "windows";
            command = "${niri-windows}/bin/niri-windows";
            mode = "poll";
            interval-ms = 1000;
            hide-if-empty = true;
            label-max-length = 60;
            icon-show = false;
            left-click = "walker -m windows";
            border-color = "accent";
            border-show = true;
            label-color = "accent";
          }
        ];
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
        # Each monitor is matched by connector name, which is NOT stable across
        # reboots/replugs: the side monitor lands on DP-2/DP-6/DP-7/DP-8 and the
        # main monitor on DP-10/DP-11 depending on cable/dock (see
        # services/kanshi). Every name a monitor can take needs its own entry,
        # otherwise that monitor silently gets a black background.
        monitors = [
          # Side monitor (portrait): flips between DP-2/DP-6/DP-7/DP-8
          {
            fit-mode = "fill";
            name = "DP-2";
            wallpaper = toString ../../../../files/wallpapers/apollo-wallpaper.jpg;
          }
          {
            fit-mode = "fill";
            name = "DP-6";
            wallpaper = toString ../../../../files/wallpapers/apollo-wallpaper.jpg;
          }
          {
            fit-mode = "fill";
            name = "DP-7";
            wallpaper = toString ../../../../files/wallpapers/apollo-wallpaper.jpg;
          }
          {
            fit-mode = "fill";
            name = "DP-8";
            wallpaper = toString ../../../../files/wallpapers/apollo-wallpaper.jpg;
          }
          # Laptop screen (undocked)
          {
            fit-mode = "fill";
            name = "eDP-1";
            wallpaper = toString ../../../../files/wallpapers/apollo-wallpaper.jpg;
          }
          # Main monitor: flips between DP-10/DP-11
          {
            fit-mode = "fill";
            name = "DP-10";
            wallpaper = toString ../../../../files/wallpapers/wedding-wallpaper.jpg;
          }
          {
            fit-mode = "fill";
            name = "DP-11";
            wallpaper = toString ../../../../files/wallpapers/wedding-wallpaper.jpg;
          }
        ];
      };
    };
  };
}
