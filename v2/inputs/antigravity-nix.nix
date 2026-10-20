# antigravity-nix — Google Antigravity agentic IDE packages.
#
# Provides google-antigravity-cli via its overlay (used by programs.antigravity-cli).
{
  url = "github:jacopone/antigravity-nix";
  inputs.nixpkgs.follows = "nixpkgs";
}
