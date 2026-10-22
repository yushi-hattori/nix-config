# Boot loader — systemd-boot on the EFI system partition (/boot).
{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
}
