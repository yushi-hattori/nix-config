{ ... }:
{
  # Running the real power-profiles-daemon alongside TLP is a hard NixOS
  # assertion failure (services.power-profiles-daemon module forbids it
  # outright), so TLP's own "tlp.pd" is the only way to expose a
  # ppd-compatible DBus interface. Upstream tlp-pd omits the backward-compat
  # "Driver" property key that real power-profiles-daemon emits alongside
  # CpuDriver/PlatformDriver, which makes strict clients like wayle see 0
  # available profiles. Patch it in here.
  nixpkgs.overlays = [
    (final: prev: {
      tlp-pd = prev.tlp-pd.overrideAttrs (old: {
        postPatch = (old.postPatch or "") + ''
          substituteInPlace tlp-pd.in --replace-fail \
            '{"Profile": f"{profile}", "CpuDriver": "tlp", "PlatformDriver": "tlp"}' \
            '{"Profile": f"{profile}", "CpuDriver": "tlp", "PlatformDriver": "tlp", "Driver": "multiple"}'
        '';
      });
    })
  ];

  # Set TLP power profile
  services = {
    tlp = {
      enable = true;
      pd.enable = true;

      settings = {
        CPU_SCALING_GOVERNOR_ON_AC = "schedutil";
        CPU_SCALING_GOVERNOR_ON_BAT = "schedutil";
        CPU_BOOST_ON_AC = 1;
        CPU_BOOST_ON_BAT = 0;
        CPU_SCALING_MIN_FREQ_ON_BAT = 400000;
        CPU_SCALING_MAX_FREQ_ON_BAT = 3000000;

        CPU_ENERGY_PERF_POLICY_ON_AC = "balance_power";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

        PLATFORM_PROFILE_ON_AC = "low-power";
        PLATFORM_PROFILE_ON_BAT = "performance";

        USB_EXCLUDE_BTUSB = 1;
        USB_AUTOSUSPEND = 1;
        USB_AUTOSUSPEND_ON_AC = 0;
        USB_AUTOSUSPEND_DISABLE_ON_SHUTDOWN = 1;

        AMDGPU_ABM_LEVEL_ON_AC = 0;
        AMDGPU_ABM_LEVEL_ON_BAT = 3;

        DISK_IOSCHED = [ "none" ];
        DISK_APM_LEVEL_ON_BAT = "1 1";

        SATA_LINKPWR_ON_BAT = "min_power";
        PCIE_ASPM_ON_AC = "performance";
        PCIE_ASPM_ON_BAT = "powersupersave";

        RUNTIME_PM_ON_AC = "on";
        RUNTIME_PM_ON_BAT = "auto";

        WIFI_PWR_ON_BAT = "on";

        SOUND_POWER_SAVE_ON_BAT = 1;
        SOUND_POWER_SAVE_CONTROLLER = "Y";

        # Battery charge thresholds for on-road usage
        START_CHARGE_THRESH_BAT0 = 85;
        STOP_CHARGE_THRESH_BAT0 = 90;
      };
    };

    power-profiles-daemon.enable = false;
  };
}
