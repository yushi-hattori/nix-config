# wl-clipboard — Wayland clipboard CLI.
#
# `wl-copy`/`wl-paste`. The `ocr` script pipes text into it; fzf copies
# selections with it. (DMS provides clipboard *history*; this is the CLI.)
{ pkgs, ... }:
{
  home.packages = [ pkgs.wl-clipboard ];
}
