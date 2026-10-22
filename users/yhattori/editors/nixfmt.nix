# nixfmt — nix formatter.
#
# Formats .nix files; wired into neovim (conform) and available as a standalone
# CLI for scripts/CI.
{ pkgs, ... }:
{
  home.packages = [ pkgs.nixfmt ];
}
