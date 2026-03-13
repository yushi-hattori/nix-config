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
      # Note: PyTorch with ROCm is installed via mamba/conda
      # to avoid long build times in Nix
    ];
in
{
  home.packages = with pkgs; [
    (python313.withPackages pythonPackages)
    # ROCm utilities
    rocmPackages.rocm-smi
    rocmPackages.rocminfo
  ];
}
