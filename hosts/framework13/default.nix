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
    "${nixosModules}/services/printing"
    "${nixosModules}/programs/steam"
    "${nixosModules}/programs/bambu-studio"
    "${nixosModules}/services/ollama"
  ];

  # Set hostname
  networking.hostName = hostname;

  # Login flow (no display manager): autologin on tty1 straight into niri, which
  # immediately spawns hyprlock as the real gate. hyprlock runs the password
  # (PAM) and fingerprint (fprintd over D-Bus) checks concurrently, so either
  # one unlocks at any time — the macOS-style behavior greetd/GDM couldn't give.
  # niri is launched from the login shell (see programs.zsh.profileExtra in the
  # zsh home-manager module); getty just needs to log the user in on tty1.
  services.getty.autologinUser = "yhattori";

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

  # Kernel parameters to fix s2idle suspend freezes on Framework 13 AMD + WD NVMe
  boot.kernelParams = [
    "nvme_core.default_ps_max_latency_us=0" # Fix WD_BLACK SN7100 DRAM-less NVMe APST suspend hang
  ];

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

  # XHC0 is the thunderbolt dock's USB controller (pci:0000:c3:00.0, same bus as NHI0/NHI1).
  # It must be enabled for keyboard/mouse through the dock to wake the system from S3.
  # The service checks current state and only toggles if disabled, so it's idempotent.
  systemd.services.enable-xhc0-wakeup = {
    description = "Enable XHC0 wakeup for thunderbolt dock keyboard/mouse";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.bash}/bin/bash -c 'grep -q \"XHC0.*disabled\" /proc/acpi/wakeup && echo XHC0 > /proc/acpi/wakeup || true'";
    };
  };

  # USB wakeup: enable for input devices (HID class=03), disable for hubs/storage/BT/misc
  # to prevent spontaneous sleep aborts/wakeups.
  # Rules re-fire on dock replug so re-enumerated devices are handled automatically.
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", ATTR{bDeviceClass}=="09", ATTR{power/wakeup}="disabled"
    ACTION=="add", SUBSYSTEM=="usb", ATTR{bDeviceClass}=="08", ATTR{power/wakeup}="disabled"
    ACTION=="add", SUBSYSTEM=="usb", ATTR{bDeviceClass}=="e0", ATTR{power/wakeup}="disabled"
    ACTION=="add", SUBSYSTEM=="usb", ATTR{bDeviceClass}=="ef", ATTR{power/wakeup}="disabled"
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
