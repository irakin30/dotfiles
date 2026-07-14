{ 
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = [ ];

  # Homebrew management
  homebrew = {
    # basic stuff
    enable = true; 
    enableZshIntegration = true;

    # don't upgrade automatically, just in case something breaks
    onActivation = {
      autoUpdate = false;
      upgrade = false;
    };

    # GUI apps since nixpkgs doesn't really play nicely with them
    casks = [
      "discord"
      "crossover"
      "steam"
      "ghostty" # my preferred terminal emulator
    ];

    taps = [ ];
 
    # prefer nixpkgs whenever possible
    brews = [ ]; 
  };
}
