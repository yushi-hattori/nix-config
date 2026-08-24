# Fusion 360 on NixOS (Windows VM + WinApps)

Fusion 360 has no Linux support and Wine/Bottles is unreliable, so it runs in a
Windows VM (KVM/QEMU) with WinApps making it launch as a seamless native window.

## Declarative (in `modules/nixos/common/default.nix`)
- `virtualisation.libvirtd` + `programs.virt-manager.enable`
- User groups: `libvirtd`, `libvirt` (WinApps checks literally for `libvirt`,
  which NixOS's libvirtd module doesn't create — declared via `users.groups.libvirt`),
  `kvm`
- `environment.sessionVariables.LIBVIRT_DEFAULT_URI = "qemu:///system"` — WinApps'
  scripts call bare `virsh`/`winapps` without exporting this from its own config
  file, so it must come from the session env or every VM lookup fails with
  "VM does not exist". **Requires a new login session (reboot/logout) to take effect.**
- `systemd.services.libvirt-default-network-autostart` — libvirt's `default`
  NAT network doesn't reliably come up active on boot; this force-starts +
  autostarts it so VMs don't fail with "network 'default' is not active".

## Manual / one-time (can't be made declarative — lives inside the Windows guest or holds a plaintext password)
- **VM**: named `tinyWin11`, built in virt-manager from a Tiny11 23H2 ISO
  (debloated Win11, no TPM/SecureBoot/MS-account requirements). 16GB RAM,
  8 vCPU, 80GB qcow2, Q35, UEFI (`code.fd`, not "secure"), TPM 2.0 emulated.
- **Inside Windows**: install VirtIO guest drivers, enable Remote Desktop,
  merge `~/winapps/oem/RDPApps.reg` (disables the RDP RemoteApp allowlist —
  without it every WinApps launch fails with `RAIL_EXEC_E_NOT_IN_ALLOWLIST`).
  Easiest way in: `xfreerdp /v:<vm-ip> /u:<user> /p:<pass> /drive:home,/home/yhattori /cert:ignore`,
  then browse to `\\tsclient\home\winapps\oem\RDPApps.reg` in Explorer.
- **`~/.config/winapps/winapps.conf`** (not in git — has a plaintext RDP
  password):
  ```
  WAFLAVOR="libvirt"
  VM_NAME="tinyWin11"
  LIBVIRT_DEFAULT_URI="qemu:///system"
  RDP_IP="<vm-ip>"          # find via: virsh net-dhcp-leases default
  RDP_USER="<windows-user>"
  RDP_PASS="<password>"
  APP_SCAN_TIMEOUT="180"     # default 60s is too short; first PowerShell
                             # cold-start in the VM can blow past it
  ```
- **Run the installer**: `LIBVIRT_DEFAULT_URI=qemu:///system nix-shell -p dialog --run "bash ~/winapps/setup.sh"`
  (or just `bash ~/winapps/setup.sh` after rebooting once the session var is live)
  → Install → Current User → Automatic. Creates `.desktop` launchers
  (including Fusion 360) in `~/.local/share/applications`.

## Gotchas hit along the way
- Windows (non-server) allows only one interactive session — if you RDP in
  manually (e.g. to merge the .reg file) without logging off cleanly,
  subsequent WinApps RDP attempts silently reconnect to that stale session
  and time out. If a WinApps step suddenly fails after previously working,
  just retry — it's often transient, no VM reboot needed.
