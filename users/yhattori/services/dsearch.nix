# dsearch — indexed filesystem search.
#
# Runs as a user service (`dsearch serve`) and backs file results in DMS's
# launcher. Enabled via the dux-search flake's home-manager module.
{ inputs, ... }:
{
  imports = [ inputs.dsearch.homeModules.default ];

  programs.dsearch.enable = true;
}
