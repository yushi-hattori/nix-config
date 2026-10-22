# Google Chrome — secondary browser.
#
# Kept alongside zen (some sites/drm only work in Chrome).
{ pkgs, ... }:
{
  home.packages = [ pkgs.google-chrome ];
}
