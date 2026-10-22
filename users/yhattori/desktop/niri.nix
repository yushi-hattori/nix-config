# niri — the compositor (home-manager side).
#
# Plain config.kdl (nixpkgs' niri). DMS handles the shell layer; this file owns
# niri itself: input, layout, window rules, keybinds, and the monitor scripts.
{ ... }:
{
  xdg.configFile = {
    "niri/config.kdl".source = ./niri/config.kdl;
    "niri/monitor_action.sh" = {
      source = ./niri/monitor_action.sh;
      executable = true;
    };
    "niri/move_column.sh" = {
      source = ./niri/move_column.sh;
      executable = true;
    };
  };
}
