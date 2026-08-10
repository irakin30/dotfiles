{config, pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    ghostty
    neovim
    playerctl
    kdePackages.dolphin
    wl-clipboard
  ];

  programs.firefox.enable = true;
  
  programs.noctalia-greeter = {
    enable = true;
    # Cached nixpkgs build instead of the flake's own (module default is
    # mkDefault, so this overrides cleanly; the input only supplies the module).
    package = pkgs.noctalia-greeter;

    # Optional configuration
    greeter-args = "";
    # Full declarative greeter.toml (overwritten on each activation).
    # See examples/greeter.toml for every key (appearance.palette, output, …). 
    settings = {
      keyboard = {
        layout = "us";
      };
    };
  };
}
