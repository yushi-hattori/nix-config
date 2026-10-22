{ constants, ... }:
{
  imports = [
    ./shell
    ./cli
    ./editors
    ./dev
    ./ai
    ./apps
    ./theme
    ./desktop
    ./scripts
    ./services
  ];

  home.username = constants.user.name;
  home.homeDirectory = "/home/${constants.user.name}";
  home.stateVersion = constants.stateVersion;

  programs.home-manager.enable = true;

  systemd.user.startServices = "sd-switch";
}
