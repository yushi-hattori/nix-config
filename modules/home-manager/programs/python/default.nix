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
      pylint
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
    (python311.withPackages pythonPackages)
  ];
}
