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
    "${nixosModules}/programs/bambu-studio"
    "${nixosModules}/services/tlp"
  ];

  # Set hostname
  networking.hostName = hostname;

  # Remote Desktop (TV → Laptop via VNC/RDP) and Miracast (Laptop → TV)
  networking.firewall.allowedTCPPorts = [
    3389
    5900
    47984
    47989
    47990
    48010
  ]; # RDP, VNC, Sunshine
  networking.firewall.allowedUDPPorts = [
    7236
    7250
    47998
    47999
    48000
    48002
    48010
  ]; # Miracast, Sunshine

  environment.systemPackages = with pkgs; [
    gnome-network-displays # Miracast casting
    mkchromecast # Cast video/screen to DLNA/Chromecast devices incl. Samsung TVs
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
  services.logind.settings.Login.HandlePowerKey = "suspend";

  systemd.sleep.settings.Sleep = {
    AllowHibernation = "no";
    AllowSuspendThenHibernate = "no";
    AllowHybridSleep = "no";
  };

  boot.kernelParams = [
    "nvme.noacpi=1" # Fixes some NVMe resume issues
    "amdgpu.abmlevel=0" # Disables adaptive backlight management to avoid resume hangs
    "rtc_cmos.use_acpi_alarm=1" # Helps with s2idle resume reliability
    "mem_sleep_default=s2idle" # Ensure system uses modern standby
    "nvme_core.default_ps_max_latency_us=0" # Prevents NVMe from entering states it can't wake from
    "amd_iommu=off" # Fixes hard freezes on resume for Strix Point
    "amdgpu.dcdebugmask=0x10" # Disables some power gating that causes resume hangs
    "amdgpu.gpu_recovery=1" # Try to recover the GPU if it hangs on wake
    "amdgpu.sg_display=0" # Fixes some black screen issues on newer AMD GPUs
    "amdgpu.dcn_ip_res=0" # Prevents display core reset hangs on Strix Point
    "amdgpu.psr=0" # Disables Panel Self Refresh (common cause of wake freezes)
    "mt7921e.disable_aspm=y" # Fixes RZ616 Wi-Fi card causing sleep freezes
    "pcie_aspm=off" # Disables PCIe active state power management globally
  ];

  boot.initrd.kernelModules = [ "i2c_hid_acpi" ]; # Ensure trackpad driver is loaded early

  # Sunshine game streaming host (compatible with Steam Link and Moonlight clients)
  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true;
    openFirewall = true;
  };

  programs.nix-ld.enable = true;
  programs.kdeconnect.enable = true;

  # Waydroid - run Android apps in a container
  virtualisation.waydroid.enable = true;

  # Ollama for local LLM with ROCm GPU acceleration
  services.ollama = {
    enable = true;
    package = pkgs.ollama-rocm;
    # GPU will be used once VRAM is increased in BIOS (UMA Frame Buffer)
  };

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
    HSA_OVERRIDE_GFX_VERSION = "11.0.2";
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  system.stateVersion = "25.11";
}
