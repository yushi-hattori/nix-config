# playerctl — control media players.
#
# Play/pause/next for any MPRIS player. Used by DMS media controls and shell
# scripts.
{ pkgs, ... }:
{
  home.packages = [ pkgs.playerctl ];
}
