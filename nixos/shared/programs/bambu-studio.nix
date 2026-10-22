# bambu-studio — udev rules for the Bambu Lab printer (USB + serial).
{ ... }:
{
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTRS{idVendor}=="2b04", ATTRS{idProduct}=="b001", TAG+="uaccess"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="2b04", ATTRS{idProduct}=="0001", TAG+="uaccess"

    KERNEL=="ttyUSB*", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="7523", MODE="0660", GROUP="dialout", TAG+="uaccess"
  '';

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
}
