{ pkgs, ... }:
{
  # ROCm support for AMD Radeon 890M
  systemd.tmpfiles.rules = [
    "L+ /opt/rocm/hip - - - - ${pkgs.rocmPackages.clr}"
    "d /opt/amdgpu 0755 root root -"
    "d /opt/amdgpu/share 0755 root root -"
    "d /opt/amdgpu/share/libdrm 0755 root root -"
    "L+ /opt/amdgpu/share/libdrm/amdgpu.ids - - - - ${pkgs.libdrm}/share/libdrm/amdgpu.ids"
  ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      rocmPackages.clr.icd
      rocmPackages.clr
      rocmPackages.rocm-runtime
      rocmPackages.rocminfo
      rocmPackages.rocm-smi
    ];
  };

  # Environment variables for ROCm
  environment.sessionVariables = {
    ROC_ENABLE_PRE_VEGA = "1";
    HSA_OVERRIDE_GFX_VERSION = "11.0.2";
  };
}
