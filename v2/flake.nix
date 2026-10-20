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

    # per-user config
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Framework 13 AMD + common cpu/gpu/ssd profiles
    hardware.url = "github:nixos/nixos-hardware";

    # declarative flatpak (Zoom, Bambu Studio)
    nix-flatpak.url = "github:gmodena/nix-flatpak?ref=v0.6.0";

    # opencode AI coding agent (+ opencode-latest overlay)
    opencode.url = "github:dan-online/opencode-nix";

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

    # OpenChamber web UI for OpenCode (nixosModules.openchamber)
    openchamber.url = "github:openchamber/openchamber";

    # DankMaterialShell — desktop shell for niri (stable branch)
    dms = {
      url = "github:AvengeMedia/DankMaterialShell/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # niri compositor via niri-flake (structured programs.niri.settings)
    niri = {
      url = "github:sodiboo/niri-flake";
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
          { nixpkgs.overlays = [ overlays.libdisplay-info ]; }
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
              inputs.opencode.overlays.default
              overlays.opencode-latest
              overlays.zellij-latest
              overlays.yazi-latest
              inputs.antigravity-nix.overlays.default
              overlays.libdisplay-info
            ];
          };
          extraSpecialArgs = { inherit inputs constants; };
          modules = [ ./users/${constants.user.name} ];
        };
    };
}
