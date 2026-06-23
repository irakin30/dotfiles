{pkgs, ...} :
{
  home.username = "irakin";
  home.homeDirectory = "/Users/irakin";

  home.packages = [
    pkgs.bat 
    pkgs.fzf 
    pkgs.lsd
    pkgs.zoxide
  ];

  home.file = {
    ".zshrc".source = "dotfiles/zshrc";
  };
}