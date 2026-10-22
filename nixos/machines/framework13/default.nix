{ constants, ... }:
{
  imports = [
    ../../shared/users.nix
    ../../shared/system.nix
    ../../shared/desktop
    ../../shared/services
    ../../shared/programs
    ./networking.nix
    ./hardware
    ./boot
    ./power
    ./hardware-configuration.nix
  ];

  networking.hostName = constants.hostname;
  system.stateVersion = constants.stateVersion;
}
