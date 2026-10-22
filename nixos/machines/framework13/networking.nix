# networking — NetworkManager (iwd backend) + firewall.
#
# NetworkManager with the iwd WiFi backend (the self-managed wiphy quirk is
# handled automatically by the iwd module). Firewall opens the kdeconnect
# port range.
{ ... }:
{
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.backend = "iwd";
  networking.wireless.iwd.enable = true;

  # For kdeconnect
  networking.firewall = {
    enable = true;
    allowedTCPPortRanges = [
      {
        from = 1714;
        to = 1764;
      }
    ];
    allowedUDPPortRanges = [
      {
        from = 1714;
        to = 1764;
      }
    ];
  };
}
