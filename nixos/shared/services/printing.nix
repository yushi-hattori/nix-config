# printing — CUPS + SANE scanning.
{ pkgs, ... }:
{
  services.printing = {
    enable = true;
    drivers = with pkgs; [
      gutenprint
      # TODO: hplip broken in nixpkgs 20261017 (makeCWrapper/dconf gappsWrapper bug). Re-enable after upstream fix.
      # hplip
      brlaser
      splix
      cups-bjnp
      foomatic-db
      foomatic-db-ppds
      foomatic-db-nonfree
      foomatic-db-engine
    ];
  };

  hardware.sane = {
    enable = true;
    extraBackends = [
      # TODO: hplipWithPlugin builds hplip, broken in nixpkgs 20261017. Re-enable with hplip above.
      # pkgs.hplipWithPlugin
      pkgs.brscan4
    ];
  };

  programs.system-config-printer.enable = true;

  environment.systemPackages = [ pkgs.networkmanagerapplet ];
}
