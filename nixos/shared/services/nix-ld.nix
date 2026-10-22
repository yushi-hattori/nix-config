# nix-ld — run non-Nix binaries (glibc-based).
{ pkgs, ... }:
{
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      libglvnd
      libx11
      libxext
      stdenv.cc.cc.lib
      zlib
    ];
  };
}
