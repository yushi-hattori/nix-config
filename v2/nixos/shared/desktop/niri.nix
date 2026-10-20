# niri — the compositor (NixOS side).
#
# Enables niri (via niri-flake), autologin on tty1 (the login flow: getty →
# zsh profileExtra → niri-session), lid-switch handling, and the desktop
# packages/apps.
{ inputs, constants, pkgs, ... }:
{
  imports = [ inputs.niri.nixosModules.niri ];

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
