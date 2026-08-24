{ userConfig, pkgs, ... }:
{
  # KVM/QEMU + virt-manager, used to run a Windows VM (see
  # notes/fusion360-vm-setup.md for the Fusion 360 / WinApps setup built on
  # top of this).

  # WinApps checks for a group literally named "libvirt" (not "libvirtd",
  # which is what NixOS's virtualisation.libvirtd module creates), so it
  # has to be declared explicitly here.
  users.groups.libvirt = { };

  users.users.${userConfig.name}.extraGroups = [
    "libvirtd"
    "libvirt"
    "kvm"
  ];

  # WinApps' scripts call bare `virsh`/`winapps` without exporting this from
  # its own config file, so it must come from the session env or every VM
  # lookup fails with "VM does not exist". Requires a new login session
  # (reboot/logout) to take effect.
  environment.sessionVariables.LIBVIRT_DEFAULT_URI = "qemu:///system";

  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      swtpm.enable = true;
    };
  };
  programs.virt-manager.enable = true;

  environment.systemPackages = [
    pkgs.freerdp # Required by WinApps for seamless Windows app streaming
  ];

  # libvirt's "default" NAT network doesn't always come up active on boot.
  # This ensures it's marked autostart and active so VMs can start without
  # a manual `virsh net-start default`. Idempotent, like enable-xhc0-wakeup.
  systemd.services.libvirt-default-network-autostart = {
    description = "Ensure libvirt's default NAT network is active and autostarted";
    after = [ "libvirtd.service" ];
    wants = [ "libvirtd.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.bash}/bin/bash -c '${pkgs.libvirt}/bin/virsh net-autostart default; ${pkgs.libvirt}/bin/virsh net-start default || true'";
    };
  };
}
