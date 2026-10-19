{
  description = "yhattori's NixOS configuration (v2)";

  inputs = import ./inputs;

  outputs =
    { nixpkgs, home-manager, ... }@inputs:
    let
      constants = import ./constants.nix;
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
          };
          extraSpecialArgs = { inherit inputs constants; };
          modules = [ ./users/${constants.user.name} ];
        };
    };
}
