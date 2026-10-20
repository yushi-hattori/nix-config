# libdisplay-info_0_2 — re-provided from nixpkgs-stable.
#
# niri-flake's niri build still requires libdisplay-info 0.2, which was removed
# from nixos-unstable. Pull the 0.2 package from nixpkgs-stable (26.05) instead.
{ inputs, ... }:
final: prev: {
  libdisplay-info_0_2 = inputs.nixpkgs-stable.legacyPackages.${final.stdenv.hostPlatform.system}.libdisplay-info_0_2;
}
