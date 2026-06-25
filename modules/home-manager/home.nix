{config, pkgs, ...} :
{
  # Let Home Manager manage itself  
  programs.home-manager.enable = true;

  #user config 
  home.username = "irakin";
  home.homeDirectory = if config.isDarwin then "/Users/irakin" else "/home/irakin/";

  home.packages = [
    pkgs.bat 
    pkgs.fzf 
    pkgs.lsd
    pkgs.zoxide
  ];

  home.file = { }; 
}
