# system — common system-wide settings.
#
# Locale, timezone, audio (PipeWire), sudo, bluetooth, docker, ssh, xwayland,
# fonts, and system packages.
{ config, pkgs, ... }:
{
  # Locale + timezone
  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "America/Los_Angeles";

  # Nix flakes + new CLI (required by `nixos-rebuild --flake`/`home-manager --flake`)
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Passwordless sudo (wheel group)
  security.sudo.wheelNeedsPassword = false;

  # PATH: ~/.local/bin
  environment.localBinInPath = true;

  # Wayland for Chromium/Electron + cursor size
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    XCURSOR_SIZE = "24";
  };

  # Disable systemd services that slow boot
  systemd.services = {
    NetworkManager-wait-online.enable = false;
    plymouth-quit-wait.enable = false;
  };

  # Input + power management
  services.libinput.enable = true;
  services.upower.enable = true;
  services.devmon.enable = true;

  # X server (for XWayland + keyboard layout)
  services.xserver = {
    xkb.layout = "us";
    xkb.variant = "";
    excludePackages = with pkgs; [ xterm ];
  };

  # Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  # Audio: PipeWire (PulseAudio disabled)
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Flatpak (system-level service)
  services.flatpak.enable = true;

  # Docker (rootless)
  virtualisation.docker.rootless.enable = true;
  virtualisation.docker.rootless.setSocketVariable = true;

  # XWayland (X11 apps)
  programs.xwayland.enable = true;

  # dconf (GTK settings)
  programs.dconf.enable = true;

  # Fonts
  fonts = {
    fontconfig.enable = true;
    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      nerd-fonts.meslo-lg
      roboto
    ];
  };

  # locate + ssh
  services.locate.enable = true;
  services.openssh.enable = true;

  # System packages
  environment.systemPackages = with pkgs; [
    gcc
    glib
    gnumake
    killall
    mesa
    usbutils
    claude-code
  ];
}
