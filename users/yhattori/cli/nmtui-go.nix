# nmtui-go — NetworkManager Wi-Fi TUI.
#
# The `wifi` alias. Built from the nmtui-go overlay (not in nixpkgs); drives
# nmcli so it stays compatible with NetworkManager.
{ pkgs, ... }:
{
  home.packages = [ pkgs.nmtui-go ];

  programs.zsh.shellAliases.wifi = "nmtui-go";
}
