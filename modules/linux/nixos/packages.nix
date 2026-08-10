{config, pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    ghostty
    neovim
    zsh
    kitty
  ];

  programs.firefox.enable = true;
  
  programs.noctalia-greeter = {
    enable = true;

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
