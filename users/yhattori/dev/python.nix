# python — python toolchain.
#
# A python313 env with the data-science stack (pandas, numpy, sklearn, jupyter,
# etc.). PyTorch/ROCm is intentionally left to mamba/conda to avoid long Nix
# build times; rocm-smi/rocminfo are added here for GPU visibility.
{ pkgs, ... }:
let
  pythonPackages =
    ps: with ps; [
      pandas
      numpy
      matplotlib
      scikit-learn
      seaborn
      black
      isort
      pip
      ipykernel
      jupyterlab
      ipywidgets
      widgetsnbextension
      jupytext
    ];
in
{
  home.packages = with pkgs; [
    (python313.withPackages pythonPackages)
    rocmPackages.rocm-smi
    rocmPackages.rocminfo
  ];
}
