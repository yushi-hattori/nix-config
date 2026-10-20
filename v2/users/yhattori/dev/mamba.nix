# mamba — micromamba (conda-alternative).
#
# `conda`/`mamba` are aliased to micromamba in zsh. Root prefix is ~/.mamba;
# the `deeplearning` alias activates the conda env that holds PyTorch/ROCm.
{ config, ... }:
{
  programs.mamba = {
    enable = true;
    rootPrefix = "${config.home.homeDirectory}/.mamba";
    channels = [ "conda-forge" ];
  };

  programs.zsh.shellAliases = {
    conda = "micromamba";
    mamba = "micromamba";
    deeplearning = "conda activate deeplearning";
  };
}
