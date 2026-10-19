{ constants, ... }:
{
  home.username = constants.user.name;
  home.homeDirectory = "/home/${constants.user.name}";
  home.stateVersion = constants.stateVersion;

  programs.home-manager.enable = true;
}
