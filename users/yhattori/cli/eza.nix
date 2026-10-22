# eza — modern `ls`.
#
# Replaces ls: `ls`/`ll`/`la`/`lt` are aliased to eza in zsh (icons, long/tree
# views).
{ pkgs, ... }:
{
  home.packages = [ pkgs.eza ];

  programs.zsh.shellAliases = {
    ls = "eza --icons always";
    ll = "eza -bhl --icons --group-directories-first";
    la = "eza -abhl --icons --group-directories-first";
    lt = "eza --tree --level=2 --icons";
  };
}
