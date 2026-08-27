{ ... }:
{
  # Manage kanshi services via Home-manager
  services.kanshi = {
    enable = true;
    systemdTarget = "graphical-session.target";
    settings = [
      {
        profile.name = "docked";
        profile.exec = [ "systemctl --user restart wayle" ];
        profile.outputs = [
          {
            # Laptop Screen
            criteria = "BOE NE135A1M-NY1 Unknown";
            status = "enable";
            mode = "2880x1920@120.000";
            scale = 1.75;
            position = "166,1152";
          }
          {
            # Side Monitor (The one that flips between DP-7 and DP-8)
            criteria = "Dell Inc. DELL S2721D 1PVGP43";
            status = "enable";
            mode = "2560x1440@59.951";
            scale = 1.25;
            transform = "90";
            position = "-1152,-253";
          }
          {
            # Main Monitor (The one that flips between DP-10 and DP-11)
            criteria = "Dell Inc. DELL S2721DGF FVM4093";
            status = "enable";
            mode = "2560x1440@59.951";
            scale = 1.25;
            position = "0,0";
          }
        ];
      }
      {
        # Clamshell mode: Thunderbolt dock connected, laptop lid closed.
        # Laptop screen disabled; only external monitors active.
        profile.name = "clamshell";
        profile.exec = [ "systemctl --user restart wayle" ];
        profile.outputs = [
          {
            criteria = "BOE NE135A1M-NY1 Unknown";
            status = "disable";
          }
          {
            criteria = "Dell Inc. DELL S2721D 1PVGP43";
            status = "enable";
            mode = "2560x1440@59.951";
            scale = 1.25;
            transform = "90";
            position = "-1152,-253";
          }
          {
            criteria = "Dell Inc. DELL S2721DGF FVM4093";
            status = "enable";
            mode = "2560x1440@59.951";
            scale = 1.25;
            position = "0,0";
          }
        ];
      }
      {
        profile.name = "undocked";
        profile.exec = [ "systemctl --user restart wayle" ];
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
