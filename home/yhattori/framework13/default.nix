{ nhModules, inputs, ... }:
{
  imports = [
    "${nhModules}/common"
    "${nhModules}/desktop/kde"
    inputs.walker.homeManagerModules.walker
  ];

  # Enable home-manager
  programs.home-manager.enable = true;

  programs.walker = {
    enable = true;
    runAsService = true;
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "25.05";
}
