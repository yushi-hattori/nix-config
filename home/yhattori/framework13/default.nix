{ nhModules, inputs, ... }:
{
  imports = [
    "${nhModules}/common"
    "${nhModules}/desktop/niri"
    inputs.walker.homeManagerModules.walker
  ];

  # Enable home-manager
  programs.home-manager.enable = true;

  programs.walker = {
    enable = true;
    runAsService = true;
    config = {
      # Add 'menus' to default providers so power options show up in search
      providers.default = [ "desktopapplications" "runner" "menus" ];

      menus = [
        {
          name = "power";
          items = [
            {
              label = "Shutdown";
              exec = "shutdown now";
            }
            {
              label = "Reboot";
              exec = "reboot";
            }
            {
              label = "Suspend";
              exec = "systemctl suspend";
            }
            {
              label = "Lock";
              exec = "swaylock";
            }
          ];
        }
      ];
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "25.11";
}
