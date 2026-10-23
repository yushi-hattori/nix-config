# Boot loader — systemd-boot on the EFI system partition (/boot).
{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 10;
  # Keep the boot menu short. Without this every rebuild adds a systemd-boot
  # entry and the auto-detected "Windows Boot Manager" entry gets buried
  # hundreds of rows down. Older generations are pruned automatically.
  boot.loader.systemd-boot.configurationLimit = 10;
}
