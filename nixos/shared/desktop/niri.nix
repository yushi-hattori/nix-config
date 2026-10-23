# niri — the compositor (NixOS side).
#
# Enables niri (nixpkgs module), autologin on tty1 (the login flow: getty →
# zsh profileExtra → niri-session), lid-switch handling, and the desktop
# packages/apps.
{ constants, pkgs, ... }:
{
  programs.niri.enable = true;

  # Login flow: autologin straight into niri (no display manager). DMS's lock
  # screen is the real login gate. Launched from zsh's profileExtra.
  services.getty.autologinUser = constants.user.name;

  # Keep external displays usable in clamshell/docked mode.
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "ignore";
    HandleLidSwitchDocked = "ignore";
  };

  services.blueman.enable = true;
  services.fprintd.enable = true;
  # fprintd injects pam_fprintd.so into every PAM service by default, which
  # makes DMS's lock screen (using the login PAM) require fingerprint *and*
  # password. Disable the chaining here so the PAM auth is password-only; DMS
  # can do fingerprint via fprintd's D-Bus API instead (concurrent, either one
  # unlocks) from its own Lock Screen settings.
  security.pam.services.login.fprintAuth = false;

  # Security, keyring, and file services (DMS needs polkit for its auth agent).
  services.gnome.gnome-keyring.enable = true;
  services.gvfs.enable = true;
  security.polkit.enable = true;

  # Portals (screen sharing, file dialogs)
  xdg.portal = {
    enable = true;
    config.common.default = [ "niri" "gnome" "gtk" ];
    extraPortals = [
      pkgs.xdg-desktop-portal-gnome
      pkgs.xdg-desktop-portal-gtk
    ];
  };

  environment.systemPackages = with pkgs; [
    # GNOME apps
    nautilus
    loupe
    gnome-calculator
    gnome-calendar
    gnome-text-editor
    seahorse
    file-roller
    baobab
    gnome-system-monitor

    # Wayland/niri utilities
    xwayland-satellite
    grim
    slurp
    satty
    wl-clipboard
    wtype
    libnotify
    brightnessctl
    pamixer
    pavucontrol
    wdisplays
  ];
}
