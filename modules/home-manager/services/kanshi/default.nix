{ ... }:
{
  # Manage kanshi services via Home-manager
  services.kanshi = {
    enable = true;
    systemdTarget = "graphical-session.target";
    settings = [
      {
        profile.name = "docked";
        profile.outputs = [
          {
            criteria = "eDP-1";
            status = "enable";
            mode = "2880x1920@120.000";
            scale = 1.5;
            position = "4359,2997";

          }
          {
            criteria = "DP-8";
            status = "enable";
            mode = "2560x1440@59.951";
            scale = 1.0;
            transform = "90";
            position = "2632,1060";
          }
          {
            criteria = "DP-10";
            status = "enable";
            mode = "2560x1440@59.951";
            scale = 1.0;
            position = "4072,1557";
          }
        ];
      }
      {
        profile.name = "undocked";
        profile.outputs = [
          {
            criteria = "eDP-1";
            status = "enable";
            mode = "2880x1920@120.000";
            scale = 1.5;
            position = "0,0";
          }
        ];
      }
    ];
  };
}
