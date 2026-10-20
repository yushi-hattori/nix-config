# niri — the compositor (home-manager side).
#
# Structured config via niri-flake (programs.niri.settings). DMS handles the
# shell layer; this file owns niri itself: input, layout, window rules, keybinds,
# and the monitor-management scripts.
#
# TODO (deferred): monitor topology (formerly kanshi) + monitor_action.sh's
# clamshell detection need reworking around DMS's output management.
{ inputs, config, ... }:
{
  imports = [ inputs.niri.homeModules.niri ];

  programs.niri = {
    enable = true;

    settings = {
      input = {
        keyboard = {
          xkb = {
            layout = "us";
            options = "caps:ctrl_modifier";
          };
          numlock = true;
          repeat-delay = 200;
          repeat-rate = 60;
        };
        touchpad = {
          tap = true;
          dwt = true;
        };
        warp-mouse-to-focus = true;
      };

      layout = {
        gaps = 0;
        preset-column-widths = [
          { proportion = 0.25; }
          { proportion = 0.5; }
          { proportion = 0.75; }
          { proportion = 1.0; }
        ];
        default-column-width = { proportion = 1.0; };
        border = { enable = false; };
        shadow = { enable = false; };
        struts = { };
      };

      # DMS runs as a systemd user service, so it's not spawned here.
      spawn-at-startup = [
        { command = [ "xwayland-satellite" ]; }
        {
          command = [
            "systemctl" "--user" "import-environment"
            "DISPLAY" "WAYLAND_DISPLAY" "XDG_CURRENT_DESKTOP"
          ];
        }
        {
          command = [
            "dbus-update-activation-environment" "--systemd"
            "DISPLAY" "WAYLAND_DISPLAY" "XDG_CURRENT_DESKTOP=niri"
          ];
        }
        {
          command = [ "systemctl" "--user" "start" "graphical-session.target" ];
        }
      ];

      environment = {
        DISPLAY = ":0";
      };

      hotkey-overlay = { };

      screenshot-path = "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";

      animations = { };

      window-rules = [
        # Open every new window maximized (full width, not fullscreen).
        { open-maximized = true; }
        {
          geometry-corner-radius = {
            top-left = 12.0;
            top-right = 12.0;
            bottom-left = 12.0;
            bottom-right = 12.0;
          };
          clip-to-geometry = true;
        }
        {
          matches = [ { app-id = "^org\\.wezfurlong\\.wezterm$"; } ];
          default-column-width = { };
        }
        {
          matches = [ { app-id = "firefox$"; title = "^Picture-in-Picture$"; } ];
          open-floating = true;
          open-fullscreen = false;
        }
        {
          matches = [ { title = "btop"; } ];
          open-floating = true;
          open-fullscreen = false;
          default-column-width = { proportion = 0.8; };
          default-window-height = { proportion = 0.8; };
        }
        {
          matches = [ { app-id = "^Autodesk Fusion 360$"; title = "already open"; } ];
          open-floating = true;
          open-fullscreen = false;
        }
      ];

      binds = with config.lib.niri.actions; {
        "Mod+Shift+Slash".action = show-hotkey-overlay;

        # Apps
        "Mod+Return".action = spawn "ghostty";
        # "Mod+Space".action = spawn "dms" "ipc" "spotlight" "toggle"; # DMS's launcher (enableKeybinds)
        "Mod+E".action = spawn "nautilus";

        # Screenshots
        "Print".action = spawn-sh "grim -t ppm - | satty --filename - --fullscreen --copy-command wl-copy --output-filename \"~/Pictures/Screenshots/satty-%Y%m%d-%H%M%S.png\" --actions-on-enter save-to-clipboard";
        "Ctrl+Print".action = screenshot-screen;
        "Alt+Print".action = screenshot-window;
        "Ctrl+Shift+S".action = spawn-sh "grim -g \"$(slurp)\" -t ppm - | satty --filename - --fullscreen --copy-command wl-copy --output-filename \"~/Pictures/Screenshots/satty-%Y%m%d-%H%M%S.png\" --actions-on-enter save-to-clipboard";

        # Window management
        "Mod+S".action = expel-window-from-column;
        "Mod+Shift+S".action = consume-window-into-column;
        "Mod+O".action = toggle-overview;
        "Mod+Q".action = close-window;
        "Mod+F".action = switch-preset-column-width;
        "Mod+Shift+F".action = switch-preset-column-width-back;
        # "Mod+M".action = fullscreen-window; # DMS's process list (enableKeybinds)
        # "Mod+C".action = spawn "wtype" "-M" "ctrl" "-k" "c"; # paste workaround (Mod+V = DMS clipboard)
        # "Mod+V".action = spawn "wtype" "-M" "ctrl" "-k" "v"; # DMS's clipboard (enableKeybinds)
        "Mod+Ctrl+C".action = center-visible-columns;
        "Mod+Ctrl+F".action = expand-column-to-available-width;

        # Focus
        "Mod+Left".action = spawn "wtype" "-k" "Home";
        "Mod+Down".action = focus-window-down;
        "Mod+Up".action = focus-window-up;
        "Mod+H".action = focus-column-left;
        "Mod+J".action = focus-window-or-workspace-down;
        "Mod+K".action = focus-window-or-workspace-up;
        "Mod+L".action = focus-column-right;
        "Mod+Tab".action = focus-column-right;
        "Mod+Shift+Tab".action = spawn "bash" "-c" "$HOME/.config/niri/move_column.sh next";
        "Mod+Right".action = spawn "wtype" "-k" "End";
        "Mod+Home".action = focus-column-first;
        "Mod+End".action = focus-column-last;

        # Movement
        "Mod+Ctrl+Left".action = move-column-left;
        "Mod+Ctrl+Right".action = move-column-right;
        "Mod+Shift+H".action = move-column-left;
        "Mod+Shift+L".action = move-column-right;
        "Mod+Shift+J".action = move-window-down-or-to-workspace-down;
        "Mod+Shift+K".action = move-window-up-or-to-workspace-up;
        "Mod+Shift+Down".action = move-window-down-or-to-workspace-down;
        "Mod+Shift+Up".action = move-window-up-or-to-workspace-up;
        "Mod+Ctrl+Home".action = move-column-to-first;
        "Mod+Ctrl+End".action = move-column-to-last;
        "Mod+W".action = toggle-column-tabbed-display;

        # Column width
        "Mod+R".action = switch-preset-column-width;
        "Mod+Shift+R".action = reset-window-height;
        "Mod+Ctrl+Shift+R".action = switch-preset-window-height;
        "Mod+Ctrl+R".action = reset-window-height;
        # "Mod+Comma".action = consume-window-into-column; # DMS's settings (enableKeybinds)
        "Mod+Period".action = expel-window-from-column;
        "Mod+BracketLeft".action = consume-or-expel-window-left;
        "Mod+BracketRight".action = consume-or-expel-window-right;
        "Mod+Minus".action = set-column-width "-10%";
        "Mod+Equal".action = set-column-width "+10%";
        "Mod+Shift+Minus".action = set-window-height "-10%";
        "Mod+Shift+Equal".action = set-window-height "+10%";

        # Monitor actions (slot-based)
        "Mod+1".action = spawn "bash" "-c" "$HOME/.config/niri/monitor_action.sh focus 1";
        "Mod+2".action = spawn "bash" "-c" "$HOME/.config/niri/monitor_action.sh focus 2";
        "Mod+3".action = spawn "bash" "-c" "$HOME/.config/niri/monitor_action.sh focus 3";
        "Mod+Shift+1".action = spawn "bash" "-c" "$HOME/.config/niri/monitor_action.sh move 1";
        "Mod+Shift+2".action = spawn "bash" "-c" "$HOME/.config/niri/monitor_action.sh move 2";
        "Mod+Shift+3".action = spawn "bash" "-c" "$HOME/.config/niri/monitor_action.sh move 3";

        # Directional
        "Mod+Shift+Left".action = focus-monitor-left;
        "Mod+Shift+Right".action = focus-monitor-right;
        "Mod+Ctrl+H".action = focus-monitor-left;
        "Mod+Ctrl+J".action = focus-monitor-down;
        "Mod+Ctrl+K".action = focus-monitor-up;
        "Mod+Ctrl+L".action = focus-monitor-right;

        # Workspaces
        "Mod+Page_Down".action = focus-workspace-down;
        "Mod+Page_Up".action = focus-workspace-up;
        "Mod+U".action = focus-workspace-down;
        "Mod+I".action = focus-workspace-up;
        "Mod+Ctrl+Page_Down".action = move-column-to-workspace-down;
        "Mod+Ctrl+Page_Up".action = move-column-to-workspace-up;
        "Mod+Ctrl+U".action = move-column-to-workspace-down;
        "Mod+Ctrl+I".action = move-column-to-workspace-up;
        "Mod+Shift+Page_Down".action = move-workspace-down;
        "Mod+Shift+Page_Up".action = move-workspace-up;
        "Mod+Shift+U".action = move-workspace-down;
        "Mod+Shift+I".action = move-workspace-up;
        "Mod+WheelScrollDown".action = focus-workspace-down;
        "Mod+WheelScrollUp".action = focus-workspace-up;
        "Mod+Ctrl+WheelScrollDown".action = move-column-to-workspace-down;
        "Mod+Ctrl+WheelScrollUp".action = move-column-to-workspace-up;
        "Mod+WheelScrollRight".action = focus-column-right;
        "Mod+WheelScrollLeft".action = focus-column-left;

        # System
        "Mod+Shift+E".action = quit;
        "Ctrl+Alt+Delete".action = quit;
        # "Mod+Alt+L".action = spawn "dms" "ipc" "lock" "lock"; # DMS's lock (enableKeybinds)
        "Mod+Escape".action = toggle-keyboard-shortcuts-inhibit;
        "Mod+Shift+V".action = switch-focus-between-floating-and-tiling;
        "Mod+Shift+P".action = power-off-monitors;

        # Media keys are DMS's (enableKeybinds: audio + brightness OSD).
        # "XF86AudioRaiseVolume".action = spawn "pamixer" "--increase" "10";
        # "XF86AudioLowerVolume".action = spawn "pamixer" "--decrease" "10";
        # "XF86AudioMute".action = spawn "pamixer" "--toggle-mute";
        # "XF86AudioMicMute".action = spawn "pamixer" "--default-source" "--toggle-mute";
        # "XF86AudioPlay".action = spawn "playerctl" "play-pause";
        # "XF86AudioNext".action = spawn "playerctl" "next";
        # "XF86AudioPrev".action = spawn "playerctl" "previous";
        # "XF86MonBrightnessUp".action = spawn "brightnessctl" "set" "+10%";
        # "XF86MonBrightnessDown".action = spawn "brightnessctl" "set" "10%-";
      };
    };
  };

  xdg.configFile = {
    "niri/monitor_action.sh" = {
      source = ./niri/monitor_action.sh;
      executable = true;
    };
    "niri/move_column.sh" = {
      source = ./niri/move_column.sh;
      executable = true;
    };
  };
}
