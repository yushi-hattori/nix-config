{ config, pkgs, inputs, constants, ... }:
let
  # TEMP: pin the kernel to the last known-good snapshot (7.1.2). nixpkgs'
  # current linuxPackages_latest is 7.2.11, which kernel-panics ~1 min after boot
  # on this machine. We still want a recent kernel for the Strix Point iGPU
  # amdgpu driver (the default LTS breaks DMS/quickshell rendering), so instead of
  # dropping to LTS we source linuxPackages_latest (= 7.1.2) from the pinned
  # nixpkgs-kernel input. The rest of the system stays on the bumped nixpkgs.
  # Revert (back to `pkgs.linuxPackages_latest`) once 7.2.x boots cleanly.
  kernelPkgs = import inputs.nixpkgs-kernel {
    system = constants.system;
    config.allowUnfree = true;
  };
in
{
  boot.kernelPackages = kernelPkgs.linuxPackages_latest;

  # Virtual camera (for OBS) — disabled: v4l2loopback 0.15.4 in current nixpkgs
  # installs a conflicting modules.builtin.alias.bin. Re-enable once fixed.
  # boot.kernelModules = [ "v4l2loopback" ];
  # boot.extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];

  # Kernel parameters to fix s2idle suspend freezes on Framework 13 AMD + WD NVMe
  boot.kernelParams = [
    "nvme_core.default_ps_max_latency_us=0" # Fix WD_BLACK SN7100 DRAM-less NVMe APST suspend hang
    "pm_debug_messages" # Extra suspend/resume logging to diagnose future s2idle hangs
    # Detect (but don't panic on) CPU lockups during the silent s2idle hangs that have
    # required hard resets. Log-only: without the *_panic sysctls, nmi_watchdog just
    # prints a stack trace on a stuck CPU, so this can't itself cause an unwanted reboot.
    "nmi_watchdog=1"
  ];

  # NOTE: the amdgpu ISM dc_lock deadlock backport (CVE-2026-68364) was dropped
  # here — it was a temporary fix for kernel 7.1.0-7.1.5, now upstream, and it
  # no longer applies to the current kernel.

  # MT7925 (RZ717) power-management workaround. The card wedges in a low-power
  # PCIe state across suspend/resume: on wake it either faults the AMD data
  # fabric (sync flood reset, reason 0x08000800) or is left unresponsive so the
  # next probe fails ("mt7925e: driver own failed", error -5) until a full
  # power-off. Disabling the card's ASPM keeps it out of the L1.2 state that
  # leaves it stuck. See https://community.frame.work/t/83690
  boot.extraModprobeConfig = ''
    options mt7925e disable_aspm=1
  '';

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
}
