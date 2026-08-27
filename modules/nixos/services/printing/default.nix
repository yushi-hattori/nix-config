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

  # nm-connection-editor/nm-applet — blueman + pavucontrol live in the niri
  # desktop module already, this is the only printing-adjacent tray utility.
  environment.systemPackages = [ pkgs.networkmanagerapplet ];
}
