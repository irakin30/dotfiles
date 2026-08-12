{config, pkgs, ...}: 
{
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."istabr" = {
    isNormalUser = true;
    description = "Istab Rakin";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.zsh;
    packages = with pkgs; [
      discord
      steam
    ];
  };

  # Required for shell = pkgs.zsh above: makes zsh a valid login shell
  # (/etc/shells) and sources the nix environment in it.
  programs.zsh.enable = true;
}

