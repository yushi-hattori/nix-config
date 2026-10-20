{
  description = "yhattori's NixOS configuration (v2)";

  inputs = import ./inputs;

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
        modules = [ ./nixos/machines/${constants.hostname} ];
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
            ];
          };
          extraSpecialArgs = { inherit inputs constants; };
          modules = [ ./users/${constants.user.name} ];
        };
    };
}
