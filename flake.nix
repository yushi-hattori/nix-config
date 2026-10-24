{
  description = "yhattori's NixOS configuration (v2)";

  # Flake inputs. NOTE: the flake evaluator requires `inputs` to be a *literal*
  # attrset — an `import` (of individual files or a computed set) is rejected as
  # a lazy thunk. So specs live inline here, not in inputs/*.nix.
  inputs = {
    # primary package set (unstable); `stable` is nixpkgs-stable below
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # pinned stable channel, backs the stable-packages overlay (pkgs.stable.*)
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-26.05";

    # TEMP kernel pin. nixpkgs' linuxPackages_latest moved to 7.2.11, which
    # kernel-panics on this Framework 13 ~1 min after boot. This rev is the last
    # known-good snapshot (its linuxPackages_latest = 7.1.2, the kernel that boots
    # stable with working WiFi + DMS). Pinned to an exact rev so it never drifts;
    # intentionally does NOT follow nixpkgs. Drop once 7.2.x boots cleanly.
    nixpkgs-kernel.url = "github:nixos/nixpkgs/65179426c83bb3f6bc14898b42ea1c6f01d374b0";

    # per-user config
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Framework 13 AMD + common cpu/gpu/ssd profiles
    hardware.url = "github:nixos/nixos-hardware";

    # declarative flatpak (Zoom, Bambu Studio)
    nix-flatpak.url = "github:gmodena/nix-flatpak?ref=v0.6.0";

    # Google Antigravity agentic IDE (google-antigravity-cli via overlay)
    antigravity-nix = {
      url = "github:jacopone/antigravity-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Zen browser (twilight home module)
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # OpenChamber web UI for OpenCode (nixosModules.openchamber). Upstream HEAD
    # drifts (flake pins opencode v2.1.3 while packages/electron requires 2.1.4,
    # and the baked bun-deps/node-modules hashes are stale), so we override the
    # opencode input here and re-bake the hashes in the module itself (see
    # nixos/shared/services/openchamber.nix).
    openchamber = {
      url = "github:openchamber/openchamber";
      inputs.opencode.url = "github:anomalyco/opencode/v2.1.4";
    };

    # DankMaterialShell — desktop shell for niri (stable branch)
    dms = {
      url = "github:AvengeMedia/DankMaterialShell/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # dsearch — indexed filesystem search (backs DMS's launcher file search)
    dsearch = {
      url = "github:duxlabs-dev/dux-search";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, home-manager, ... }@inputs:
    let
      constants = import ./constants.nix;
      overlays = import ./overlays { inherit inputs; };
    in
    {
      nixosConfigurations.${constants.hostname} = nixpkgs.lib.nixosSystem {
        system = constants.system;
        specialArgs = { inherit inputs constants; };
        modules = [
          ./nixos/machines/${constants.hostname}
          {
            nixpkgs.config.allowUnfree = true;
            nixpkgs.overlays = [ overlays.openchamber overlays.xwayland-satellite-dark ];
          }
        ];
      };

      homeConfigurations."${constants.user.name}@${constants.hostname}" =
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            system = constants.system;
            config.allowUnfree = true;
            overlays = [
              overlays.stable-packages
              overlays.nmtui-go
              overlays.openchamber
              overlays.zellij-latest
              overlays.yazi-latest
              overlays.qtengine
              inputs.antigravity-nix.overlays.default
            ];
          };
          extraSpecialArgs = { inherit inputs constants; };
          modules = [ ./users/${constants.user.name} ];
        };
    };
}
