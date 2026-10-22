# virt-manager — KVM/QEMU + virt-manager (Windows VM).
{ constants, pkgs, ... }:
{
  users.groups.libvirt = { };

  users.users.${constants.user.name}.extraGroups = [
    "libvirtd"
    "libvirt"
    "kvm"
  ];

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
    pkgs.freerdp
  ];

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
