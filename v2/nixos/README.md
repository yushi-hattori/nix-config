# nixos/

System-wide (NixOS) configuration.

- `shared/` — machine-agnostic modules (desktop, services, programs, system).
- `machines/<host>/` — machine-specific config; each host imports the shared modules it needs plus its own hardware, boot, power, and networking.
