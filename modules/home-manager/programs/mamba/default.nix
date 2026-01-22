{ pkgs, ... }:

{
  programs.mamba = {
    enable = true;
    channels = [
      "conda-forge"
    ];
  };
}