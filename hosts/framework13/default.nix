{
  inputs,
  hostname,
  nixosModules,
  pkgs,
  ...
}:
{
  imports = [
    inputs.hardware.nixosModules.common-cpu-amd
    inputs.hardware.nixosModules.common-gpu-amd
    inputs.hardware.nixosModules.common-pc-ssd
    inputs.hardware.nixosModules.framework-amd-ai-300-series

    ./hardware-configuration.nix
    "${nixosModules}/common"
    "${nixosModules}/desktop/kde"
    "${nixosModules}/programs/steam"
  ];

  # Set hostname
  networking.hostName = hostname;

  # Remote Desktop (TV → Laptop via VNC/RDP) and Miracast (Laptop → TV)
  networking.firewall.allowedTCPPorts = [ 3389 5900 47984 47989 47990 48010 ];    # RDP, VNC, Sunshine
  networking.firewall.allowedUDPPorts = [ 7236 7250 47998 47999 48000 48002 48010 ];  # Miracast, Sunshine

  environment.systemPackages = with pkgs; [
    gnome-network-displays  # Miracast casting
    mkchromecast            # Cast video/screen to DLNA/Chromecast devices incl. Samsung TVs
  ];

  # Avahi for mDNS/device discovery (required by gnome-network-displays)
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  services.fwupd.enable = true;
  services.hardware.bolt.enable = true;

  # Xbox One wireless USB dongle support
  hardware.xone.enable = true;

  # Sunshine game streaming host (compatible with Steam Link and Moonlight clients)
  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true;
    openFirewall = true;
  };

  programs.nix-ld.enable = true;

  # Waydroid - run Android apps in a container
  virtualisation.waydroid.enable = true;

  # Ollama for local LLM with ROCm GPU acceleration
  services.ollama = {
    enable = true;
    package = pkgs.ollama-rocm;
    # GPU will be used once VRAM is increased in BIOS (UMA Frame Buffer)
  };

  services.logind.powerKey = "suspend";

  # ROCm support for AMD Radeon 890M (Ryzen AI 9 HX 370)
  systemd.tmpfiles.rules = [
    "L+ /opt/rocm/hip - - - - ${pkgs.rocmPackages.clr}"
    # Create /opt/amdgpu directory structure and symlink amdgpu.ids
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
  # HSA_OVERRIDE_GFX_VERSION=11.0.0 is needed for Radeon 890M (gfx1150/1151)
  # which isn't officially supported by ROCm yet
  environment.sessionVariables = {
    ROC_ENABLE_PRE_VEGA = "1";
    HSA_OVERRIDE_GFX_VERSION = "11.0.0";
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  system.stateVersion = "25.05";
}
