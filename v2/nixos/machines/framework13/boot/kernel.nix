{
  # Kernel parameters to fix s2idle suspend freezes on Framework 13 AMD + WD NVMe
  boot.kernelParams = [
    "nvme_core.default_ps_max_latency_us=0" # Fix WD_BLACK SN7100 DRAM-less NVMe APST suspend hang
    "pm_debug_messages" # Extra suspend/resume logging to diagnose future s2idle hangs
    # Detect (but don't panic on) CPU lockups during the silent s2idle hangs that have
    # required hard resets. Log-only: without the *_panic sysctls, nmi_watchdog just
    # prints a stack trace on a stuck CPU, so this can't itself cause an unwanted reboot.
    "nmi_watchdog=1"
  ];

  # Backport of the upstream amdgpu ISM dc_lock deadlock fix (CVE-2026-68364).
  # Our 2026-07-01 nixpkgs lock gives linuxPackages_latest = 7.1.2, which sits
  # inside the 7.1.0-7.1.5 window where amdgpu_dm_ism_disable() holds dc_lock
  # while waiting on ISM delayed work that also takes dc_lock -> ABBA deadlock
  # that hard-freezes the machine on s2idle (the journal stops dead at
  # "PM: suspend entry (s2idle)" with no resume, no panic, recovery only by cold
  # restart). Triggers especially when video was playing at suspend time.
  # Fixed upstream in stable 7.1.6 / mainline 7.2-rc1. We vendor the single
  # stable backport commit (95776812e6b8) so the rest of the pinned lock stays
  # frozen -> a clean A/B test of just this one change.
  # TODO: drop this once the pinned kernel is >= 7.1.6 (e.g. after a flake update).
  boot.kernelPatches = [
    {
      name = "amdgpu-ism-dc-lock-deadlock-fix";
      patch = ./patches/amdgpu-ism-dc-lock-deadlock-fix.patch;
    }
  ];

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
