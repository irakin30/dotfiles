 {config, ...}:
 {
    # Necessary for using flakes on this system.
    nix.settings.experimental-features = ["nix-command" "flakes"];

    users.users.irakin = {
      name = "irakin";
      home = "/Users/irakin";
    };

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
    
}
