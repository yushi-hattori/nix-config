{
  description = "NixOS and nix-darwin configs for my machines";
  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05";

    # Home manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # NixOS profiles to optimize settings for different hardware
    hardware.url = "github:nixos/nixos-hardware";

    # Global catppuccin theme
    catppuccin.url = "github:catppuccin/nix";

    # Declarative flatpak manager
    nix-flatpak.url = "github:gmodena/nix-flatpak?ref=v0.6.0";

    # Declarative kde plasma manager
    plasma-manager = {
      url = "github:AlexNabokikh/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    # Nix Darwin (for MacOS machines)
    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Nix WSL (for Windows machines)
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";

    # Extras

    opencode = {
      url = "github:sst/opencode/v0.3.58";
      flake = false;
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      # IMPORTANT: we're using "libgbm" and is only available in unstable so ensure
      # to have it up-to-date or simply don't specify the nixpkgs input
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Neovim

    nixCats = {
      url = "github:BirdeeHub/nixCats-nvim";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };

    plugins-debugmaster = {
      url = "github:miroshQa/debugmaster.nvim";
      flake = false;
    };

    plugins-nui = {
      url = "github:MunifTanjim/nui.nvim";
      flake = false;
    };

    plugins-opencode = {
      url = "github:NickvanDyke/opencode.nvim";
      flake = false;
    };
  };

  outputs = {
    self,
    catppuccin,
    darwin,
    home-manager,
    nixpkgs,
    ...
  } @ inputs: let
    inherit (self) outputs;

    # Define user configurations
    users = {
      "yhattori" = {
        avatar = ./files/avatar/face;
        # email = "";
        fullName = "Yushi Hattori";
        gitKey = "";
        name = "yhattori";
      };
    };

    # Function for NixOS system configuration
    mkNixosConfiguration = hostname: username:
      nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs outputs hostname;
          userConfig = users.${username};
          nixosModules = "${self}/modules/nixos";
        };
        modules = [./hosts/${hostname}];
      };

    # Function for nix-darwin system configuration
    mkDarwinConfiguration = hostname: username:
      darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = {
          inherit inputs outputs hostname;
          userConfig = users.${username};
          darwinModules = "${self}/modules/darwin";
        };
        modules = [./hosts/${hostname}];
      };

    # Function for Home Manager configuration
    mkHomeConfiguration = system: username: hostname:
      home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {inherit system;};
        extraSpecialArgs = {
          inherit inputs outputs;
          userConfig = users.${username};
          nhModules = "${self}/modules/home-manager";
        };
        modules = [
          ./home/${username}/${hostname}
          catppuccin.homeModules.catppuccin
        ];
      };
  in {
    nixosConfigurations = {
      framework13 = mkNixosConfiguration "framework13" "yhattori";
    };

    # darwinConfigurations = {
    #   "some.random.hostname" = mkDarwinConfiguration "some.random.hostname" "yhattori";
    # };

    homeConfigurations = {
      # "yhattori@some.random.hostname" =
      #   mkHomeConfiguration "aarch64-darwin" "alexander.nabokikh"
      #   "PL-OLX-KCGXHGK3PY";
      "yhattori@framework13" = mkHomeConfiguration "x86_64-linux" "yhattori" "framework13";
      "yhattori@wsl" = mkHomeConfiguration "x86_64-linux" "yhattori" "wsl";
    };

    overlays = import ./overlays {inherit inputs;};
  };
}
