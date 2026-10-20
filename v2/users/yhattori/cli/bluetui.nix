# bluetui — bluetooth device manager (TUI).
#
# The `bt` alias. Pairs/connects bluetooth devices from the terminal; DMS only
# has a quick-toggle, not a full device manager.
{ pkgs, ... }:
{
  home.packages = [ pkgs.bluetui ];

  programs.zsh.shellAliases.bt = "bluetui";
}
