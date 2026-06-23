{
  description = "WIP nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # home-manager = {
    #   url = "github:nix-community/home-manager";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      # home-manager,
      nixpkgs,
    }:
    {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .
      darwinConfigurations.Luna = nix-darwin.lib.darwinSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./sys/darwin/configuration.nix
          ./sys/darwin/dock.nix
          ./sys/darwin/packages.nix
          ./sys/darwin/system.nix

          # home-manager.darwinModules.home-manager
          # {
          #   home-manager.useGlobalPkgs = true;
          #   home-manager.useUserPackages = true;
          #   home-manager.extraSpecialArgs = { inherit inputs; };
          # }
        ];
      };
    };
}
