{config, pkgs, ...} :
{
  # Let Home Manager manage itself  
  programs.home-manager.enable = true;
  home.stateVersion = "26.11";

  #user config 
  home.username = "irakin";
  home.homeDirectory = if pkgs.stdenv.isDarwin then "/Users/irakin/" else "/home/irakin/";

  home.packages = [
    pkgs.bat 
    pkgs.fzf 
    pkgs.lsd
    pkgs.zoxide
  ];

  home.file = { }; 
}
