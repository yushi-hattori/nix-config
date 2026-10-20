# ripgrep — fast grep.
#
# The `rg` command; fzf previews and `fif` build on it.
{ pkgs, ... }:
{
  home.packages = [ pkgs.ripgrep ];
}
