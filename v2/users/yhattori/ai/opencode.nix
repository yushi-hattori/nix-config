# opencode — AI coding agent (CLI).
#
# The `oc` alias. Package comes from the opencode-nix input + opencode-latest
# overlay; model selection is left to opencode's own config.
{ pkgs, ... }:
{
  home.packages = [ pkgs.opencode ];

  programs.zsh.shellAliases.oc = "opencode";
}
