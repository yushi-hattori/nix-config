{ inputs, ... }:
{
  imports = [
    inputs.hardware.nixosModules.common-cpu-amd
    inputs.hardware.nixosModules.common-gpu-amd
    inputs.hardware.nixosModules.common-pc-ssd
    inputs.hardware.nixosModules.framework-amd-ai-300-series
  ];

  # The community framework-laptop-kmod (out-of-tree) fails to build against
  # the current kernel (a nixpkgs module-signing regression). Use the in-tree
  # framework_laptop driver instead for EC control.
  hardware.framework.enableKmod = false;
  boot.kernelModules = [ "framework_laptop" ];
}
