 {config, ...}:
 {
    # Necessary for using flakes on this system.
    nix.settings.experimental-features = ["nix-command" "flakes"];

    # Enable alternative shell support in nix-darwin.
    # programs.fish.enable = true;
    # Set Git commit hash for darwin-version.
    system.configurationRevision = config.rev or config.dirtyRev or null;

    # Used for backwards compatibility, please read the changelog before changing.
    # $ darwin-rebuild changelog
    system.stateVersion = 6;

    # The platform the configuration will be used on.
    nixpkgs = {
      hostPlatform = "aarch64-darwin";
      config.allowUnfree = true;
    };
    
    # nix.settings.trusted-users = [ "@admin" ];  # or "irakin" specifically
    # nix.linux-builder = {
    #   enable = true; 
    #   ephemeral = true;
    #   systems = [
    #     "x86_64-linux"
    #     "aarch64-linux"
    #   ];
    # };
}