{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    inputs.nirinit.nixosModules.nirinit
  ];

  # Keep external displays usable in clamshell/docked mode.
  services.logind = {
    settings.Login = {
      HandleLidSwitch = "suspend";
      HandleLidSwitchExternalPower = "ignore";
      HandleLidSwitchDocked = "ignore";
    };
  };

  # Enable Niri
  programs.niri.enable = true;

  # nirinit: periodically snapshots the open niri windows and relaunches them
  # (with their workspace, output and size) on the next session, e.g. after a
  # reboot. `launch` maps a window's Wayland app_id to the command used to
  # relaunch it. An unmapped app_id is used verbatim as the command, so apps
  # whose app_id is not an executable (GNOME reverse-DNS ids, ghostty, ...)
  # need an entry here. Anything not listed still restores as long as its
  # app_id happens to be a runnable binary (e.g. `zen-twilight`).
  services.nirinit = {
    enable = true;
    settings.launch = {
      "com.mitchellh.ghostty" = "ghostty";

      "org.gnome.Nautilus" = "nautilus";
      "org.gnome.Loupe" = "loupe";
      "org.gnome.Calculator" = "gnome-calculator";
      "org.gnome.Calendar" = "gnome-calendar";
      "org.gnome.TextEditor" = "gnome-text-editor";
      "org.gnome.seahorse.Application" = "seahorse";
      "org.gnome.FileRoller" = "file-roller";
      "org.gnome.baobab" = "baobab";
      "org.gnome.SystemMonitor" = "gnome-system-monitor";
    };
  };

  # The upstream module hardcodes nirinit's default 300s save interval. Save
  # every 60s instead: niri tears its windows down before nirinit receives its
  # shutdown signal, so the periodic save is the reliable one, and a session
  # that starts fresh (seeded empty on first run) would otherwise go
  # uncaptured for five minutes.
  systemd.user.services.nirinit.serviceConfig.ExecStart = lib.mkForce (
    "${lib.getExe config.services.nirinit.package} --config ${
      (pkgs.formats.toml { }).generate "nirinit-config.toml" config.services.nirinit.settings
    } --save-interval 60"
  );

  # Screen locker used as the login gate (see hosts/framework13 autologin).
  # This installs hyprlock, enables hypridle, and creates the "hyprlock" PAM
  # service for password auth. Fingerprint auth is handled by hyprlock itself
  # over fprintd's D-Bus API (independent of PAM), so the two run concurrently
  # and NEITHER should be chained in PAM — do not set fprintAuth here.
  programs.hyprlock.enable = true;
  services.fprintd.enable = true;
  # fprintd being enabled injects pam_fprintd into every PAM service by default.
  # For hyprlock that's harmful: its PAM stack would block on a fingerprint scan
  # before accepting a typed password, while hyprlock is ALSO reading the sensor
  # over D-Bus — two readers fighting. Keep hyprlock's PAM password-only; the
  # fingerprint path is hyprlock's own D-Bus code, so the two stay concurrent.
  security.pam.services.hyprlock.fprintAuth = false;

  # Enable security and file services
  services.gnome.gnome-keyring.enable = true;
  services.gvfs.enable = true;
  security.polkit.enable = true;

  # Enable Bluetooth support (standard for desktops)
  services.blueman.enable = true;

  # List of Niri/GNOME specific packages
  environment.systemPackages = with pkgs; [
    # GNOME applications the user might expect
    nautilus # file manager
    loupe # image viewer
    gnome-calculator
    gnome-calendar
    gnome-control-center # Settings: Wi-Fi, Bluetooth, etc.
    gnome-text-editor
    seahorse # keyring manager
    file-roller # archive manager
    baobab # disk usage analyzer
    gnome-system-monitor

    # Wayland/Niri utilities
    xwayland-satellite # if needed for X11 apps
    wayle
    swaynotificationcenter # notifications
    hypridle # idle daemon
    swappy # screenshot editor
    grim # screenshot tool
    slurp # region selector
    satty # screenshot annotation editor (Snagit-like)
    wl-clipboard # clipboard manager
    wtype # synthesize keys (Mod+Left/Right -> Home/End)
    libnotify # for notifications
    brightnessctl # backlight control
    pamixer # audio control
    pavucontrol # audio mixer
    wdisplays
  ];

  # Niri needs some portals to work correctly (e.g. for screen sharing)
  xdg.portal = {
    enable = true;
    config.common.default = [
      "niri"
      "gnome"
      "gtk"
    ];
    extraPortals = [
      pkgs.xdg-desktop-portal-gnome
      pkgs.xdg-desktop-portal-gtk
    ];
  };
}
