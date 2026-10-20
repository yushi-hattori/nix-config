# Antigravity CLI — Google Antigravity agentic IDE (CLI).
#
# Google's agentic coding tool. Package comes from the antigravity-nix overlay;
# this is the home-manager module wrapping it.
{ ... }:
{
  programs.antigravity-cli = {
    enable = true;
  };
}
