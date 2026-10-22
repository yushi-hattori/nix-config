# jq — JSON processor.
#
# Command-line JSON parsing/transformation; used in scripts and one-off shell
# work.
{ pkgs, ... }:
{
  home.packages = [ pkgs.jq ];
}
