# playerctl — control media players.
#
# Play/pause/next for any MPRIS player. Used by DMS media controls and shell
# scripts.
#
# Also runs playerctld (shipped with playerctl). It tracks the last-active MPRIS
# player, so `playerctl` with no --player flag targets the most recently used
# player instead of the first one alphabetically (which is why the browser
# always won over Spotify). Started as a user service.
{ pkgs, ... }:
{
  home.packages = [ pkgs.playerctl ];

  systemd.user.services.playerctld = {
    Unit = {
      Description = "Track the last-active MPRIS media player";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.playerctl}/bin/playerctld";
      Restart = "on-failure";
      RestartSec = 3;
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
