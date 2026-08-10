{
  description = "nix-darwin + NixOS system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      home-manager,
      nixpkgs,
    }:

    {
      # ALL REBUILD SCRIPTS ARE IMPURE 
      # DOTFILES_DIR must be set, see home.nix

      # MacBook Configurations 
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#Luna --impure 
      darwinConfigurations.Luna = nix-darwin.lib.darwinSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./modules/darwin/configuration.nix
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs; };
            home-manager.users.irakin = ./modules/home-manager/home.nix; 
          }
        ];
      };

      # NixOS Configurations
      # Build NixOS using:
      # $ nixos-rebuild switch --flake .#Terra --impure 
      nixosConfigurations.Terra = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./modules/linux/nixos/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs; };
            home-manager.users.irakin = ./modules/home-manager/home.nix;
          }
        ];
      };

      # Standalone home-manager, for linux machines that aren't NixOS
      # (nix + home-manager on top of another distro) 
      # This is mostly going to be used for my server configs.
      # Build using:
      # $ home-manager switch --flake . --impure  (DOTFILES_DIR must be set, see home.nix)
      homeConfigurations.Sola = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = { inherit inputs; };
        modules = [ ./modules/home-manager/home.nix ];
      };
    };
}
