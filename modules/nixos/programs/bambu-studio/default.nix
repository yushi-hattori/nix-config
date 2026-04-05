{ pkgs, ... }:
{
  # Enable udev rules for Bambu Studio to communicate with the printer via USB
  # We provide manual rules here to ensure they are available even for the Flatpak version
  services.udev.extraRules = ''
    # Bambu Lab printer rules
    SUBSYSTEM=="usb", ATTRS{idVendor}=="2b04", ATTRS{idProduct}=="b001", TAG+="uaccess"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="2b04", ATTRS{idProduct}=="0001", TAG+="uaccess"

    # Serial/CH340 rules (often used by printer mainboards)
    KERNEL=="ttyUSB*", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="7523", MODE="0660", GROUP="dialout", TAG+="uaccess"
  '';

  # Avahi is already enabled in common/default.nix, but we ensure it's configured for discovery
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
}
