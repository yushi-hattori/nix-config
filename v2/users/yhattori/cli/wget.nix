# wget — file downloader.
{ pkgs, ... }:
{
  home.packages = [ pkgs.wget ];
}
