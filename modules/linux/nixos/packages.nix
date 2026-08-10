{config, pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    ghostty
    neovim
    zsh
    kitty
  ];

  programs.firefox.enable = true;

}
