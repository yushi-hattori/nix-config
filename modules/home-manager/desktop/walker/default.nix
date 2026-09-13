{ inputs, lib, ... }:
{
  imports = [
    inputs.walker.homeManagerModules.walker
  ];

  programs.walker = {
    enable = true;
    runAsService = true;
  };

  xdg.configFile = {
    "walker/config.toml" = {
      source = lib.mkForce ./config.toml;
    };
  };

  xdg.configFile = {
    "elephant/menus/power.lua" = {
      source = lib.mkForce ./elephant/menus/power.lua;
    };
    # Sort the app list by usage history when Walker opens with an empty query.
    "elephant/desktopapplications.toml" = {
      source = lib.mkForce ./elephant/desktopapplications.toml;
    };
    # Window switcher shows only open windows, not workspace entries.
    "elephant/windows.toml" = {
      source = lib.mkForce ./elephant/windows.toml;
    };
  };
}
