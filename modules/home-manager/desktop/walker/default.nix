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
  };
}
