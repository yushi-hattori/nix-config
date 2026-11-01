# nmtui-go — NetworkManager Wi-Fi TUI.
#
# The `wifi` alias. Built from the nmtui-go overlay (not in nixpkgs); drives
# nmcli so it stays compatible with NetworkManager.
#
# The `login` alias is the manual fallback for the captive-portal dispatcher
# (nixos/shared/services/captive-portal.nix): opens a plain-HTTP URL that the
# portal redirects to its login page, in the default browser (zen).
{ pkgs, ... }:
{
  home.packages = [ pkgs.nmtui-go ];

  programs.zsh.shellAliases = {
    wifi = "nmtui-go";
    login = "gio open http://neverssl.com";
  };
}
