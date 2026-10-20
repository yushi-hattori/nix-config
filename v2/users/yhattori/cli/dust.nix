# dust — disk usage visualizer.
#
# `du` alternative that shows directory sizes as a readable tree.
{ pkgs, ... }:
{
  home.packages = [ pkgs.dust ];
}
