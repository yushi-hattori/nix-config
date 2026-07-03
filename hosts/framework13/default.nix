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
    "${nixosModules}/desktop/niri"
    "${nixosModules}/services/greetd"
    "${nixosModules}/services/printing"
    "${nixosModules}/programs/steam"
    "${nixosModules}/programs/bambu-studio"
    "${nixosModules}/services/ollama"
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
  ];
  networking.firewall.allowedUDPPorts = [
    7236
    7250
    47998
    47999
    48000
    48002
    48010
  ];

  environment.systemPackages = with pkgs; [
    gnome-network-displays
    mkchromecast
    bolt
    pciutils
    usbutils
  ];

  # Avahi for mDNS/device discovery
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  services.fwupd.enable = true;
  services.hardware.bolt.enable = true;

  # Xbox One wireless USB dongle support (Restored from pre-problem state)
  hardware.xone.enable = true;

  # Hibernation fix (User requested to keep)
  systemd.sleep.settings.Sleep = {
    AllowHibernation = "no";
    AllowSuspendThenHibernate = "no";
    AllowHybridSleep = "no";
  };

  # ALL MAJOR KERNEL WORKAROUNDS REMOVED
  boot.kernelParams = [ "rtc_cmos.use_acpi_alarm=1" ];

  # Sunshine game streaming host
  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true;
    openFirewall = true;
  };

  programs.kdeconnect.enable = true;

  # Waydroid - run Android apps in a container
  virtualisation.waydroid.enable = true;

  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      libglvnd
      libx11
      libxext
      stdenv.cc.cc.lib
      zlib
    ];
  };

  # USB wakeup: allow keyboards/mice to wake from sleep, block everything else.
  # XHC0 ACPI wakeup is left enabled (we no longer toggle it off) so HID devices
  # can wake the system. Individual device wakeup is managed by udev so non-HID
  # devices (storage, hubs, etc.) don't cause spontaneous wakeups.
  # Rules re-fire on every add event, so replug of a thunderbolt dock
  # automatically re-enables wakeup for the re-enumerated HID devices.
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", ATTR{power/wakeup}="disabled"
    ACTION=="add", SUBSYSTEM=="usb", ATTR{bDeviceClass}=="03", ATTR{power/wakeup}="enabled"
  '';

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

  # REVERTED: StateVersion 25.11 is a major change that affects security policies.
  system.stateVersion = "25.11";
}
