{config, pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    ghostty
    neovim
  ];

  programs.firefox.enable = true;

}
