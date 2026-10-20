# yazi — terminal file manager.
#
# Rust TUI file manager with image previews (via the yazi-latest overlay for
# kitty graphics). Integrated into neovim.
{ pkgs, ... }:
{
  home.packages = [ pkgs.yazi ];
}
