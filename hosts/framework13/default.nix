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
    "${nixosModules}/services/auto-timezone"
    "${nixosModules}/services/printing"
    "${nixosModules}/programs/steam"
    "${nixosModules}/programs/bambu-studio"
    "${nixosModules}/programs/virt-manager"
    "${nixosModules}/services/ollama"
    "${nixosModules}/services/tlp"
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
    "pm_debug_messages" # Extra suspend/resume logging to diagnose future s2idle hangs
    # Detect (but don't panic on) CPU lockups during the silent s2idle hangs that have
    # required hard resets. Log-only: without the *_panic sysctls, nmi_watchdog just
    # prints a stack trace on a stuck CPU, so this can't itself cause an unwanted reboot.
    "nmi_watchdog=1"
  ];

  # Safety net for a marginal WiFi card. A bad card/slot contact can make the
  # driver fault during probe and trigger an AMD data-fabric sync flood that
  # resets the machine in a loop ~5s into boot (reset reason 0x08000800), with no
  # way back into the OS. This specialisation adds a systemd-boot entry
  # ("... (no-wifi)") that blacklists both in-tree WiFi drivers — mt7925e (the
  # RZ717/MT7925) and ath12k (the QCNCM865) — so if the normal entry is looping we
  # can still boot and reseat/replace the card. Normal boots are unaffected and
  # keep WiFi. Note: this only helps because the fault is triggered by the driver
  # probing the card — a fault during PCIe enumeration itself can't be prevented
  # from software.
  specialisation.no-wifi.configuration = {
    system.nixos.tags = [ "no-wifi" ];
    boot.blacklistedKernelModules = [
      "mt7925e" "mt7925_common" "mt792x_lib" "mt76_connac_lib" "mt76"
      "ath12k_wifi7" "ath12k"
    ];
    boot.extraModprobeConfig = ''
      install mt7925e /bin/false
      install mt7925_common /bin/false
      install mt792x_lib /bin/false
      install mt76_connac_lib /bin/false
      install mt76 /bin/false
      install ath12k_wifi7 /bin/false
      install ath12k /bin/false
    '';
  };

  # MT7925 (RZ717) power-management workaround. The card wedges in a low-power
  # PCIe state across suspend/resume: on wake it either faults the AMD data
  # fabric (sync flood reset, reason 0x08000800) or is left unresponsive so the
  # next probe fails ("mt7925e: driver own failed", error -5) until a full
  # power-off. Disabling the card's ASPM keeps it out of the L1.2 state that
  # leaves it stuck. See https://community.frame.work/t/83690
  boot.extraModprobeConfig = ''
    options mt7925e disable_aspm=1
  '';

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

  # USB wakeup for the thunderbolt dock's keyboard/mouse.
  #
  # A USB device can only wake the system if every device in the chain up to the
  # host controller is armed as a wakeup source. The dock's keyboard/mouse sit
  # behind several internal hubs, so those hubs MUST have wakeup enabled or a
  # keypress/move won't propagate a remote-wakeup signal. (This is also why
  # plugging the dock in while asleep can wake the machine: the dock's hub
  # connect event fires on the already-armed XHC0 controller.)
  #
  # Root hubs (sysfs name "usbN", no dash) are excluded — their wakeup is owned
  # by the host controller's ACPI wakeup (XHC0 above), not power/wakeup. Only
  # intermediate/external hubs (name "N-M[...]") are matched.
  #
  # Storage (08), wireless (e0) and misc/AV (ef) stay disabled so an attached
  # drive/radio/audio device can't spuriously abort sleep.
  #
  # Rules re-fire on dock replug so re-enumerated devices are handled automatically.
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", ATTR{bDeviceClass}=="09", KERNEL=="*-*", ATTR{power/wakeup}="enabled"
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
