{ pkgs, ... }:
{
  # Enable CUPS to print documents.
  services.printing = {
    enable = true;
    drivers = with pkgs; [
      gutenprint
      hplip
      brlaser
      splix
      cups-bjnp
      foomatic-db
      foomatic-db-ppds
      foomatic-db-nonfree
      foomatic-db-engine
    ];
  };

  # Enable SANE for scanning
  hardware.sane = {
    enable = true;
    extraBackends = [
      pkgs.hplipWithPlugin
      pkgs.brscan4
    ];
  };

  # System-wide packages for printer management
  programs.system-config-printer.enable = true;

  # Additional desktop utilities for a "System Settings" feel
  environment.systemPackages = with pkgs; [
    blueman # Bluetooth manager
    pavucontrol # Audio control
    networkmanagerapplet # nm-connection-editor and nm-applet
  ];

  # Enable services for these utilities
  services.blueman.enable = true;
}
