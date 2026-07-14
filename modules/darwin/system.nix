{pkgs, ...}:
{ 
  # allow touchID for sudo
  security.pam.services.sudo_local.touchIdAuth = true; 

  # fonts! 
  fonts = {
      packages = with pkgs; 
      [
        nerd-fonts.symbols-only
        nerd-fonts.jetbrains-mono
      ];
    }; 

  system = {
    primaryUser = "irakin";
    primaryUserHome = "/Users/irakin";

    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToEscape = true; # for vim 
    }; 

    defaults = {
      SoftwareUpdate = {
        AutomaticallyInstallMacOSUpdates = false; # personal preference
      };

      screencapture = {
        include-date = true; 
        target = "clipboard";
      }; 

      finder = {
        AppleShowAllExtensions = true; 
        AppleShowAllFiles = true;
        ShowPathbar = true;
        FXDefaultSearchScope = "SCcf"; # from docs, changes search behavior to the current folder 
        FXRemoveOldTrashItems = true; # remove trash items after 30 days
        NewWindowTarget = "Home";
        _FXSortFoldersFirst = true; # keeps folders on top when sorting 
        FXPreferredViewStyle = "Nlsv"; # Finder list view
        ShowStatusBar = true; 
        CreateDesktop = false; # I don't want icons on the desktop 
        QuitMenuItem = true; # I can quit Finder!!
      };
    };
  };
}
