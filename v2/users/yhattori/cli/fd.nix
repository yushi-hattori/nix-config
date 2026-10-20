# fd — faster `find`.
#
# Friendlier find with sane defaults. Used by tooling/scripts that need quick
# file search.
{ pkgs, ... }:
{
  home.packages = [ pkgs.fd ];
}
