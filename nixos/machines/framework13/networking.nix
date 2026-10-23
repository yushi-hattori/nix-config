# networking — NetworkManager (iwd backend) + firewall.
#
# NetworkManager with the iwd WiFi backend (the self-managed wiphy quirk is
# handled automatically by the iwd module).
{ ... }:
{
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.backend = "iwd";
  networking.wireless.iwd.enable = true;

  networking.firewall.enable = true;
}
