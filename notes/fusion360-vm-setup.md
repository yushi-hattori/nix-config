# Fusion 360 on NixOS (Windows VM)

Fusion 360 has no Linux support and Wine/Bottles is unreliable, so it runs in a
Windows VM (KVM/QEMU). Two display methods documented here:

- **Method A — Moonlight/Sunshine (preferred):** Stream Fusion 360 from Sunshine
  running *inside* the VM, viewed via Moonlight on the Linux host. Low latency,
  GPU-accelerated H.265 display, full DirectX support.
- **Method B — WinApps/RDP (legacy):** Seamless-window mode via FreeRDP. Works
  but is slower and renders over RDP without GPU acceleration.

---

## NixOS host (declarative)

- `virtualisation.libvirtd` + `programs.virt-manager.enable` — in
  `modules/nixos/programs/virt-manager`
- User groups: `libvirtd`, `libvirt`, `kvm`
- `environment.sessionVariables.LIBVIRT_DEFAULT_URI = "qemu:///system"`
- `systemd.services.libvirt-default-network-autostart` — ensures libvirt's
  `default` NAT network is up on boot
- `moonlight-qt` installed via `modules/home-manager/programs/moonlight`
  (framework13 host only)
- Firewall ports for Sunshine (from the *host*'s Sunshine service, kept open):
  TCP 47984, 47989, 47990, 48010 / UDP 47998, 47999, 48000, 48002, 48010

---

## VM spec

Named `tinyWin11` — built from Tiny11 23H2 ISO (debloated Win11, no
TPM/SecureBoot/MS-account). 16 GB RAM, 8 vCPU, 80 GB qcow2, Q35, UEFI
(`code.fd`, not "secure"), TPM 2.0 emulated (swtpm).

---

## Method A — Moonlight/Sunshine setup (preferred)

### One-time setup inside the Windows VM

1. **Start the VM** in virt-manager and open its display.

2. **Find the VM's IP** from the host:
   ```
   virsh net-dhcp-leases default
   ```

3. **Download Sunshine for Windows** inside the VM:
   https://github.com/LizardByte/Sunshine/releases
   → grab the `.exe` installer (e.g. `sunshine-windows-installer.exe`)

4. **Install Sunshine** — run the installer, accept defaults.
   - It installs as a Windows service and opens a web UI at https://localhost:47990
   - On first launch Windows Firewall will prompt → **Allow access** (both private
     and public so the libvirt NAT bridge can reach it)

5. **Open Sunshine's web UI** in the VM's browser:
   https://localhost:47990
   - Set a username/password on first run
   - Go to **Configuration → General** — no changes needed for basic use
   - Go to **Applications** → **Add New**:
     - **Application Name:** `Fusion 360`
     - **Command:** leave blank to stream the full desktop (easiest), or set to
       `"C:\Users\<user>\AppData\Local\Autodesk\webdeploy\production\<hash>\FusionLauncher.exe"`
       (find exact path: run `where /r %LOCALAPPDATA% Fusion360.exe` in CMD)
     - Leave other fields default → **Save**

6. **Configure Windows Firewall** (if Sunshine didn't do it automatically):
   - Open Windows Defender Firewall → Advanced Settings → Inbound Rules → New Rule
   - Port → TCP: 47984, 47989, 47990, 48010 → Allow → All profiles → Name: "Sunshine"
   - Repeat for UDP: 47998, 47999, 48000, 48002, 48010

### Pairing Moonlight with the VM

1. On the **Linux host**, open Moonlight:
   ```
   moonlight
   ```

2. Click **Add PC** and enter the VM's IP (e.g. `192.168.122.x`).

3. Moonlight will show a PIN pairing dialog — enter the 4-digit PIN in Sunshine's
   web UI (Pin tab at https://192.168.122.x:47990 from the host browser, or
   localhost:47990 inside the VM).

4. The VM now appears in Moonlight. Click it → **Fusion 360** (or **Desktop** for
   the full desktop).

### Reconnecting after VM restarts

- Sunshine starts automatically as a Windows service on VM boot.
- The VM IP may change on each start → check with `virsh net-dhcp-leases default`
  and update Moonlight if needed.
- **Tip:** Set a static DHCP lease to avoid IP changes:
  ```
  # Find the VM's MAC address first:
  virsh domiflist tinyWin11

  # Then pin it to 192.168.122.10:
  virsh net-update default add ip-dhcp-host \
    '<host mac="<VM-MAC>" ip="192.168.122.10"/>' \
    --live --config
  ```

### Moonlight streaming settings (recommended for CAD)

In Moonlight → Settings:
- **Resolution:** Match your display (e.g. 2560×1600)
- **FPS:** 60
- **Bitrate:** 20–30 Mbps (local loopback/NAT, so go high)
- **Video codec:** H.265 (HEVC) — uses AMD VCE hardware decode on the host
- **Hardware decoding:** On

---

## Method B — WinApps/RDP (legacy, kept for reference)

### Inside Windows (one-time)
- Install VirtIO guest drivers
- Enable Remote Desktop
- Merge `~/winapps/oem/RDPApps.reg` (disables RDP RemoteApp allowlist):
  ```
  xfreerdp /v:<vm-ip> /u:<user> /p:<pass> /drive:home,/home/yhattori /cert:ignore
  ```
  Browse to `\\tsclient\home\winapps\oem\RDPApps.reg` in Explorer → merge it.

### `~/.config/winapps/winapps.conf` (not in git — contains plaintext password)
```
WAFLAVOR="libvirt"
VM_NAME="tinyWin11"
LIBVIRT_DEFAULT_URI="qemu:///system"
RDP_IP="<vm-ip>"          # virsh net-dhcp-leases default
RDP_USER="<windows-user>"
RDP_PASS="<password>"
APP_SCAN_TIMEOUT="180"    # default 60 is too short; first PowerShell cold-start blows past it
```

### Run the WinApps installer
```
LIBVIRT_DEFAULT_URI=qemu:///system nix-shell -p dialog --run "bash ~/winapps/setup.sh"
```
→ Install → Current User → Automatic. Creates `.desktop` launchers in
`~/.local/share/applications`.

---

## Gotchas

- **WinApps one-session limit:** Windows (non-server) allows only one interactive
  session. If you RDP in manually without logging off cleanly, subsequent WinApps
  attempts silently reconnect to the stale session and time out. Just retry — it's
  transient, no VM reboot needed.
- **Moonlight VM IP changes:** Check `virsh net-dhcp-leases default` after each
  VM start if you haven't set a static DHCP lease.
- **Sunshine pairing is per-install:** If you reinstall Sunshine or restore a VM
  snapshot, you'll need to re-pair from Moonlight.
- **Windows Firewall:** If Moonlight can't connect, check that Windows Firewall
  isn't blocking Sunshine's ports (common after Windows updates reset rules).
