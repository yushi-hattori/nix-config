{ constants, ... }:
{
  imports = [
    ../../shared/desktop
    ../../shared/services
    ./hardware
    ./boot
    ./power
    ./hardware-configuration.nix
  ];

  networking.hostName = constants.hostname;
  system.stateVersion = constants.stateVersion;
}
