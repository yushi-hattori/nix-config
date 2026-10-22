# mamba — micromamba (conda-alternative).
#
# `conda`/`mamba` are aliased to micromamba in zsh; `deeplearning` activates the
# conda env holding PyTorch/ROCm. Shell init lives in zsh/init.nix.
{ pkgs, ... }:
{
  home.packages = [ pkgs.micromamba ];

  programs.zsh.shellAliases = {
    conda = "micromamba";
    mamba = "micromamba";
    deeplearning = "conda activate deeplearning";
  };
}
