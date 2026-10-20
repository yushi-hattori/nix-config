# zen-browser — Zen browser (Firefox-based).
#
# Twilight build via its home module (imported in apps/zen-browser.nix).
{
  url = "github:0xc000022070/zen-browser-flake";
  inputs.nixpkgs.follows = "nixpkgs";
}
