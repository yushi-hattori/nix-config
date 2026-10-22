# nix-config (v2)

Declarative NixOS + home-manager configuration.

## Structure

```
flake.nix             entrypoint (inputs + outputs)
constants.nix         shared values (system, hostname, user info, stateVersion)
inputs/               flake inputs, one file per input (auto-imported)
nixos/                system-wide configuration (NixOS)
  shared/             modules reusable across all machines
  machines/<host>/    per-machine config (hardware, boot, power, networking)
users/<user>/         per-user configuration (home-manager)
```

- **`nixos/`** is machine-scoped: `shared/` holds reusable modules, `machines/<host>/` holds what's unique to each box.
- **`users/<user>/`** is user-scoped: one folder per user, containing their home-manager config.

Every category is a folder with a `default.nix` that only lists imports, plus one leaf file per concern.

## Usage

```sh
# system
sudo nixos-rebuild switch --flake .#framework13

# home-manager
home-manager switch --flake .#yhattori@framework13
```
