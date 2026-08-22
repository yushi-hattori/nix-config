{ pkgs, ... }:
{
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
    gnome-text-editor
    seahorse # keyring manager
    file-roller # archive manager
    baobab # disk usage analyzer
    gnome-system-monitor

    # Wayland/Niri utilities
    xwayland-satellite # if needed for X11 apps
    waybar # status bar
    swaynotificationcenter # notifications
    hypridle # idle daemon
    fuzzel # app launcher (or walker, which the user already has)
    swappy # screenshot editor
    grim # screenshot tool
    slurp # region selector
    wl-clipboard # clipboard manager
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
