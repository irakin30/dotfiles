{config, pkgs, ...}: 
{
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."istabr" = {
    isNormalUser = true;
    description = "Istab Rakin";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      kdePackages.kate
    #  thunderbird
    ];
  };
}

