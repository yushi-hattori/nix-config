# nh — nix helper.
#
# Nicer wrapper around nixos-rebuild / home-manager (`nh os switch`,
# `nh home switch`) with pretty output.
{ pkgs, ... }:
{
  home.packages = [ pkgs.nh ];
}
