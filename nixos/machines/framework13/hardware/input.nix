{ pkgs, ... }:
{
  # Xbox One wireless USB dongle support. Temporarily disabled: the out-of-tree
  # xpad-noone module fails to build against the current kernel (a nixpkgs
  # module-signing regression). Re-enable once that's fixed upstream.
  # hardware.xone.enable = true;

  # XHC0 is the thunderbolt dock's USB controller (pci:0000:c3:00.0, same bus as NHI0/NHI1).
  # It must be enabled for keyboard/mouse through the dock to wake the system from S3.
  # The service checks current state and only toggles if disabled, so it's idempotent.
  systemd.services.enable-xhc0-wakeup = {
    description = "Enable XHC0 wakeup for thunderbolt dock keyboard/mouse";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.bash}/bin/bash -c 'grep -q \"XHC0.*disabled\" /proc/acpi/wakeup && echo XHC0 > /proc/acpi/wakeup || true'";
    };
  };

  # USB wakeup for the thunderbolt dock's keyboard/mouse.
  #
  # A USB device can only wake the system if every device in the chain up to the
  # host controller is armed as a wakeup source. The dock's keyboard/mouse sit
  # behind several internal hubs, so those hubs MUST have wakeup enabled or a
  # keypress/move won't propagate a remote-wakeup signal. (This is also why
  # plugging the dock in while asleep can wake the machine: the dock's hub
  # connect event fires on the already-armed XHC0 controller.)
  #
  # Root hubs (sysfs name "usbN", no dash) are excluded — their wakeup is owned
  # by the host controller's ACPI wakeup (XHC0 above), not power/wakeup. Only
  # intermediate/external hubs (name "N-M[...]") are matched.
  #
  # Storage (08), wireless (e0) and misc/AV (ef) stay disabled so an attached
  # drive/radio/audio device can't spuriously abort sleep.
  #
  # Rules re-fire on dock replug so re-enumerated devices are handled automatically.
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", ATTR{bDeviceClass}=="09", KERNEL=="*-*", ATTR{power/wakeup}="enabled"
    ACTION=="add", SUBSYSTEM=="usb", ATTR{bDeviceClass}=="08", ATTR{power/wakeup}="disabled"
    ACTION=="add", SUBSYSTEM=="usb", ATTR{bDeviceClass}=="e0", ATTR{power/wakeup}="disabled"
    ACTION=="add", SUBSYSTEM=="usb", ATTR{bDeviceClass}=="ef", ATTR{power/wakeup}="disabled"
    ACTION=="add", SUBSYSTEM=="usb", ATTR{bDeviceClass}=="03", ATTR{power/wakeup}="enabled"
  '';
}
