{ pkgs, ... }:
{
  # Moonlight game streaming client — used to connect to the Sunshine instance
  # running inside the tinyWin11 QEMU VM (see notes/fusion360-vm-setup.md).
  # This gives GPU-accelerated, low-latency access to Fusion 360 without the
  # CPU overhead and display artifacts of FreeRDP/WinApps.
  home.packages = [ pkgs.moonlight-qt ];
}
