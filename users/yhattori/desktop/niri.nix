# niri — the compositor (home-manager side).
#
# Plain config.kdl (nixpkgs' niri). DMS handles the shell layer; this file owns
# niri itself: input, layout, window rules, keybinds, and the monitor scripts.
{ ... }:
{
  xdg.configFile = {
    "niri/config.kdl".source = ./niri/config.kdl;
    # toggle_center.sh rewrites this at runtime; force reclaims it on rebuild.
    "niri/centering.kdl" = {
      source = ./niri/centering.kdl;
      force = true;
    };
    "niri/toggle_center.sh" = {
      source = ./niri/toggle_center.sh;
      executable = true;
    };
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
