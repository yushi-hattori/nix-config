{ pkgs, ... }:
{
  # Enable GDM display manager
  services.displayManager.gdm.enable = true;

  # Enable Niri
  programs.niri.enable = true;

  # Enable security services
  services.gnome.gnome-keyring.enable = true;
  security.polkit.enable = true;
  security.pam.services.gdm.enableGnomeKeyring = true;

  # Enable Bluetooth support (standard for desktops)
  services.blueman.enable = true;

  # List of Niri/GNOME specific packages
  environment.systemPackages = with pkgs; [
    # GNOME applications the user might expect
    nautilus # file manager
    loupe # image viewer
    gnome-calculator
    gnome-text-editor
    seahorse # keyring manager
    file-roller # archive manager
    baobab # disk usage analyzer
    gnome-system-monitor

    # Wayland/Niri utilities
    xwayland-satellite # if needed for X11 apps
    waybar # status bar
    swaynotificationcenter # notifications
    swaylock-effects # screen locker
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
      "gnome"
      "gtk"
    ];
    extraPortals = [
      pkgs.xdg-desktop-portal-gnome
      pkgs.xdg-desktop-portal-gtk
    ];
  };
}
