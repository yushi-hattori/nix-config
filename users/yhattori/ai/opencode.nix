# opencode — AI coding agent (CLI), v2.1.4.
#
# The `oc` alias. Package now comes from the openchamber overlay, which builds
# opencode v2.1.4 once and reuses it both here and bundled in the desktop app,
# so there is a single opencode instead of the old 1.19.3 + 2.1.4 pair. Model
# selection is left to opencode's own config.
{ pkgs, ... }:
{
  home.packages = [ pkgs.opencode ];

  programs.zsh.shellAliases.oc = "opencode";
}
