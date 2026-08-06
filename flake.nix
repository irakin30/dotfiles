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
      # MacBook Configurations 
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .
      darwinConfigurations.MacBook = nix-darwin.lib.darwinSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./modules/darwin/configuration.nix
          ./modules/darwin/dock.nix
          ./modules/darwin/packages.nix
          ./modules/darwin/system.nix

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
      # yes I know that the correct latin is "Sol" but the name scheme works better
      # Build using:
      # $ nixos-rebuild switch --flake .#Sola --impure  (DOTFILES_DIR must be set, see home.nix)
      nixosConfigurations.Sola = nixpkgs.lib.nixosSystem {
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
      # (nix + home-manager on top of another distro; no system config).
      # Build using:
      # $ home-manager switch --flake . --impure  (DOTFILES_DIR must be set, see home.nix)
      homeConfigurations.irakin = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = { inherit inputs; };
        modules = [ ./modules/home-manager/home.nix ];
      };
    };
}
