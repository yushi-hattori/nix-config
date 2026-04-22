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
            # Laptop Screen
            criteria = "BOE NE135A1M-NY1 Unknown";
            status = "enable";
            mode = "2880x1920@120.000";
            scale = 1.75;
            position = "4359,2997";
          }
          {
            # Side Monitor (The one that flips between DP-7 and DP-8)
            criteria = "Dell Inc. DELL S2721D 1PVGP43";
            status = "enable";
            mode = "2560x1440@59.951";
            scale = 1.0;
            transform = "90";
            position = "2632,1060";
          }
          {
            # Main Monitor (The one that flips between DP-10 and DP-11)
            criteria = "Dell Inc. DELL S2721DGF FVM4093";
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
            criteria = "BOE NE135A1M-NY1 Unknown";
            status = "enable";
            mode = "2880x1920@120.000";
            scale = 1.75;
            position = "0,0";
          }
        ];
      }
    ];
  };
}
