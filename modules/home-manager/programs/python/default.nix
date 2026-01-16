{ pkgs, ... }:

let
  pythonPackages = ps: with ps; [
    pandas
    numpy
    matplotlib
    scikit-learn
    seaborn
    black
    isort
    pylint
    pip
  ];
in
{
  home.packages = with pkgs; [
    (python3.withPackages pythonPackages)
  ];
}