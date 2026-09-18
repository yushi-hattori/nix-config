# nix-config

NixOS + Home Manager configuration for my Framework 13 (AMD), managed via [Nix Flakes](https://nixos.wiki/wiki/Flakes).

Single machine, single user. Desktop is [niri](https://github.com/niri-wm/niri) (scrollable-tiling Wayland compositor).

## Structure

- `flake.nix` — flake inputs/outputs for the NixOS system and Home Manager configs.
- `hosts/framework13/` — the NixOS system configuration for this machine (hardware, boot, system services).
- `home/yhattori/framework13/` — the Home Manager configuration for this machine/user.
- `modules/nixos/` — reusable NixOS modules, grouped as `common/`, `desktop/`, `programs/`, `services/`.
- `modules/home-manager/` — reusable Home Manager modules, grouped as `common/`, `desktop/`, `programs/`, `services/`, `misc/`, `scripts/`.
- `overlays/` — custom nixpkgs overlays (e.g. pulling select packages from the stable channel).
- `files/` — static assets referenced by modules (avatar image).
- `notes/` — freeform notes tied to the WinApps/Fusion 360 VM setup.

A module only takes effect if it's listed in the `imports` of `hosts/framework13/default.nix` (NixOS) or `home/yhattori/framework13/default.nix` → `modules/home-manager/common/default.nix` (Home Manager). A file existing under `modules/` doesn't mean it's active — check the relevant `imports` list.

### Key inputs

- **nixpkgs** — `nixos-unstable`.
- **nixpkgs-stable** — pinned stable channel, used selectively via the `stable-packages` overlay.
- **home-manager**, **hardware** (nixos-hardware profiles for this Framework board), **catppuccin** (theming), **nix-flatpak**.
- A handful of small flakes for specific tools: `claude-code`, `opencode`, `antigravity-nix`, `zen-browser`, `walker`, `herdr`, `nirinit` (niri session save/restore).

## Usage

```sh
# Rebuild the NixOS system
sudo nixos-rebuild switch --flake .#framework13

# Rebuild the Home Manager environment
home-manager switch --flake .#yhattori@framework13 -b backup

# Update flake inputs
nix flake update

# Garbage collect old generations
nix-collect-garbage -d
```

## Notable design points

- **No display manager.** `getty` autologs in on tty1, which launches `niri-session` from the zsh login shell (`programs.zsh.profileExtra`). `hyprlock` spawns immediately as the real lock/login gate, checking password (PAM) and fingerprint (fprintd over D-Bus) concurrently.
- **Monitor layout is owned by `kanshi`** (`modules/home-manager/services/kanshi`), which switches between docked/clamshell/undocked profiles based on what's connected. niri's own `config.kdl` intentionally does not declare static `output` blocks, to avoid the two fighting over the same outputs.
- **Docker runs rootless only** (`virtualisation.docker.rootless`) — no system-wide daemon, no `docker` group.
- **WinApps** (`home/yhattori/framework13/winapps.nix`) runs a Windows 11 VM (via `virt-manager`/libvirt) for Fusion 360, RDP'd in through gamescope to work around a niri/xwayland-satellite RAIL-rendering limitation. See `notes/fusion360-vm-setup.md`.
- **Ollama** runs locally with the Vulkan backend against the Framework's Radeon 890M iGPU, fronted by Open WebUI.
- **Known issue — suspend/resume with the HP Thunderbolt Dock G2 is unreliable.** On `s2idle` the dock's Thunderbolt link drops (`failed to reach state TB_PORT_UP` / `lost during suspend, disconnecting`) and the dock's USB controller is hot-removed via `pciehp` (with a `pci_disable_device` WARNING); occasionally the resume deadlocks entirely and the machine wakes to a black screen (see `journalctl -b -1` ending at `PM: suspend entry` with no resume). This matches the known Framework + HP Dock G2 bug. Possible future mitigations to try (one at a time): `pcie_aspm=off`, `thunderbolt.host_reset=false`, or simply not suspending while docked. Separately, after a hard reset the Intel AX210 can fail to probe (`iwlwifi: HW_REV=0xFFFFFFFF, PCI issues?` / `probe failed with error -5`); a full power-off (not a warm reboot) clears it.

## License

MIT.
