{pkgs, ...} :
{
  # Let Home Manager manage itself  
  programs.home-manager.enable = true;
  home.stateVersion = "26.11";

  #user config 
  home.username = "irakin";
  home.homeDirectory = "/Users/irakin";

  home.packages = [
    pkgs.bat 
    pkgs.fzf 
    pkgs.lsd
    pkgs.zoxide
  ];

  home.file = { }; 
}
