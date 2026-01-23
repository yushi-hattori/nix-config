{ pkgs, config, ... }:

{
  programs.mamba = {
    enable = true;
    rootPrefix = "${config.home.homeDirectory}/.mamba";
    channels = [
      "conda-forge"
    ];
  };
}