# steam — gaming platform (with remote play firewall).
{ ... }:
{
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
  };
}
