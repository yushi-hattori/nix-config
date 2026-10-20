# home-manager — per-user configuration.
#
# Follows nixpkgs so it shares the same package set.
{
  url = "github:nix-community/home-manager";
  inputs.nixpkgs.follows = "nixpkgs";
}
